module diagram;
import shaderplayground;

struct TestUniforms
{
    @Color             vec3 uColor = vec3(1, 1, 1);
    @Range(0, 1)       float uAmbient = 0.2;
    @Range(0, 1)       float uDiffuse = 0.5;
    @Edit              vec3 uLightPosition = vec3(0, 5, 1);
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
    mat3 uModelViewInverseTranspose;
    mat4 uModelView;
    mat4 uView;
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    vec3 aNormal;
    vec3 aPosition;
    // vec2 aTexCoord;
}

alias Model_t = Model!(TestAttribute, TestUniforms);
alias Object_t = shaderplayground.object.Object!(TestAttribute, TestUniforms);

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TestAttribute ~ q{
    uniform mat4 uModelViewProjection;
    uniform mat4 uModelView;
    uniform mat3 uModelViewInverseTranspose;

    out vec3 vNormal;
    out vec4 vECPosition;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vECPosition = uModelView * vec4(aPosition, 1.0);
        vNormal = uModelViewInverseTranspose * aNormal;
    }
};

immutable string fragmentShaderText = SHADER_HEADER ~ q{
    in vec3 vNormal;
    in vec4 vECPosition;

    uniform mat4 uView;

    out vec4 fragColor;

    uniform vec3 uColor;
    uniform float uAmbient;
    uniform float uDiffuse;
    uniform vec3 uLightPosition;

    void main()
    {
        vec4 to_light_vector = normalize(uView * vec4(uLightPosition, 1) - vECPosition);
        float diffuse = clamp(dot(vec3(to_light_vector), vNormal), 0, 1) * uDiffuse;
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        fragColor = vec4(uColor * sum, 1.0);
    }
};



class App : IApp
{
    import shaderplayground.object;
    import shaderplayground.csv;
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    Model_t prismModel;
    Csv dataCsv;

    int startIndex = 0;
    int endIndex = 10;
    size_t[] numericIndices;
    float[] dataPoints;
    float maxDataValue;
    float minDataValue;

    void renewData()
    {
        minDataValue =  float.infinity;
        maxDataValue = -float.infinity;
        foreach (i; 0..dataCsv.numRows)
        {
            if (dataCsv.data[selectedDataIndex][i] == "")
            {
                dataPoints[i] = float.nan;
                continue;
            }
            dataPoints[i] = to!float(dataCsv.data[selectedDataIndex][i].get());
            minDataValue = min(dataPoints[i], minDataValue);
            maxDataValue = max(dataPoints[i], maxDataValue);
        }
    }

    struct Params
    {
        @Range(0,   1)    float belowMinHeight  = 0.1;
        @Range(0,   3)    float minHeight       = 1;
        @Range(0.5, 10)   float maxHeight       = 5;
        @Range(0,   1)    float width           = 0.2;
        @Range(0,   0.2)  float spacing         = 0.01;

    }    
    Params params;

    void setup()
    {
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");
        prismModel = Model_t(&program, makePrism!TestAttribute());

        dataCsv = loadCsv(getAssetPath("income.csv"));
        import std.range;
        numericIndices = dataCsv.getNumericIndices().array;
        if (!numericIndices.empty)
        {
            selectedDataIndex = numericIndices[0];
            dataPoints = new float[](dataCsv.numRows);
            renewData();
        }
    }

    void visualizeDataPoints()
    {
        float heightGap = params.maxHeight - params.minHeight;
        float valueGap = maxDataValue - minDataValue;
        float xShift = 0;

        foreach (index; startIndex..endIndex+1)
        {
            float value = dataPoints[index];
            float height;
            import std.math.traits;
            if (isNaN(value))
            {
                height = params.belowMinHeight;
            }
            else
            {
                height = params.minHeight + (heightGap) * (value - minDataValue) / valueGap;
            }
            auto scale = scaleMatrix(vec3(params.width, height, params.width));
            auto transform = translationMatrix(vec3(xShift, 0, 0)) * scale;
            prismModel.draw(&uniforms, transform);

            {
                import std.math : PI_2;
                auto factor = params.width / g_TextDrawer.getHeight();
                auto textScale = scaleMatrix(vec3(factor, factor, 1));
                auto textRotation = rotationMatrix(Axis.z, -cast(float) PI_2);
                auto textTranslation = translationMatrix(vec3(xShift, 0, params.width));
                g_TextDrawer.drawLine(
                    dataCsv.data[selectedLabelIndex][index], 
                    TextAlignment.Right|TextAlignment.Top, 
                    textTranslation * textRotation * textScale);
            }

            xShift += (params.spacing + params.width);
        }
    }

    void loop(double dt)
    {
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        visualizeDataPoints();

        void drawText(string text, vec3 translation)
        {
            g_TextDrawer.drawLine(text, TextAlignment.Right|TextAlignment.Middle, translationMatrix(translation));
        }

        if (!dataCsv.getNumericIndices().empty)
        {
            drawText("Numeric: " ~ dataCsv.header[selectedDataIndex], vec3(-1, 0, 0));
        }
        drawText("Label: " ~ dataCsv.header[selectedLabelIndex], vec3(-1, g_TextDrawer.getHeight(), 0));
    }

    size_t selectedLabelIndex = 0;
    size_t selectedDataIndex = 0;

    void doImgui()
    {
        .doImgui(&uniforms);
        .doImgui(&params);

        if (ImGui.BeginCombo("Select label column", dataCsv.header[selectedLabelIndex].nullTerminated))
        {
            foreach (index, ref h; dataCsv.header)
            {
                bool isSelected = (index == selectedLabelIndex);
                if (ImGui.Selectable(h.nullTerminated, isSelected))
                    selectedLabelIndex = index;
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }

        auto numeric = dataCsv.getNumericIndices();
        if (!numeric.empty && ImGui.BeginCombo("Select data column", dataCsv.header[selectedDataIndex].nullTerminated))
        {
            foreach (index; numeric)
            {
                bool isSelected = (index == selectedDataIndex);
                if (ImGui.Selectable(dataCsv.header[index].nullTerminated, isSelected))
                {
                    selectedDataIndex = index;
                    renewData();
                }
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }

        ImGui.SliderInt("Starting index", &startIndex, 0, endIndex);
        ImGui.SliderInt("Ending index", &endIndex, startIndex, cast(int) dataCsv.numRows - 1);
        if (startIndex < 0) 
            startIndex = 0;
        if (endIndex >= dataCsv.numRows) 
            endIndex = cast(int) dataCsv.numRows - 1;
        if (startIndex > endIndex) 
            startIndex = endIndex;
        if (endIndex < startIndex)
            endIndex = startIndex;
    }
}
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

import shaderplayground.string;
struct Csv
{
    NullTerminatedString[] header;
    ValueType[] inferredTypes;
    NullTerminatedString[][] data;

    auto getNumericIndices()
    {
        import std.range;
        import std.algorithm;
        return iota(header.length).filter!(
            i => inferredTypes[i] == ValueType.Double || inferredTypes[i] == ValueType.Int);
    }

    size_t numRows() { return data[0].length; }
    size_t numColumns() { return header.length; }
}

enum ValueType
{
    Double, Int, Other
}

int toIntZero(string str)
{
    if (str.empty) 
        return 0;
    return to!int(str);
}

double toFloatZero(string str)
{
    if (str.empty)
        return 0;
    return to!double(str);
}

Csv loadCsv(string csvPath)
{
    import std.stdio;
    import std.algorithm;
    import std.range;
    import std.array;

    auto file = File(csvPath, "r");
    auto lines = file.byLine;

    char[] convertEntry(char[] entry)
    {
        if (entry.length >= 2 && entry[0] == '"' && entry[$-1] == '"')
            entry = entry[1..$-1];
        return entry;
    }

    Csv result;
    
    auto firstLine = lines.front;
    // Remove BOM
    if (firstLine.length > 3 && firstLine[0..3] == [0xEF,0xBB,0xBF])
        firstLine = firstLine[3..$];

    foreach (i, header; firstLine.split(','))
    {
        result.header ~= NullTerminatedString(convertEntry(header));
    }
    result.data = new NullTerminatedString[][](result.header.length);
    lines.popFront();
    
    auto otherLines = lines.map!(l => l.dup).array;
    auto numLines = otherLines.length;
    foreach(ref v; result.data)
        v = new NullTerminatedString[](numLines);
    
    foreach (lineIndex, line; otherLines)
    {
        auto elements = line.split(",");
        import std.exception;
        // if (elements.length > result.header.length) 
        //     g_Logger.log("One of the lines is longer than the header");
        foreach (i, thing; elements)
        {
            if (i >= result.header.length)
            {
                g_Logger.log("Shoot: " ~ thing);
                break;
            }
            result.data[i][lineIndex] = convertEntry(thing);
        }
    }

    result.inferredTypes = new ValueType[result.header.length];

    foreach (i; 0..result.header.length)
    {
        bool canBe(T)()
        {
            foreach (j, it; result.data[i])
            {
                // Empty is fine
                if (it.empty) 
                    continue;
                try it.get.to!T(); 
                catch (Exception)
                {
                    return false;
                }
            }
            return true;
        }

        if (canBe!double)
            result.inferredTypes[i] = ValueType.Double;
        else if (canBe!int)
            result.inferredTypes[i] = ValueType.Int;
        else
            result.inferredTypes[i] = ValueType.Other;
    }

    return result;
}


class App : IApp
{
    import shaderplayground.object;
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    Model_t prismModel;
    Csv dataCsv;
    Object_t[] pool;

    void setup()
    {
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");
        prismModel = Model_t(&program, makePrism!TestAttribute());

        dataCsv = loadCsv(getAssetPath("income.csv"));
        if (!dataCsv.getNumericIndices().empty)
        {
            selectedDataIndex = dataCsv.getNumericIndices().front;
            pool = new Object_t[](dataCsv.numColumns);

            float[] values = new float[](dataCsv.numColumns);
            float nonZeroMin;
            float maximum;
            foreach (i; 0..dataCsv.numColumns)
            {
                values[i] = toFloatZero(dataCsv.data[selectedDataIndex][i]);
                if (values[i] != 0)
                {
                    import std.algorithm.comparison;
                    nonZeroMin = min(values[i], nonZeroMin);
                    maximum = max(values[i], maximum);
                }
            }

            enum maxHeight = 5;
            enum belowMinHeight = 0.1;
            enum minHeight = 1;
            float heightGap = maxHeight - minHeight;
            float valueGap = maximum - nonZeroMin;
            enum spacing = 0.01;
            enum width = 0.2;

            foreach (index, ref obj; pool)
            {
                auto value = values[index];
                float height;
                if (value < nonZeroMin)
                    height = belowMinHeight;
                else
                    height = minHeight + (heightGap) * (value - nonZeroMin) / valueGap;
                auto scale = scaleMatrix(vec3(width, height, width));
                obj = Object_t(&prismModel, translationMatrix(vec3((spacing + width) * index, 0, 0)) * scale);
            }
        }

    }

    void loop(double dt)
    {
        // glEnable(GL_CULL_FACE);
        // glCullFace(GL_BACK);

        foreach (ref obj; pool)
        {
            obj.draw(&uniforms);
        }

        void drawText(string text, vec3 translation)
        {
            g_TextDrawer.drawLine(text, TextAlignment.Right|TextAlignment.Middle, translationMatrix(translation));
        }

        if (!dataCsv.getNumericIndices().empty)
        {
            drawText("Numeric: " ~ dataCsv.header[selectedDataIndex], vec3(0, 0, 0));
        }
        drawText("Label: " ~ dataCsv.header[selectedLabelIndex], vec3(0, g_TextDrawer.getHeight(), 0));
    }

    size_t selectedLabelIndex = 0;
    size_t selectedDataIndex = 0;

    void doImgui()
    {
        .doImgui(&uniforms);

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
                    selectedDataIndex = index;
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }
    }
}
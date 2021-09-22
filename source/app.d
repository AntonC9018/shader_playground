module app;
import shaderplayground;

struct TestUniforms
{
    @Color             vec3 uColor = vec3(1, 1, 1);
    @Range(0, 1)       float uAmbient = 0.2;
    @Range(0, 1)       float uDiffuse = 0.5;
    @Edit              vec3 uLightPosition = vec3(5, 1, 1);
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
    mat3 uModelViewInverseTranspose;
    mat4 uModelView;
    mat4 uView;

    // mat4 uModel;
    Texture2D uTexture;
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    vec3 aNormal;
    vec3 aPosition;
    vec2 aTexCoord;
}

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TestAttribute ~ q{
    uniform mat4 uModelViewProjection;
    uniform mat4 uModelView;
    uniform mat3 uModelViewInverseTranspose;

    out vec3 vNormal;
    out vec4 vECPosition;
    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vECPosition = uModelView * vec4(aPosition, 1.0);
        vNormal = uModelViewInverseTranspose * aNormal;
        vTexCoord = aTexCoord;
    }
};

immutable string fragmentShaderText = SHADER_HEADER ~ q{
    in vec3 vNormal;
    in vec4 vECPosition;
    in vec2 vTexCoord;

    uniform mat4 uView;

    out vec4 fragColor;

    uniform vec3 uColor;
    uniform float uAmbient;
    uniform float uDiffuse;
    uniform vec3 uLightPosition;
    uniform sampler2D uTexture;

    void main()
    {
        vec4 to_light_vector = normalize(uView * vec4(uLightPosition, 1) - vECPosition);
        float diffuse = clamp(dot(vec3(to_light_vector), vNormal), 0, 1) * uDiffuse;
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        vec3 texColor = texture(uTexture, vTexCoord).xyz;
        fragColor = vec4(uColor * texColor * sum, 1.0);
    }
};


class App : IApp
{
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    Model!(TestAttribute, TestUniforms) sphere;
    Model!(TestAttribute, TestUniforms) prism;
    TextureManager textureManager;

    void setup()
    {
        // TODO: hot reload on this stuff would be really nice.
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        enum recursionCount = 3;
        sphere = createModel(&program, makeSphere!TestAttribute(recursionCount));
        sphere.localTransform = translationMatrix(vec3(1, 1, 2));
     
        prism = createModel(&program, makePrism!TestAttribute());
        textureManager.setup();
        uniforms.uTexture = textureManager.currentTexture.texture;
    }

    void loop(double dt)
    {
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        sphere.draw(&uniforms);
        prism.draw(&uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui((t) { uniforms.uTexture = t.texture; });
    }
}


struct TextureManager
{
    static struct TextureThing 
    {
        string _name;
        TrueColorImage image;
        Texture2D texture;

        static TextureThing make(string pngPath)
        {
            import std.path;

            TextureThing t = void;
            string name = baseName(pngPath);
            t.image   = cast(TrueColorImage) readPng(pngPath);
            t.texture = Texture2D.make(t.image);
            t._name   = name ~ '\0';
            return t;
        }

        string name() const
        {
            return _name[0..$-1];
        }
    
        const (char)* nullTerminatedName() const
        {
            return name.ptr;   
        }

        auto opCmp(TextureThing t) const
        {
            return t._name > _name;
        }
    }

    TextureThing[string] textures;
    TextureThing* currentTexture;

    void setup()
    {
        import std.file;
        // TODO: watch the folder and add files when they appear there
        foreach (string pngPath; dirEntries(getAssetsPath(), "*.png", SpanMode.shallow))
        {
            auto t = TextureThing.make(pngPath);
            textures[t.name] = t;
            currentTexture = t.name in textures;
        }
    }

    void doImgui(void delegate(TextureThing*) onChanged)
    {
        if (ImGui.BeginCombo("Texture", currentTexture.nullTerminatedName))
        {
            foreach (ref t; textures.values)
            {
                bool isSelected = (currentTexture == &t);
                if (ImGui.Selectable(t.nullTerminatedName, isSelected))
                {
                    currentTexture = &t;
                    onChanged(currentTexture);
                }
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }
    }
}
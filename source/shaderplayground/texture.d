module shaderplayground.texture;

import arsd.png;
import bindbc.opengl;
import shaderplayground.common;

struct Texture2D
{
    uint id;

    void create()
    {
        glGenTextures(1, &id);
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_2D, id);
    }

    void setData(const TrueColorImage image)
    { 
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.imageData.bytes.ptr);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
}

Texture2D texture2D(const TrueColorImage image)
{
    Texture2D result;
    result.create();
    result.bind();
    result.setData(image);
    return result;
}

struct CubeMap
{
    uint id;

    void create()
    {
        glGenTextures(1, &id);
        bind();

        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_CUBE_MAP, id);
    }

    void setData(in TrueColorImage[6] images)
    { 
        foreach (uint i, image; images)
        {
            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, image.width, image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, image.imageData.bytes.ptr);
        }
    }
}

CubeMap cubeMap(in TrueColorImage[6] images)
{
    CubeMap result;
    result.create();
    result.bind();
    result.setData(images);
    return result;
}

struct TextureManager
{
    import shaderplayground.string;

    static struct TextureThing 
    {
        NullTerminatedString name;
        TrueColorImage image;
        Texture2D texture;

        this(string pngPath)
        {
            import std.path;

            image   = cast(TrueColorImage) readPng(pngPath);
            texture = texture2D(image);
            name    = baseName(pngPath);
        }
    }

    TextureThing[string] textures;
    TextureThing* currentTexture;
    void delegate(TextureThing*) onChanged;

    void setup(void delegate(TextureThing*) onChanged = null)
    {
        import std.file;
        // TODO: watch the folder and add files when they appear there
        foreach (string pngPath; dirEntries(getAssetsPath(), "*.png", SpanMode.shallow))
        {
            auto t = TextureThing(pngPath);
            textures[t.name] = t;
            currentTexture = t.name in textures;
        }

        this.onChanged = onChanged;
        if (onChanged !is null)
            onChanged(currentTexture);
    }

    Texture2D* selectTexture(string name)
    {
        if (auto p = name in textures)
        {
            currentTexture = p;
            if (onChanged !is null)
                onChanged(currentTexture);
            return &p.texture;
        }
        return null;
    }

    void doImgui()
    {
        import imgui;
        if (ImGui.BeginCombo("Texture", currentTexture.name.nullTerminated))
        {
            foreach (ref t; textures.values)
            {
                bool isSelected = (currentTexture == &t);
                if (ImGui.Selectable(t.name.nullTerminated, isSelected))
                {
                    currentTexture = &t;
                    if (onChanged !is null)
                        onChanged(currentTexture);
                }
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }
    }
}


struct SkyBox
{
    import shaderplayground;

    struct Attribute
    {
        vec3 aPosition;
    }
    
    struct Uniforms
    {
        @Fragment CubeMap uSkybox;
        @Vertex mat4 uViewProjection;
    }

    static immutable vertexShaderText = SHADER_HEADER
    ~ VertexDeclarations!(Attribute, Uniforms) ~ q{
        
        out vec3 vTexCoord;
        
        void main()
        {
            vTexCoord = aPosition;
            gl_Position = uViewProjection * aPosition;
        }
    };

    static immutable fragmentShaderText = SHADER_HEADER
    ~ FragmentMarkedUniformDeclarations!(Uniforms) ~ q{

        out vec4 fragColor;
        in vec3 vTexCoord;

        void main()
        {
            fragColor = texture(uSkybox, vTexCoord);
        }
    };

    /// ---  Member Variables!!!
    CubeMap cubeMap;
    Model!Attribute cubeModel;
    ShaderProgram!Uniforms program;


    void setup()
    {
        program = ShaderProgram!Uniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");
    }

    void loop()
    {

    }
}
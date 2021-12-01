module cloth;

import shaderplayground;

struct Uniforms
{
    @Vertex mat4 uModelViewProjection;

    @Fragment {
        float uTime;
        Texture2D uTexture;
        @Range(0, 2) float uDisplacementFactor = 1;
        @Range(0, 100) float uLocality = 1;
    }
}

struct Attribute
{
    vec3 aPosition;
    vec2 aTexCoord;
}

alias A = TypeAliases!(Attribute, Uniforms);
alias Model_t = A.Model;
alias Object_t = A.Object;

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexDeclarations!(Attribute, Uniforms) ~ q{

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }
};


// https://thebookofshaders.com/11/
immutable string fragmentShaderText = SHADER_HEADER
    ~ FragmentMarkedUniformDeclarations!Uniforms 
    ~ importNoise.source ~ q{

    in vec2 vTexCoord;
    out vec4 fragColor;

    void main() 
    {
        float displacement = uDisplacementFactor / uLocality;
        vec2 sampledPoint = vTexCoord * uLocality + uTime;
        float x = noise(sampledPoint) * displacement;
        float y = noise(sampledPoint + 5.0) * displacement;
        fragColor = texture(uTexture, vTexCoord + vec2(x, y));
    }
};


class App : IApp
{
    Uniforms uniforms;
    ShaderProgram!Uniforms program;
    TextureManager textureManager;
    Model_t squareModel;
    Object_t square;

    void setup()
    {
        program = ShaderProgram!Uniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        squareModel = createModel(makeSquare!Attribute, program.id);
        square = makeObject(&squareModel);

        textureManager.setup();
        uniforms.uTexture = *textureManager.selectTexture("covor.png");
    }

    void loop(double dt)
    {
        uniforms.uTime = glfwGetTime();
        square.draw(&program, &uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui((t) { uniforms.uTexture = t.texture; });
    }
}

module cloth;

import shaderplayground;

struct TestUniforms
{
    /// These ones here are built in.
    mat4 uModelViewProjection;

    @Fragment {
        Texture2D uTexture;
        @Range(0, 2) float uDisplacementFactor = 1;
        @Range(0, 100) float uLocality = 1;
    }
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    // vec3 aNormal;
    vec3 aPosition;
    vec2 aTexCoord;
}

alias Model_t = Model!(TestAttribute, TestUniforms);
alias Object_t = shaderplayground.object.Object!(TestAttribute, TestUniforms);

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TestAttribute ~ q{

    uniform mat4 uModelViewProjection;

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }
};

// https://thebookofshaders.com/11/
immutable string fragmentShaderText = SHADER_HEADER
    ~ FragmentMarkedUniformDeclarations!TestUniforms ~ q{

    in vec2 vTexCoord;
    out vec4 fragColor;

    // 2D Random
    float random (in vec2 st) 
    {
        return fract(sin(dot(st.xy,
                            vec2(12.9898,78.233)))
                    * 43758.5453123);
    }

    // 2D Noise based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise (in vec2 st) 
    {
        vec2 i = floor(st);
        vec2 f = fract(st);

        // Four corners in 2D of a tile
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));

        // Smooth Interpolation

        // Cubic Hermine Curve.  Same as SmoothStep()
        vec2 u = f * f * (3.0 - 2.0 * f);
        // u = smoothstep(0.0, 1.0, f);

        // Mix 4 coorners percentages
        return mix(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
    }

    void main() 
    {
        float x = noise(vTexCoord * uLocality) * uDisplacementFactor / uLocality;
        float y = noise(vTexCoord * uLocality + 5.0) * uDisplacementFactor / uLocality;
        fragColor = texture(uTexture, vTexCoord + vec2(x, y));
    }
};


class App : IApp
{
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    TextureManager textureManager;
    Model_t squareModel;
    Object_t square;

    void setup()
    {
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        squareModel = createModel(&program, makeSquare!TestAttribute);
        square = makeObject(&squareModel);

        textureManager.setup();
        uniforms.uTexture = *textureManager.selectTexture("covor.png");
    }

    void loop(double dt)
    {
        square.draw(&uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui((t) { uniforms.uTexture = t.texture; });
    }
}

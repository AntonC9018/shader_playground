module abstract_thing;

import shaderplayground;

// This was supposed to be a hair shader, but it turned out more like abstract art
struct Uniforms
{
    @Vertex mat4 uModelViewProjection;

    @Fragment {
        @Color {
            vec3 uMainColor = vec3(1, 0.7, 0);
            vec3 uHairColor = vec3(0, 0, 0);
            vec3 uAroundHairColor = vec3(1, 1, 1);
        }

        @Range(0, 50) float uHairDensity = 20;
        @Range(0, 0.5) float uHairThreshold = 0.1;
        @Range(0, 0.5) float uAroundHairThreshold = 0.01;
        @Range(0, 10) float uHairLength = 2;
        @Range(0, 30) float uLocality = 10;
    }
}

struct Attribute
{
    vec3 aPosition;
    vec2 aTexCoord;
}

alias Model_t = Model!(Attribute, Uniforms);
alias Object_t = shaderplayground.object.Object!(Attribute, Uniforms);

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexDeclarations!(Attribute, Uniforms) ~ q{

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }
};

static import cloth;

immutable string fragmentShaderText = SHADER_HEADER
    ~ FragmentMarkedUniformDeclarations!Uniforms 
    ~ cloth.noiseText ~ q{

    in vec2 vTexCoord;
    out vec4 fragColor;

    void main() 
    {
        vec2 sampledPoint = vTexCoord * uLocality;
        // sampledPoint.x /= uHairLength;
        sampledPoint.y *= uHairDensity;
        
        float pi_2 = radians(float(90));
        float unmappedAngle = noise(sampledPoint) * pi_2;
        float length = random(sampledPoint + vec2(3.0, 6.0));
        float colorIndex = noise((sampledPoint + vec2(cos(unmappedAngle), sin(unmappedAngle)) * uHairLength) + 2.5);

        vec3 color;
        if (colorIndex >= 1 - uHairThreshold)
            color = uHairColor;
        else
        {
            float amount = uHairThreshold + uAroundHairThreshold;
            if (colorIndex >= 1 - amount)
                color = mix(uAroundHairColor, uMainColor, (1 - colorIndex) / amount);
            else 
                color = uMainColor;
        }
        fragColor = vec4(color, 1);
    }
};


class App : IApp
{
    Uniforms uniforms;
    ShaderProgram!Uniforms program;
    Model_t squareModel;
    Object_t square;

    void setup()
    {
        program = ShaderProgram!Uniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        squareModel = createModel(&program, makeSquare!Attribute);
        square = makeObject(&squareModel);
    }

    void loop(double dt)
    {
        square.draw(&uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
    }
}

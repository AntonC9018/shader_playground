module cloth2;

import shaderplayground;

struct Uniforms
{
    @Vertex mat4 uModelViewProjection;

    @Fragment {
        @Range(0, 0.2) float uGapWidth = 0.1;
        @Color vec3 uGapColor = vec3(1, 0, 0);

        @Range(0, 0.2) float uGap2Width = 0.1;
        @Color vec3 uGap2Color = vec3(0, 1, 0);
        
        @Range(0, 0.4) float uRimWidth = 0.2;
        @Color vec3 uRimColor = vec3(0, 0, 1);

        @Range(0, 0.4) float uRhombusWidth = 0.2;
        @Color vec3 uRhombusColor = vec3(0.5, 0.8, 0);

        @Range(0, 0.2) float uRhombusCenterWidth = 0.1;
        @Color vec3 uRhombusCenterColor = vec3(0, 0, 0);

        @Range(0, 2) float uDisplacementFactor = 1;
        @Range(0, 100) float uLocality = 1;

        @Range(0, 20) float uNumPatterns = 2;
    }
}

struct Attribute
{
    vec3 aPosition;
    vec2 aTexCoord;
}

alias A = TypeAliases!(Attribute, Uniforms);


immutable string vertexShaderText = SHADER_HEADER 
    ~ A.VertexDeclarations ~ q{

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }
};

immutable string fragmentShaderText = SHADER_HEADER
    ~ A.FragmentDeclarations 
    ~ importNoise.source ~ q{

    in vec2 vTexCoord;
    out vec4 fragColor;

    vec3 getColor(vec2 coord)
    {
        float x = coord.x;
        float y = coord.y;

        if (y < uGapWidth)
            return uGapColor;
        
        y -= uGapWidth;

        if (x < uRhombusCenterWidth && y < uRhombusCenterWidth - x)
            return uRhombusCenterColor;

        if (x < 1 - uGap2Width && y < 1 - uGap2Width - x )
            return uRhombusColor;  

        if (y < 1 - x)
            return uGap2Color;

        return uRimColor;
    }

    void main() 
    {
        float locality = uLocality * uNumPatterns;
        float displacement = uDisplacementFactor / uLocality;
        vec2 sampledPoint = vTexCoord * locality;
        float xOffset = fract(noise(sampledPoint) * displacement);
        float yOffset = fract(noise(sampledPoint + 5.0) * displacement);

        vec2 t = mod(vTexCoord * uNumPatterns, 1.0) * 2;

        if (t.x > 1)
            t.x = 2 - t.x;
        if (t.y > 1)
            t.y = 2 - t.y;

        if (t.x > 1)
            t.x = 2 - t.x;
        if (t.y > 1)
            t.y = 2 - t.y;

        t.x = 1 - t.x;

        vec2 factor = vec2(
            1, (uRimWidth + uRhombusCenterWidth + uRhombusWidth + uGapColor + uGap2Width) / (uGap2Width + uRhombusWidth + uRhombusCenterWidth));

        vec3 color = getColor(t * factor / 2 + vec2(xOffset, yOffset));
        fragColor = vec4(color, 1);
    }
};


class App : IApp
{
    Uniforms uniforms;
    A.ShaderProgram program;
    A.Model squareModel;
    A.Object square;

    void setup()
    {
        program = A.ShaderProgram();
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

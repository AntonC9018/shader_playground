module cloth2;

import shaderplayground;

struct Uniforms
{
    @Vertex mat4 uModelViewProjection;

    @Fragment {
        @Color vec3[5] uColors = [
            vec3(1, 1, 1),
            vec3(1, 0, 0),
            vec3(0, 1, 0),
            vec3(0, 0, 1),
            vec3(1, 1, 1)   
        ];
        @Color  vec3[2] uMixinColors = [
            vec3(1, 1, 1),
            vec3(0, 0, 0)
        ];
        @Range(0, 1)    float[4] uColorChangeDistances = [ 0.25, 0.5, 0.75, 1.0 ];
        @Range(0, 20)   float uNumPatterns = 2;
        @Range(0, 5)    float uFluffDisplacementFactor = 1;
        @Range(0, 100)  float uFluffLocality = 1;
        @Range(0, 20)   float uFluffChangeSpeed = 1;
        @Range(0, 1)    float uMixinColorEffect = 0.5;
        @Range(0, 500)  float uMixinLocality = 1;
    }

    @ValuesSetCallback
    void valuesSet()
    {
        uColorChangeDistances[3] = 1;
    }
}

struct Attribute
{
    vec3 aPosition;
    vec2 aTexCoord;
}

alias A = TypeAliases!(Attribute, Uniforms);


immutable vertexShaderSource = A.vertexShaderSource(q{

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }
});

immutable fragmentShaderSource = A.fragmentShaderSource(q{

    in vec2 vTexCoord;
    out vec4 fragColor;

    float manhattanDistance(vec2 a, vec2 b)
    {
        return dot(abs(a - b), vec2(1, 1));
    }

    void main() 
    {
        vec2 coord = vTexCoord;

        coord -= vec2(0.5, 0.5);
        coord *= sqrt(2);
        coord += vec2(0.5, 0.5);

        coord *= uNumPatterns;
        coord = mod(coord, vec2(1, 1));

        float randomValue = noise(vTexCoord * uFluffLocality);

        vec2[4] points;
        // left
        points[0] = vec2(0.25, 0.5);
        // up
        points[1] = vec2(0.5, 0.25);
        // right
        points[2] = vec2(0.75, 0.5);
        // bottom
        points[3] = vec2(0.5, 0.75);


        float minDistance = manhattanDistance(coord, points[0]);
        for (int i = 1; i < 4; i++)
        {
            float distance = manhattanDistance(coord, points[i]);
            if (distance < minDistance)
                minDistance = distance;
        }
        minDistance *= 2;
        minDistance += sin(randomValue * radians(180.0) * uFluffChangeSpeed) * uFluffDisplacementFactor / uFluffLocality;

        vec3 color;

        if (minDistance >= 1)
        {
            color = uColors[uColors.length() - 1];
        }
        else
        {
            int index = 0;
            while (uColorChangeDistances[index] < minDistance
                && index <= uColors.length()
            )
            {
                index++;
            }
            color = uColors[index];
        }

        float randomValue2 = noise(vTexCoord * uMixinLocality);
        float sin2 = abs(sin(randomValue2 * radians(180.0)));
        vec3 mixinColor = sin2 * uMixinColors[0] + (1 - sin2) * uMixinColors[1]; 
        // color = color * (1 - uMixinColorEffect) + uMixinColorEffect * mixinColor;
        color = color * (1 - uMixinColorEffect) + color * uMixinColorEffect * randomValue2;
        fragColor = vec4(color, 1);
    }
}, [&importNoise]);


class App : IApp, ITerminate
{
    Uniforms uniforms;
    HotreloadShaderProgram!Uniforms program;
    A.Model squareModel;
    A.Object square;

    void setup()
    {
        load(uniforms);
        reinitializeHotloadShaderProgram(program, vertexShaderSource, fragmentShaderSource);
        squareModel = createModel(makeSquare!Attribute, program.id);
        square = makeObject(&squareModel);
    }

    void loop(double dt)
    {
        square.draw(&program, &uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
    }

    void terminate()
    {
        save(uniforms);
    }
}

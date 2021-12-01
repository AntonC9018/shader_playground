module abstract_thing;

import shaderplayground;

// This was supposed to be a hair shader, but it turned out more like abstract art
// The problem is that I cannot rotate around center of the blob because I cannot know its position.
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

alias A = TypeAliases!(Attribute, Uniforms);

immutable vertexSource = A.vertexShaderSource(q{

    out vec2 vTexCoord;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vTexCoord = aTexCoord;
    }

});

immutable fragmentSource = A.fragmentShaderSource(q{

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
}, [&importNoise]);


class App : IApp, ITerminate
{
    Uniforms uniforms;
    HotreloadShaderProgram!Uniforms p;
    A.Model squareModel;
    A.Object square;

    
    void setup()
    {
        load(uniforms);
        if (p is null)
        {
            p = new HotreloadShaderProgram!Uniforms();
            errors("After create");
            addSourcesGlobally(p, vertexSource);
            errors("After vertex");
            addSourcesGlobally(p, fragmentSource);
            errors("After fragment");
            p.linkProgram();
            errors("After link");
        }
        squareModel = createModel(makeSquare!Attribute, p.id);
        square = makeObject(&squareModel);
    }

    void loop(double dt)
    { 
        square.draw(&p, &uniforms);
    }
    void doImgui() { .doImgui(&uniforms); }
    void terminate() { save(uniforms); }
}
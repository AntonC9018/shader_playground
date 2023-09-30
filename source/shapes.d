module shapes;

import shaderplayground;
import abstract_thing;
import shaderplayground.axes_object;

struct Uniforms
{
    @Fragment {
        @Color             vec3 uColor = vec3(1, 1, 1);
        @Range(0, 1)       float uAmbient = 0.2;
        @Range(0, 1)       float uDiffuse = 0.5;
        @Edit              vec3[5] uLightPositions = [
                               vec3(5, 3, 1),
                               vec3(4, 2, 2),
                               vec3(3, 1, 3),
                               vec3(2, 5, 4),
                               vec3(1, 4, 5),
                           ];
        @Range(0, 5)       int uLightCount = 1;
        Texture2D uTexture;
        
        mat4 uView;
    }
    
    @Vertex {
        mat4 uModelViewProjection;
        mat3 uModelViewInverseTranspose;
        mat4 uModelView;
    }
}

struct Attribute
{
    vec3 aNormal;
    vec3 aPosition;
    vec2 aTexCoord;
}

alias A = TypeAliases!(Attribute, Uniforms);

immutable vertexShaderSource = A.vertexShaderSource(q{
    out vec3 vNormal;
    out vec4 vECPosition;
    out vec2 vTexCoord;
    // out vec3 vaNormal;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vECPosition = uModelView * vec4(aPosition, 1.0);
        vNormal = uModelViewInverseTranspose * aNormal;
        vTexCoord = aTexCoord;
        // vaNormal = aNormal;
    }
});

immutable fragmentShaderSource = A.fragmentShaderSource(q{
    in vec3 vNormal;
    in vec4 vECPosition;
    in vec2 vTexCoord;
    // in vec3 vaNormal;

    out vec4 fragColor;

    void main()
    {
        float diffuse = 0;
        for (int i = 0; i < uLightCount; i++)
        {
            vec4 light_position = vec4(uLightPositions[i], 1);
            vec4 to_light_vector = normalize(uView * light_position - vECPosition);
            diffuse += clamp(dot(vec3(to_light_vector), vNormal), 0, 1) * uDiffuse;
        }
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        vec3 texColor = texture(uTexture, vTexCoord).xyz;
        fragColor = vec4(uColor * texColor * sum, 1.0);

        // vec3 color = vNormal;
        // color /= 2;
        // color += vec3(0.5, 0.5, 0.5);
        // fragColor = vec4(color * sum, 1.0);
    }
});

struct TranslationScale
{
    vec3 position;
    float scale;
}

class App : IApp, ITerminate
{
    enum int shapeCount = 3;
    Uniforms uniforms;
    HotreloadShaderProgram!Uniforms program;
    A.Model[shapeCount] models;
    TranslationScale[shapeCount] shapeTransforms;

    TextureManager textureManager;
    AxesContext axesContext;
    AxesObject axesObject;

    void setup()
    {
        load(uniforms);
        reinitializeHotloadShaderProgram(
            program,
            vertexShaderSource,
            fragmentShaderSource);

        float currentScale = 1;
        float shapeRadius = 0.5;
        vec3 currentPosition = vec3(0, -shapeRadius, 1);

        TranslationScale getTransform()
        {
            TranslationScale t = 
            {
                position: currentPosition,
                scale: currentScale,
            };
            return t;
        }

        shapeTransforms[0] = getTransform();
        foreach (int i; 1 .. 3)
        {
            float topOfPreviousBase = currentScale * shapeRadius;

            currentScale /= 2;
            shapeTransforms[i].scale = currentScale;

            float toCenterOfCurrent = currentScale * shapeRadius;
            currentPosition += vec3(0, topOfPreviousBase + toCenterOfCurrent, 0);
            shapeTransforms[i].position = currentPosition;
        }

        {
            auto circlePoints = getUnclosedCircleBasePoints!Attribute(20);
            auto pointsCopy = circlePoints.dup;
            foreach (i; 0 .. models.length)
            {
                auto t = shapeTransforms[i];
                PathOnPointConfig config =  
                {
                    basePathPoints : pointsCopy,
                    topPointPosition : -t.position / t.scale,
                    numSections : 10,
                    isClosed : true,
                };
                auto hollowPyramid = makePathOntoPointData!Attribute(config);
                models[i] = createModel(hollowPyramid, program.id);
            }
        }

        textureManager.setup((t) { uniforms.uTexture = t.texture; });

        {
            AxesConfig config;
            config.vertexColors = [
                vec3(1, 0, 0), vec3(0, 0, 0), 
                vec3(0, 1, 0), vec3(0, 0, 0), 
                vec3(0, 0, 1), vec3(0, 0, 0), 
            ];
            config.size = 3;
            axesContext.setup(config);
            const float lineWidth = 5;
            axesObject = AxesObject(&axesContext, mat4.identity, lineWidth);
        }
    }
    
    void loop(double dt)
    {
        // glDisable(GL_DEPTH_TEST);
        // glCullFace(GL_BACK);

        // There's no instanced rendering in this engine.
        foreach (i, const t; shapeTransforms)
        {
            void draw(mat4 transform)
            {
                models[i].draw(&program, &uniforms, transform);
            }

            enum vec3 one = vec3(1, 1, 1);
            {
                mat4 transform = translationMatrix(t.position);
                transform *= scaleMatrix(one * t.scale);
                draw(transform);
            }
            {
                enum uint xaxis = 0;
                mat4 transform = rotationMatrix(xaxis, degtorad(180f));
                transform *= translationMatrix(t.position);
                transform *= scaleMatrix(one * t.scale);
                draw(transform);
            }
        }

        axesObject.draw();
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui();
    }

    void terminate()
    {
        save(uniforms);
    }
}
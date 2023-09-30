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

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vECPosition = uModelView * vec4(aPosition, 1.0);
        vNormal = uModelViewInverseTranspose * aNormal;
        vTexCoord = aTexCoord;
    }
});

immutable fragmentShaderSource = A.fragmentShaderSource(q{
    in vec3 vNormal;
    in vec4 vECPosition;
    in vec2 vTexCoord;

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

    enum bool _enableDebugThings = false;
    static if (_enableDebugThings)
    {
        A.Model cubeModel;
        A.Object cubeObject;
        A.Object cubeObject1;

        uint linesVaoId;
        VertexBuffer!LineAttribute linesVertexBuffer;
        size_t linesCount;
        enum size_t modelIndex = 0;
    }

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

        ModelData!Attribute[shapeCount] modelData;
        {
            vec2[] circlePoints = {
                CreateCircleConfig config = 
                {
                    numPoints : 15,
                    isClosedLoop: true,
                };
                return getCircleBasePoints!Attribute(config);
            }();

            foreach (i; 0 .. models.length)
            {
                auto t = shapeTransforms[i];
                PathOnPointConfig config =  
                {
                    basePathPoints : circlePoints,
                    topPointPosition : -t.position / t.scale,
                    numSections : 10,
                    isClosed : false,
                };
                auto hollowPyramid = makePathOntoPointData!Attribute(config);
                modelData = hollowPyramid;
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

        static if (_enableDebugThings)
        {
            cubeModel = createModel(makeCube!Attribute, program.id);
            cubeModel.localTransform = scaleMatrix(vec3(1, 1, 1) * 0.1) 
                * translationMatrix(-vec3(0.5, 0.5, 0.5));
            cubeObject = makeObject(&cubeModel);
            cubeObject1 = makeObject(&cubeModel);
            {
                const vertexIndex = 0;
                auto attribute = modelData[modelIndex].vertexData[vertexIndex];
                // It's just shifted eventually, it's not rotated or anything.
                // As long as that's true, this will work.
                vec3 position = vec3(0, 0, 0);
                position += attribute.aPosition;
                vec3 normal = attribute.aNormal;
                position -= shapeTransforms[0].position;
                cubeObject1.transform = translationMatrix(position);

                position += normal * 0.3;
                cubeObject.transform = translationMatrix(position);
            }

            {
                auto model = modelData[modelIndex];
                auto lineVertexData = new LineAttribute[model.vertexData.length * 2];
                foreach (vertexIndex, vertex; model.vertexData)
                {
                    vec3 position = vertex.aPosition;
                    vec3 normal = vertex.aNormal;
                    lineVertexData[vertexIndex * 2] = LineAttribute(position, vec3(1, 0, 0));
                    lineVertexData[vertexIndex * 2 + 1] = LineAttribute(position + normal * 0.4, vec3(1, 0, 0));
                }

                glGenVertexArrays(1, &linesVaoId);
                glBindVertexArray(linesVaoId);

                setupVertexBuffer(linesVertexBuffer, axesObject.model.lineProgram.id, lineVertexData[]);
                linesCount = lineVertexData.length / 2;
            }
        }
    }
    
    void loop(double dt)
    {
        // glDisable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        // There's no instanced rendering in this engine.
        foreach (i, const t; shapeTransforms)
        {
            void draw(mat4 transform)
            {
                models[i].draw(&program, &uniforms, transform);
            }

            enum vec3 one = vec3(1, 1, 1);
            foreach (index, faceToCull; [GL_BACK, GL_FRONT])
            {
                if (index == 1)
                    uniforms.uColor = vec3(1, 0, 0);
                else
                    uniforms.uColor = vec3(1, 1, 0);

                glCullFace(faceToCull);

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
        }

        glCullFace(GL_BACK);

        static if (_enableDebugThings)
        {
            auto old = uniforms.uColor;
            uniforms.uColor = vec3(1, 0, 0);
            cubeObject.draw(&program, &uniforms);
            cubeObject1.draw(&program, &uniforms);
            uniforms.uColor = old;
        }

        axesObject.draw();
        // NOTE: the program is not unbound after this.
        static if (_enableDebugThings)
        {
            glBindVertexArray(linesVaoId);
            int startingIndex = 0;
            glDrawArrays(GL_LINES, startingIndex, cast(uint) linesCount);
        }
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
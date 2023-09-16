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


class App : IApp, ITerminate
{
    Uniforms uniforms;
    HotreloadShaderProgram!Uniforms program;
    A.Model sphereModel;
    mat4[3] sphereTransform;
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

        const int recursionLevel = 3;
        sphereModel = createModel(makeSphere!Attribute(recursionLevel), program.id);

        float currentScale = 1;
        float sphereRadius = 0.75;
        vec3 currentPosition = vec3(0, -1, 0);
        mat4 getTransform()
        {
            return translationMatrix(currentPosition) 
                * scaleMatrix(vec3(1, 1, 1) * currentScale);
        }
        sphereTransform[0] = getTransform();
        foreach (int i; 1 .. 3)
        {
            currentPosition += vec3(0, currentScale * sphereRadius * 2, 0);
            currentScale /= 2;
            sphereTransform[i] = getTransform();
        }

        textureManager.setup((t) { uniforms.uTexture = t.texture; });

        axesContext.setup();
        const float lineWidth = 5;
        axesObject = AxesObject(&axesContext, mat4.identity, lineWidth);
    }
    
    void loop(double dt)
    {
        foreach (i, ref transform; sphereTransform)
            transform *= rotationMatrix!float(i % 3, dt);

        // There's no instanced rendering in this engine.
        foreach (transform; sphereTransform)
            sphereModel.draw(&program, &uniforms, transform);

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
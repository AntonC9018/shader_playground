module app;
import shaderplayground;

struct TestUniforms
{
    @Fragment {
        @Color             vec3 uColor = vec3(1, 1, 1);
        @Range(0, 1)       float uAmbient = 0.2;
        @Range(0, 1)       float uDiffuse = 0.5;
        @Edit              vec3 uLightPosition = vec3(5, 3, 5);
        Texture2D uTexture;
        
        // Built-in
        mat4 uView;
    }
    
    @Vertex {
        mat4 uModelViewProjection;
        mat3 uModelViewInverseTranspose;
        mat4 uModelView;
    }
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    vec3 aNormal;
    vec3 aPosition;
    vec2 aTexCoord;
}

alias A = TypeAliases!(TestAttribute, TestUniforms);
alias Model_t = A.Model;
alias Object_t = A.Object;

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexDeclarations!(TestAttribute, TestUniforms) ~ q{

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
};

immutable string fragmentShaderText = SHADER_HEADER 
    ~ FragmentMarkedUniformDeclarations!TestUniforms ~ q{

    in vec3 vNormal;
    in vec4 vECPosition;
    in vec2 vTexCoord;

    out vec4 fragColor;

    void main()
    {
        vec4 to_light_vector = normalize(uView * vec4(uLightPosition, 1) - vECPosition);
        float diffuse = clamp(dot(vec3(to_light_vector), vNormal), 0, 1) * uDiffuse;
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        vec3 texColor = texture(uTexture, vTexCoord).xyz;
        fragColor = vec4(uColor * texColor * sum, 1.0);
    }
};

Matrix!(float, 4) translationRotationScale(
    vec3 translation,
    Quaternion!(float) rotation,
    vec3 scale)
{
    return mat4.identity()
        * translationMatrix(translation) 
        * rotation.toMatrix4x4() 
        * scaleMatrix(scale);
}

class App : IApp
{
    import shaderplayground.object;
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    
    Model_t sphereModel;
    Model_t cubeModel;
    Object_t sphere;
    Object_t cube;
    TextObject text;

    TextureManager textureManager;

    bool isAnimating;
    float animationSpeed = 1;
    float time = 0;

    void setup()
    {
        // TODO: hot reload on this stuff would be really nice.
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        load(uniforms);

        enum recursionCount = 3;
        sphereModel = createModel(
            makeSphere!TestAttribute(recursionCount),
            program.id);
        cubeModel = createModel(
            makeCube!TestAttribute(),
            program.id);
        
        sphere = makeObject(&sphereModel, translationMatrix(vec3(1, 1, 2)));
        cube = makeObject(&cubeModel);

        text = TextObject("Hello World!");
        text.transform = translationMatrix(vec3(2, 0, 0));

        textureManager.setup();
        uniforms.uTexture = textureManager.currentTexture.texture;
    }

    void loop(double dt)
    {
        if (isAnimating)
        {
            {
                const rotation = rotationMatrix!float(0, animationSpeed * dt);
                sphere.transform = sphere.transform * rotation;
            }
            {
                time += animationSpeed * cast(float) dt;
                import std.math;
                const r = rotationQuaternion(vec3(1, 1, 1).normalized, time);
                const t = vec3(1, 0, 0) * 3 * sin(time);
                const scaleX = sin(time + 1333) * 1 + 1.5f;
                const scaleY = sin(2 * time + 133) * 1 + 1.5f;
                const scaleZ = sin(3 * time + 533) * 1 + 1.5f;
                const s = vec3(scaleX, scaleY, scaleZ);
                const transform = translationRotationScale(t, r, s);
                cube.transform = transform;
            }
        }

        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        sphere.draw(&program, &uniforms);
        cube.draw(&program, &uniforms);

        text.draw();
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui((t) { uniforms.uTexture = t.texture; });
        ImGui.Checkbox("Animate?", &isAnimating);
        ImGui.SliderFloat("Animation Speed", &animationSpeed, 0, 5);
    }

    void terminate()
    {
        save(uniforms);
    }
}

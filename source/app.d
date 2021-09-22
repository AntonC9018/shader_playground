module app;
import shaderplayground;

struct TestUniforms
{
    @Color             vec3 uColor = vec3(1, 1, 1);
    @Range(0, 1)       float uAmbient = 0.2;
    @Range(0, 1)       float uDiffuse = 0.5;
    @Edit              vec3 uLightPosition = vec3(100, 1, 1);
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
    mat3 uModelViewInverseTranspose;
    mat4 uModelView;
    mat4 uView;
    // mat4 uModel;
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    vec3 aNormal;
    vec3 aPosition;
}

immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TestAttribute ~ q{
    uniform mat4 uModelViewProjection;
    uniform mat4 uModelView;
    uniform mat3 uModelViewInverseTranspose;

    out vec3 vNormal;
    out vec4 vECPosition;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vECPosition = uModelView * vec4(aPosition, 1.0);
        vNormal = uModelViewInverseTranspose * aNormal;
    }
};

immutable string fragmentShaderText = SHADER_HEADER ~ q{
    in vec3 vNormal;
    in vec4 vECPosition;
    uniform mat4 uView;

    out vec4 fragColor;

    uniform vec3 uColor;
    uniform float uAmbient;
    uniform float uDiffuse;
    uniform vec3 uLightPosition;

    void main()
    {
        vec4 to_light_vector = normalize(uView * vec4(uLightPosition, 1) - vECPosition);
        float diffuse = clamp(dot(vec3(to_light_vector), vNormal), 0, 1) * uDiffuse;
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        fragColor = vec4(uColor * sum, 1.0);
    }
};


class App : IApp
{
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    Model!(TestAttribute, TestUniforms) sphere;
    Model!(TestAttribute, TestUniforms) prism;

    void setup()
    {
        // TODO: hot reload on this stuff would be really nice.
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        enum recursionCount = 3;
        sphere = createModel(&program, makeSphere!TestAttribute(recursionCount));
        sphere.localTransform = translationMatrix(vec3(1, 1, 2));
     
        prism = createModel(&program, makePrism!TestAttribute());
    }

    void loop(double dt)
    {
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        sphere.draw(&uniforms);
        prism.draw(&uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
    }
}
module app;
import shaderplayground;

struct TestUniforms
{
    @Fragment {
        @Color             vec3 uColor = vec3(1, 1, 1);
        @Range(0, 1)       float uAmbient = 0.2;
        @Range(0, 1)       float uDiffuse = 0.5;
        @Edit              vec3 uLightPosition = vec3(0, 5, 1);
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

alias Model_t = Model!(TestAttribute, TestUniforms);
alias Object_t = shaderplayground.object.Object!(TestAttribute, TestUniforms);

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


class App : IApp
{
    import shaderplayground.object;
    TestUniforms uniforms;
    ShaderProgram!TestUniforms program;
    
    Model_t sphereModel;
    Model_t prismModel;
    Object_t sphere;
    Object_t prism;
    TextObject text;

    TextureManager textureManager;

    void setup()
    {
        // TODO: hot reload on this stuff would be really nice.
        program = ShaderProgram!TestUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");

        enum recursionCount = 3;
        sphereModel = Model_t(&program, makeSphere!TestAttribute(recursionCount));
        prismModel = Model_t(&program, makePrism!TestAttribute());
        
        sphere = Object_t(&sphereModel, translationMatrix(vec3(1, 1, 2)));
        prism = Object_t(&prismModel);

        text = TextObject("Hello World!");
        text.transform = translationMatrix(vec3(2, 0, 0));

        textureManager.setup();
        uniforms.uTexture = textureManager.currentTexture.texture;
    }

    void loop(double dt)
    {
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);

        sphere.draw(&uniforms);
        prism.draw(&uniforms);

        text.draw();
    }

    void doImgui()
    {
        .doImgui(&uniforms);
        textureManager.doImgui((t) { uniforms.uTexture = t.texture; });
    }
}

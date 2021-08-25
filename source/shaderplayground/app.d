module shaderplayground.app;
import shaderplayground.logger;
import shaderplayground.shadercommon;
import shaderplayground.d_to_shader;
import shaderplayground.initialization;

import bindbc.opengl;
import bindbc.glfw;
import std.string;
import dlib.math; 

struct TestUniforms
{
    // @Edit           int uInteger; 
    // @Color          vec3 uColor;
    // @Range(1, 2)    float uThing;
    @Color           vec3 uThing;
    // @Edit           vec4 uAnotherThing;
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
}

struct TestAttribute
{
    vec3 aColor;
    vec2 aPosition;
}

immutable string vertexShaderText = SHADER_HEADER 
    ~ GetVertexAttributeShaderDeclarations!TestAttribute ~ q{
    uniform mat4 uModelViewProjection;

    out vec3 vColor;
    
    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 0.0, 1.0);
        vColor = aColor;
    }
};

immutable string fragmentShaderText = SHADER_HEADER ~ q{
    in vec3 vColor;
    out vec4 fragColor;

    uniform vec3 uThing;

    void main()
    {
        fragColor = vec4(vColor * uThing, 1.0);
    }
};

void run()
{
    import bindbc.opengl;
    import std.conv;
    import imgui;

    glfwSwapInterval(1);

    ShaderProgram!TestUniforms program;
    VertexBuffer!TestAttribute buffer;
    TestUniforms uniforms;
    uniforms.uThing = vec3(1, 1, 1);

    if (!program.initialize(vertexShaderText, fragmentShaderText)) return;

    buffer.create();
    buffer.bind();
    buffer.setup(program.id);
    
    TestAttribute[] vertexData = [
        { aColor: vec3(0, 0, 1), aPosition: vec2(-0.6f, -0.4f) },
        { aColor: vec3(1, 0, 0), aPosition: vec2( 0.6f, -0.4f) },
        { aColor: vec3(0, 1, 0), aPosition: vec2( 0.0f,  0.6f) }
    ];
    buffer.setData(vertexData);

    while (!glfwWindowShouldClose(g_Window))
    {
		glfwPollEvents();

        auto io = &ImGui.GetIO();
        
        ImguiImpl.NewFrame();
		{
			ImGui.Begin("Main Window");
            doImgui(&uniforms);
			ImGui.End();
		}
		ImGui.Render();
        
        float ratio;
        int width, height;
		glfwMakeContextCurrent(g_Window);
        glfwGetFramebufferSize(g_Window, &width, &height);
        ratio = width / cast(float) height;
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);

        mat4 model = rotationQuaternion(Vector3f(1.0f, 0.0f, 0.0f), cast(float) glfwGetTime()).toMatrix4x4();
        mat4 projection = orthoMatrix(-ratio, ratio, -1.0f, 1.0f, 1.0f, -1.0f);
        uniforms.uModelViewProjection = projection * model;

        program.use();
        program.setUniforms(&uniforms);
        glDrawArrays(GL_TRIANGLES, 0, 3);

		ImguiImpl.RenderDrawData(ImGui.GetDrawData());

		glfwMakeContextCurrent(g_Window);
		glfwSwapBuffers(g_Window);
    }
}
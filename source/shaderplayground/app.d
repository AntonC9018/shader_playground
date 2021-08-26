module shaderplayground.app;
import shaderplayground.logger;
import shaderplayground.shadercommon;
import shaderplayground.d_to_shader;
import shaderplayground.initialization;
import shaderplayground.freeview;

import bindbc.opengl;
import bindbc.glfw;
import std.string;
import dlib.math; 

struct TestUniforms
{
    // @Edit           int uInteger; 
    // @Color          vec3 uColor;
    @Range(1, 2)       float uThing2 = 0;
    @Color             vec3 uThing = vec3(1, 1, 1);
    // @Edit           vec4 uAnotherThing;
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
    float uFOV = 70;
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

struct Data
{
    FreeviewComponent freeview;
    ShaderProgram!TestUniforms program;
    VertexBuffer!TestAttribute buffer;
    TestUniforms uniforms;
}
Data data;

extern(C) void scrollCallback(GLFWwindow* window, double xOffset, double yOffset)
{
    // auto v = Vector2d(xOffset, yOffset);
    // data.freeview.onMouseScroll(v);
    data.uniforms.uFOV -= yOffset;
}

void run()
{
    import bindbc.opengl;
    import std.conv;
    import imgui;

    glfwSwapInterval(1);
    glfwSetScrollCallback(g_Window, cast(GLFWscrollfun) &scrollCallback);

    with(data)
    {
    freeview.reset();
    freeview.lookAt(vec3(0, 0, 0));
    freeview.mouseSensibility = 0.01f;
    
    if (!program.initialize(vertexShaderText, fragmentShaderText)) return;
    buffer.create();
    buffer.bind();
    buffer.setup(program.id);
    
    TestAttribute[] vertexData = [
        { aColor: vec3(0, 0, 1), aPosition: vec2( 0, 0) },
        { aColor: vec3(0, 1, 0), aPosition: vec2( 0, 1) },
        { aColor: vec3(0, 1, 0), aPosition: vec2( 1, 1) },
        { aColor: vec3(0, 1, 0), aPosition: vec2( 1, 1) },
        { aColor: vec3(0, 0, 1), aPosition: vec2( 0, 0) },
        { aColor: vec3(1, 0, 0), aPosition: vec2( 1, 0) }
    ];
    buffer.setData(vertexData);

    double time = glfwGetTime();

    while (!glfwWindowShouldClose(g_Window))
    {
		glfwPollEvents();

        double dt = glfwGetTime() - time;
        time = glfwGetTime();
        freeview.update(dt);
        
        ImguiImpl.NewFrame();
		{
			if (ImGui.Begin("Main Window"))
            {
                doImgui(&uniforms);
                ImGui.DragFloat("Distance", &freeview.distance, 0.5, 0, 20); 
                ImGui.DragFloat("Mouse sensitivity", &freeview.mouseSensibility, 0.001, -0.2, 0.2); 
                ImGui.DragFloat("Speed", &freeview.speed, 0.001, -0.1, 0.1); 
                ImGui.DragFloat("FOV", &uniforms.uFOV, 1, 0, 100);

                vec3 pos = freeview.position;
                ImGui.Text(pos.to!string().toStringz);
            }
            freeview.active = !ImGui.IsWindowFocused();
            ImGui.End();
		}
		ImGui.Render();

        int width, height;
		glfwMakeContextCurrent(g_Window);
        glfwGetFramebufferSize(g_Window, &width, &height);
        float ratio = cast(float) width / height;
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);

        // mat4 model = rotationQuaternion(Vector3f(1.0f, 0.0f, 0.0f), cast(float) glfwGetTime()).toMatrix4x4();
        mat4 model = translationMatrix(vec3(-0.5, -0.5, -2)); 
        mat4 projection = perspectiveMatrix(uniforms.uFOV, ratio, 0.1f, 100.0f);
        uniforms.uModelViewProjection = projection * freeview.invTransform * model;

        program.use();
        program.setUniforms(&uniforms);
        glDrawArrays(GL_TRIANGLES, 0, 6);

		ImguiImpl.RenderDrawData(ImGui.GetDrawData());

		glfwMakeContextCurrent(g_Window);
		glfwSwapBuffers(g_Window);
    }
    }
}
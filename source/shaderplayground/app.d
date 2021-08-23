module shaderplayground.app;
import shaderplayground.logger;
import shaderplayground.parsing;
import shaderplayground.shadercommon;

import bindbc.opengl;
import std.string;
import dlib.math; 

immutable string vertexShaderText = q{
    #version 330 core

    in vec3 aColor;
    in vec2 aPosition;

    uniform mat4 uModelViewProjection;

    out vec3 vColor;
    
    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 0.0, 1.0);
        vColor = aColor;
    }
};

immutable string fragmentShaderText = q{
    #version 330 core

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
    import shaderplayground.shader_to_d;
    import bindbc.opengl;
    import bindbc.glfw;
    import shaderplayground.initialization : g_Window;
    import shaderplayground.shaderloader;
    import std.conv;

    glfwSwapInterval(1);

    alias Info = ShaderProgramInfo!(vertexShaderText, fragmentShaderText);
    alias VBuffer = VertexBuffer!(Info.vertexAttributeInfos);
    Info.ShaderProgram program;
    VBuffer buffer;

    buffer.create();
    buffer.bind();
    
    VBuffer.Vertex v1;
    v1.aColor    = vec3(0, 0, 1);
    v1.aPosition = vec2(-0.6f, -0.4f);

    VBuffer.Vertex[3] vertexData = [
        v1,
        { vec3(1, 0, 0), vec2(0.6f,  -0.4f) },
        { vec3(0, 1, 0), vec2(0.0f,  0.6f)  }
    ];
    buffer.setData(vertexData);

    if (!program.initialize()) return;
    buffer.queryLocations(program.id);
    buffer.setupAttributes();
 
    while (!glfwWindowShouldClose(g_Window))
    {
        float ratio;
        int width, height;
 
        glfwGetFramebufferSize(g_Window, &width, &height);
        ratio = width / cast(float) height;
 
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);

        mat4 model = rotationQuaternion(Vector3f(1.0f, 0.0f, 0.0f), cast(float) glfwGetTime()).toMatrix4x4();
        mat4 projection = orthoMatrix(-ratio, ratio, -1.0f, 1.0f, 1.0f, -1.0f);
        mat4 mvp = projection * model;

        program.use();
        program.uModelViewProjection.set(mvp);
        program.uThing.set(vec3(1, 2, 3));
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(g_Window);
        glfwPollEvents();
    }
}
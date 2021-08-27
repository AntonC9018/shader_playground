module shaderplayground.app;
import shaderplayground.logger;
import shaderplayground.shadercommon;
import shaderplayground.d_to_shader;
import shaderplayground.initialization;
import shaderplayground.freeview;
import shaderplayground.sphere;

import bindbc.opengl;
import bindbc.glfw;
import std.string;
import dlib.math; 

struct TestUniforms
{
    // @Edit           int uInteger; 
    // @Color          vec3 uColor;
    // @Range(1, 2)       float uThing2 = 0;
    @Color             vec3 uColor = vec3(1, 1, 1);
    @Range(0, 1)       float uAmbient = 0.2;
    @Range(0, 1)       float uDiffuse = 0.5;
    // @Edit           vec4 uAnotherThing;
    
    /// These ones here are built in.
    mat4 uModelViewProjection;
    mat3 uModelViewInverseTranspose;
    mat4 uModelView;
    mat4 uView;
    // mat4 uModel;

    float uFOV = 70;
}

/// The idea is that these vertex attributes are automatically mirrored 
/// in the shader code below, so they are never out of sync
struct TestAttribute
{
    // vec3 aColor;
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

    const vec4 light_source = vec4(5, 5, 5, 1);

    void main()
    {
        vec4 to_light_vector = normalize(uView * light_source - vECPosition);
        float diffuse = dot(vec3(to_light_vector), vNormal) * uDiffuse;
        float ambient = uAmbient;
        float sum = ambient + diffuse;
        fragColor = vec4(uColor * sum, 1.0);
    }
};

struct Data
{
    // Camera data
    FreeviewComponent freeview;

    ShaderProgram!TestUniforms program;
    VertexBuffer!TestAttribute buffer;
    IndexBuffer indexBuffer;
    TestUniforms uniforms;
}
private Data data;


void run()
{
    import std.conv;
    import imgui;

    glfwSwapInterval(1);

    // Must be a plain function pointer, which is actually a shame.
    // A delegate here would be really convenient.
    static extern(C) void scrollCallback(GLFWwindow* window, double xOffset, double yOffset) nothrow
    {
        // auto v = Vector2d(xOffset, yOffset);
        // data.freeview.onMouseScroll(v);
        data.uniforms.uFOV -= yOffset;
    }
    glfwSetScrollCallback(g_Window, &scrollCallback);

    with(data) 
    {
    freeview.reset();
    freeview.lookAt(vec3(0, 0, 0));
    freeview.translateTarget(vec3(0, 0, -2));
    
    if (!program.initialize(vertexShaderText, fragmentShaderText)) return;

    // This is lazy and inefficient code at the moment, but whatever 
    const recursionCount = 3;
    auto sphereCreator = new IcoSphereCreator();
    auto geometry = sphereCreator.Create(recursionCount);

    buffer.create();
    buffer.bind();
    buffer.setup(program.id);
    TestAttribute[] vertexData = new TestAttribute[geometry.Positions.length];
    foreach (i, position; geometry.Positions)
    {
        // Still needs to be adjusted manually after the attribute structure changes
        // TODO: generate in a function and set this conditionally if the attribute has normals
        vertexData[i].aPosition = position;
        vertexData[i].aNormal = position.normalized;
    }
    // A square
    // TestAttribute[] vertexData = [
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 0, 0, 0) },
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 0, 1, 0) },
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 1, 1, 0) },
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 1, 1, 0) },
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 0, 0, 0) },
    //     { aNormal: vec3(1, 1, 1), aPosition: vec3( 1, 0, 0) }
    // ];
    buffer.setData(vertexData);

    indexBuffer.create();
    indexBuffer.bind();
    // ivec3[] indexData = [
    //     ivec3(0, 1, 2), ivec3(3, 4, 5)
    // ];
    auto indexData = geometry.TriangleIndexBuffer;
    assert(indexBuffer.validateData(indexData, vertexData.length));
    indexBuffer.setData(indexData);

    double time = glfwGetTime();

    while (!glfwWindowShouldClose(g_Window))
    {
		glfwPollEvents();

        double dt = glfwGetTime() - time;
        time = glfwGetTime();
        freeview.update(dt);
        
        ImguiImpl.NewFrame();
        if (ImGui.Begin("Main Window"))
        {
            ImGui.Text("User-defined uniforms");
            doImgui(&uniforms);
            ImGui.Separator();

            ImGui.Text("Camera stuff");
            ImGui.DragFloat("Distance", &freeview.distance, 0.5, 0, 20); 
            ImGui.DragFloat("Mouse sensitivity", &freeview.mouseSensibility, 0.001, -0.2, 0.2); 
            ImGui.DragFloat("Speed", &freeview.speed, 0.001, -0.1, 0.1); 
            ImGui.DragFloat("FOV", &uniforms.uFOV, 1, 0, 100);
            ImGui.Text(("Camera position: " ~ freeview.position.to!string()).toStringz());
            ImGui.Separator();
        }
        freeview.active = !ImGui.IsWindowFocused(ImGuiFocusedFlags_AnyWindow);
        ImGui.End();
		ImGui.Render();

        int width, height; 
		glfwMakeContextCurrent(g_Window);
        glfwGetFramebufferSize(g_Window, &width, &height);
        float ratio = cast(float) width / height;
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);
        glClear(GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);
        glCullFace(GL_BACK);

        mat4 model      = mat4.identity; 
        mat4 projection = perspectiveMatrix(uniforms.uFOV, ratio, 0.1f, 100.0f);
        mat4 view       = freeview.invTransform;

        void set(string name, alias expression)()
        {
            static if (__traits(hasMember, typeof(data.uniforms), name))
                __traits(getMember, data.uniforms, name) = expression();
        }

        // Conditional setting of uniforms
        // TODO: should be in a separate function
        set!("uModel",                      () => model);
        set!("uView",                       () => view);
        set!("uProjection",                 () => projection);
        set!("uModelView",                  () => view * model);
        set!("uModelViewInverseTranspose",  () => matrix4x4to3x3((view * model).inverse.transposed));
        set!("uModelViewProjection",        () => projection * view * model);

        program.use();
        program.setUniforms(&uniforms);
        // TODO: encapsulate in a `Model` sort of thing.
        glDrawElements(GL_TRIANGLES, cast(int) indexData.length * 3, GL_UNSIGNED_INT, cast(void*) 0);

		ImguiImpl.RenderDrawData(ImGui.GetDrawData());

		glfwMakeContextCurrent(g_Window);
		glfwSwapBuffers(g_Window);
    }
    }
}
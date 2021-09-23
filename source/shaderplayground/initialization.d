module shaderplayground.initialization;

import shaderplayground.logger;
import shaderplayground.freeview;
import shaderplayground.text;

import bindbc.glfw;
import bindbc.opengl;
import imgui;
public import ImguiImpl = imgui.glfw_impl;
import dlib.math;


__gshared GLFWwindow* g_Window;
__gshared FreeviewComponent g_Camera;
__gshared TextDrawer g_TextDrawer;

struct ScreenDimensions
{
    int width, height;
    float ratio() { return cast(float) width / height; }
}

__gshared ScreenDimensions g_CurrentWindowDimensions;

/// Loads GLFW, creates a window, sets it globally, Loads OpenGL 
void initialize()
{
    import bindbc.glfw.binddynamic;
    import std.conv;
    import std.algorithm : min;

    static logger = Logger("Initialization");

    const GLFWSupport glfwLoadResult = loadGLFW();
    switch (glfwLoadResult)
    {
    case GLFWSupport.badLibrary:
        logger.error("GLFW bad library.");
        return;

    case GLFWSupport.noLibrary:
        logger.error("GLFW no library.");
        return;

    default:
        logger.log("Successfully loaded GLFW");
        break;
    }

    const glfwInitResult = glfwInit();
    if (!glfwInitResult)
    {
        logger.error("GLFW init failed");
        return;
    }

    static void error_callback(int error, const(char)* description)
    {
        logger.error(description);
    }
    glfwSetErrorCallback(cast(GLFWerrorfun)(&error_callback));


    auto vidMode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    int width = vidMode.width - 200; 
    int height = vidMode.height - 200;
    // width = min(width, vidMode.width);
    // height = min(height, vidMode.height);

    glfwWindowHint(GLFW_VISIBLE, 0);
    glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);

    GLFWwindow* window = glfwCreateWindow(width, height, "Shaders", null, null);
    if (!window)
    {
        logger.error("Window or context creation failed");
        return;
    }
    g_Window = window;
    // glfwSetWindowPos(window, (vidMode.width - width) / 2, (vidMode.height - height) / 2);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    glfwShowWindow(window);



    const GLSupport glLoadResult = loadOpenGL();
    if (glLoadResult < GLSupport.gl33) 
    {
        import loader = bindbc.loader.sharedlib;
        foreach (info; loader.errors) 
        {
            logger.error(info.message);
        }

        switch (glLoadResult)
        {
        case GLSupport.noLibrary:
            logger.error("This application requires the GLFW library.");
            return;

        case GLSupport.badLibrary:
            logger.error("The version of the GLFW library on your system is too low. Please upgrade.");
            return;

        case GLSupport.noContext:
            logger.error("This program has encountered a graphics configuration error. Please report it to the developers.");
            return;

        default: return;
        }
    }

    
    static void setupCamera()
    {
        g_Camera = new FreeviewComponent();
        
        // Must be a plain function pointer, which is actually a shame.
        // A delegate here would be really convenient.
        static extern(C) void scrollCallback(GLFWwindow* window, double xOffset, double yOffset) nothrow
        {
            // auto v = Vector2d(xOffset, yOffset);
            // data.freeview.onMouseScroll(v);
            g_Camera.fov -= yOffset;
        }
        glfwSetScrollCallback(g_Window, &scrollCallback);

        g_Camera.lookAt(vec3(0, 0, 0));
        g_Camera.translateTarget(vec3(0, 0, -2));
    }
    setupCamera();

    static extern(C) void resetScreenDimensions(GLFWwindow* window, int width, int height) nothrow
    {
        g_CurrentWindowDimensions.width = width;
        g_CurrentWindowDimensions.height = width;
        // FIXME: Doesn't work without SetContextCurrent
        glViewport(0, 0, width, height);
    }
    glfwSetWindowSizeCallback(window, &resetScreenDimensions);
    glfwGetWindowSize(window, &g_CurrentWindowDimensions.width, &g_CurrentWindowDimensions.height);


    ImGui.CreateContext();
	ImGuiIO* io = &ImGui.GetIO();
	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;  // Enable Keyboard Controls
	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;   // Enable Gamepad Controls

	ImguiImpl.InitOpenGL(window);
	ImGui.StyleColorsDark();

    // const DPI_SCALE = 1.5;
    // auto style = &ImGui.GetStyle();
    // style.ScaleAllSizes(DPI_SCALE);

    // ImFontConfig cfg;
    // cfg._default_ctor();
    // cfg.SizePixels = 13 * DPI_SCALE; // default font size is 13
    // //io.FontGlobalScale = 2; // blurry, meh
    // io.Fonts.AddFontDefault(&cfg);
}

void shutdown()
{
    if (g_Window !is null) glfwDestroyWindow(g_Window); 
    glfwTerminate();
}

extern (System)
private void glErrorCallback(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, in GLchar* message, GLvoid* userParam)
{
    //string msg = format("glErrorCallback: source: %s, type: %s, id: %s, severity: %s, length: %s, message: %s, userParam: %s",
    //                     source, type, id, severity, length, message.to!string, userParam);

    //stderr.writeln(msg);
}

module initialization;

import logger;
import bindbc.glfw;

__gshared GLFWwindow* g_Window;

/// Loads GLFW, creates a window, sets it globally, Loads OpenGL 
void initialize()
{
    import bindbc.glfw.binddynamic;
    import bindbc.opengl;
    import std.conv;

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

    GLFWwindow* window = glfwCreateWindow(640, 480, "Shaders", null, null);
    if (!window)
    {
        logger.error("Window or context creation failed");
        return;
    }
    glfwMakeContextCurrent(window);
    g_Window = window;


    const GLSupport glLoadResult = loadOpenGL();
    if (glLoadResult != GLSupport.gl33) 
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
}

void shutdown()
{
    if (g_Window !is null) glfwDestroyWindow(g_Window); 
    glfwTerminate();
}
module shaderplayground.input;
import dlib.math;
import bindbc.glfw;
import shaderplayground.initialization : g_Window;

Vector2d getMousePosition()
{
    Vector2d result;
    glfwGetCursorPos(g_Window, &result.x, &result.y);
    return result;
}
enum MOUSE_BUTTON
{
    LEFT = GLFW_MOUSE_BUTTON_LEFT, RIGHT = GLFW_MOUSE_BUTTON_RIGHT
}

auto getMouseDown(MOUSE_BUTTON which)
{
    return glfwGetMouseButton(g_Window, which) == GLFW_PRESS;
}

enum KEY
{
    LEFT_CONTROL = GLFW_KEY_LEFT_CONTROL,
    E = GLFW_KEY_E,
    W = GLFW_KEY_W,
    S = GLFW_KEY_S,
    A = GLFW_KEY_A,
    D = GLFW_KEY_D,
    SPACE = GLFW_KEY_SPACE,
    LEFT_SHIFT = GLFW_KEY_LEFT_SHIFT
}

auto getKeyDown(KEY key)
{
    return glfwGetKey(g_Window, key) == GLFW_PRESS;
}
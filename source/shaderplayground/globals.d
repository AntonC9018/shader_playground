module shaderplayground.globals;

import shaderplayground.d_to_shader : SourceFilesHotreloadProvider;
import shaderplayground.freeview : FreeviewComponent;
import bindbc.glfw : GLFWwindow;
import shaderplayground.text : TextDrawer;

__gshared SourceFilesHotreloadProvider g_SourceFilesHotreloadProvider;
__gshared GLFWwindow* g_Window;
__gshared FreeviewComponent g_Camera;
__gshared TextDrawer g_TextDrawer;

struct ScreenDimensions
{
    int width, height;
    float ratio() { return cast(float) width / height; }
}
__gshared ScreenDimensions g_CurrentWindowDimensions;

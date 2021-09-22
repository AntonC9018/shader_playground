module shaderplayground;

public:
import shaderplayground.logger;
import shaderplayground.shadercommon;
import shaderplayground.d_to_shader;
import shaderplayground.initialization;
import shaderplayground.freeview;
import shaderplayground.model;
import shaderplayground.object;
import shaderplayground.app;
import std.conv;
import imgui;
import bindbc.opengl;
import bindbc.glfw;
import std.string;
import dlib.math; 
import arsd.png;

import shaderplayground.d_to_shader : Color;

// Currently the wd is in bin, and the assets are next to bin
// This function serves for easier future abstraction
string getAssetPath(string path)
{
    return "../assets/" ~ path;
}

// TODO: this should not exist
string getAssetsPath()
{
    return "../assets";
}
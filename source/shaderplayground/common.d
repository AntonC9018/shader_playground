module shaderplayground.common;

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
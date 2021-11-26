module shaderplayground.texture;

import arsd.png;
import bindbc.opengl;
import shaderplayground.common;

struct Texture2D
{
    uint id;

    void create()
    {
        glGenTextures(1, &id);
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    }

    void bind()
    {
        glBindTexture(GL_TEXTURE_2D, id);
    }

    void setData(const TrueColorImage image)
    { 
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.imageData.bytes.ptr);
        glGenerateMipmap(GL_TEXTURE_2D);
    }

    static Texture2D make(const TrueColorImage image)
    {
        Texture2D result;
        result.create();
        result.bind();
        result.setData(image);
        return result;
    }
}

struct TextureManager
{
    import shaderplayground.string;

    static struct TextureThing 
    {
        NullTerminatedString name;
        TrueColorImage image;
        Texture2D texture;

        static TextureThing make(string pngPath)
        {
            import std.path;

            TextureThing t = void;
            t.image   = cast(TrueColorImage) readPng(pngPath);
            t.texture = Texture2D.make(t.image);
            t.name    = baseName(pngPath);
            return t;
        }
    }

    TextureThing[string] textures;
    TextureThing* currentTexture;

    void setup()
    {
        import std.file;
        // TODO: watch the folder and add files when they appear there
        foreach (string pngPath; dirEntries(getAssetsPath(), "*.png", SpanMode.shallow))
        {
            auto t = TextureThing.make(pngPath);
            textures[t.name] = t;
            currentTexture = t.name in textures;
        }
    }

    Texture2D* selectTexture(string name)
    {
        if (auto p = name in textures)
        {
            currentTexture = p;
            return &p.texture;
        }
        return null;
    }

    void doImgui(void delegate(TextureThing*) onChanged)
    {
        import imgui;
        if (ImGui.BeginCombo("Texture", currentTexture.name.nullTerminated))
        {
            foreach (ref t; textures.values)
            {
                bool isSelected = (currentTexture == &t);
                if (ImGui.Selectable(t.name.nullTerminated, isSelected))
                {
                    currentTexture = &t;
                    onChanged(currentTexture);
                }
                if (isSelected)
                    ImGui.SetItemDefaultFocus();
            }
            ImGui.EndCombo();
        }
    }
}
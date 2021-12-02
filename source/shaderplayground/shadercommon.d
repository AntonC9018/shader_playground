module shaderplayground.shadercommon;

public import shaderplayground.logger;
public import bindbc.opengl;
public import dlib.math;

alias vec2 = Vector!(float, 2);
alias vec3 = Vector!(float, 3);
alias vec4 = Vector!(float, 4);

alias ivec2 = Vector!(int, 2);
alias ivec3 = Vector!(int, 3);
alias ivec4 = Vector!(int, 4);

alias bvec2 = Vector!(bool, 2);
alias bvec3 = Vector!(bool, 3);
alias bvec4 = Vector!(bool, 4);


enum string SHADER_HEADER = "#version 330 core\n";


string getErrorMessage(GLenum code)
{
    switch (code)
    {
    case GL_INVALID_OPERATION: return "Invalid operation";
    case GL_INVALID_VALUE: return "Invalid value";
    case GL_OUT_OF_MEMORY: return "Out of memory";
    case GL_INVALID_FRAMEBUFFER_OPERATION: return "Invalid framebuffer operation";
    case GL_INVALID_ENUM: return "Invalid enum";
    default: return "Unknown";
    }
}

void errors(string name)
{
    auto logger = Logger(name);
    errors(logger);
}

void errors(ref Logger logger)
{
    import std.conv : to;
    
    GLenum err;
    while((err = glGetError()) != GL_NO_ERROR)
    {
        logger.error(getErrorMessage(err));
    }
}

struct UniformLocation(string uniformName, T)
{
    enum name = uniformName; 
    int location = -1;

    void findLocation(uint programId)
    {
        import std.string;
        location = glGetUniformLocation(programId, name.toStringz());
    }
    
    void set(Args...)(auto ref Args args)
    {
        UniformSetValue!(name, T)(location, args);
    }
}

private template TypeSuffix(T)
{
    static if (is(T == float))
        enum TypeSuffix = "f";
    else static if (is(T == int))
        enum TypeSuffix = "i";
    else static if (is(T == uint))
        enum TypeSuffix = "ui";
    else
        static assert(0);
}

private template UniformSetValue(string name, F)
{
    import arsd.png;
    import shaderplayground.texture;

    static if (is(F == float) || is(F == int) || is(F == uint)) 
    {
        void UniformSetValue(int location, auto ref F value = F.init)
        {
            mixin(`glUniform1` ~ TypeSuffix!(F) ~ `(location, value);`);
            errors("Uniform " ~ name);
        }
    }
    else static if (is(F == Texture2D) || is(F == CubeMap))
    {
        void UniformSetValue(int location, F tex, uint textureUnit)
        {
            glActiveTexture(cast(GLenum) (GL_TEXTURE0 + textureUnit));
            tex.bind();
            glUniform1i(location, textureUnit);
        }
    }
    else
    {
        void UniformSetValue(int location, auto ref F value = F.init)
        {
            if (location == -1) return;
            import std.conv : to;

            enum string Suffix(T, int N) = N.to!string() ~ TypeSuffix!(T) ~ "v";

            static if (is(F : Vector!(T, N), T, int N))
            {
                mixin(`glUniform` ~ Suffix!(T, N))(location, 1, cast(T*) &value);
            }
            else static if (is(F : Matrix!(T, N), T, int N))
            {
                mixin(`glUniformMatrix` ~ Suffix!(T, N))(location, 1, GL_FALSE, cast(T*) &value);
            }
            else static assert(0);

            errors("Uniform " ~ name);
        }
    }
}
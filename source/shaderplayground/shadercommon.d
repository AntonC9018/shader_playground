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


struct VertexAttributeInfo(T, int loc)
{
    string name;

    this(string name) { this.name = name; }

    static if (loc == -1)
    {
        int location = -1;
       
        void findLocation(int programId)
        {
            import std.string;
            location = glGetAttribLocation(programId, name.toStringz());
        }
    }
    else
        enum location = loc;

    
    void setupInBuffer(GLsizei totalSize, ref uint currentOffset)
    {
        import std.traits;
        import std.meta;

        template GlType(T)
        {
            static if (is(T == int))
                enum GlType = GL_INT;
            else static if (is(T == float))
                enum GlType = GL_FLOAT;
            else static assert(0);
        } 

        glEnableVertexAttribArray(location);

        static if (is(T : float) || is(T : int))
        {
            glVertexAttribPointer(location, 1, GlType!(T), GL_FALSE, totalSize, cast(void*) currentOffset);
            currentOffset += 4;
        }
        else static if (is(T : Vector!Args, Args...))
        {
            glVertexAttribPointer(location, Args[1], GlType!(Args[0]), GL_FALSE, totalSize, cast(void*) currentOffset);
            currentOffset += Args[1] * 4;
        }
        else 
        {
            pragma(msg, T);
            static assert(0);
        }

        errors("Vertex " ~ name);
        g_Logger.log(location);
    } 
}


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

struct Uniform(T)
{
    string name; 
    int location = -1;

    void findLocation(uint programId)
    {
        import std.string;
        location = glGetUniformLocation(programId, name.toStringz());
    }
    
    template TypeSuffix(T)
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
    
    static if (is(T == float) || is(T == int) || is(T == uint)) 
    {
        void set(T value)
        {
            mixin(`glUniform1` ~ TypeSuffix!(T) ~ `(location, value);`);
            errors("Uniform " ~ name);
        }
    }
    else
    {
        void set(const ref T value)
        {
            if (location == -1) return;
            import std.conv : to;

            enum string Suffix(T, int N) = N.to!string() ~ TypeSuffix!(T) ~ "v";

            static if (is(T : Vector!(T, N), T, int N))
            {
                mixin(`glUniform` ~ Suffix!(T, N))(location, 1, cast(T*) &value);
            }
            else static if (is(T : Matrix!(T, N), T, int N))
            {
                mixin(`glUniformMatrix` ~ Suffix!(T, N))(location, 1, GL_FALSE, cast(T*) &value);
            }
            errors("Uniform " ~ name);
        }
    }
}
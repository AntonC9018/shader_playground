module shaderplayground.d_to_shader;

import shaderplayground.shadercommon;
import imgui;

import std.conv : to;
import std.string : toStringz;

/// Makes imgui sliders and stuff for the value
enum Edit;
/// Treat vector value as color
enum Color;
/// Make slider in between values `a` and `b`
struct Range
{
    float a; 
    float b;
}

template VertexAttributeShaderDeclarations(TAttribute)
{
    template Prefix(T)
    {
        static if (is(T == float))
            enum Prefix = "";
        else static if (is(T == int))
            enum Prefix = "i";
        else static if (is(T == bool))
            enum Prefix = "b";
        else static assert(0);
    }
    string _get()
    {
        string result = "";
        static foreach (field; TAttribute.tupleof)
        {{
            string typeName;
            alias F = typeof(field);

            static if (is(F == float) || is(F == int) || is(F == bool))
            {
                typeName = F.stringof;
            }
            else static if (is(F : Vector!(T, N), T, int N))
            {
                typeName = Prefix!T ~ "vec" ~ N.to!string();
            }
            else static if (is(F : Matrix!(T, N), T, int N))
            {
                static assert (is(T == float));
                typeName = "mat" ~ N.to!string();
            }
            else static assert(0);

            result ~= `in ` ~ typeName ~ ` ` ~ __traits(identifier, field) ~ ";\n";
        }}
        return result;
    }
    enum string VertexAttributeShaderDeclarations = _get();
}


private void doEdit(T)(string name, T* memory)
{
    static if (is(T == float))
    {
        ImGui.InputFloat(name.toStringz, memory, 0.2, 1);
    }
    else static if (is(T == int))
    {
        ImGui.InputInt(name.toStringz, memory);
    }
    else static if (is(T : Vector!(float, N), int N))
    {
        mixin(`ImGui.SliderFloat` ~ N.to!string())(name.toStringz, cast(float*) memory, -5, 5);
    }
    else static if (is(T : Vector!(int, N), int N))
    {
        mixin(`ImGui.InputInt` ~ N.to!string())(name.toStringz, cast(int*) memory);
    }        
}

private void doColor(T)(string name, T* vector)
{
    static if (is(T : Vector!(float, N), int N) && (N == 3 || N == 4))
    {
        mixin(`ImGui.ColorEdit` ~ N.to!string())(name.toStringz, cast(float*) vector);
    }
    else static assert(0);
}

private void doRange(T)(string name, Range range, T* memory)
if (is(T == float))
{
    ImGui.SliderFloat(name.toStringz, memory, range.a, range.b);
}

struct UniformInfo(TUniforms)
{
    static foreach (field; TUniforms.tupleof)
    {
        mixin("auto " ~ __traits(identifier, field) ~ " = Uniform!(typeof(field))(__traits(identifier, field));");
    }

    void queryLocations(uint programId)
    {
        foreach (ref uniform; this.tupleof)
        {
            uniform.findLocation(programId);
            if (uniform.location < 0)
                g_Logger.log("Uniform " ~ uniform.name ~ " failed to find location.");
        }
    }
}

struct IndexBuffer
{
    import std.algorithm;
    uint id;

    void create()
    {
        glGenBuffers(1, &id);
    }

    void bind()
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
    }

    bool validateData(const ivec3[] indices, size_t vertexCount)
    {
        foreach (tri; indices)
        {
            if (tri.arrayof[].any!(i => i >= vertexCount))
                return false;
        }

        return true;
    }

    void setData(const ivec3[] indices)
    {
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * ivec3.sizeof, indices.ptr, GL_STATIC_DRAW);
    }
}

struct VertexBuffer(TAttribute)
{
    import std.conv : to;

    uint id;
    static Logger logger = Logger("VBO");

    void setup(uint programId)
    {
        template GlType(T)
        {
            static if (is(T == int))
                enum GlType = GL_INT;
            else static if (is(T == float))
                enum GlType = GL_FLOAT;
            else static if (is(T == bool))
                enum GlType = GL_BOOl;
            else static assert(0);
        } 

        uint location;
        static foreach (field; TAttribute.tupleof)
        {{
            location = glGetAttribLocation(programId, __traits(identifier, field));
            glEnableVertexAttribArray(location);

            alias F = typeof(field);
            
            static if (__traits(compiles, GlType!F)) // int, float or bool
            {
                glVertexAttribPointer(location, 1, GlType!F, GL_FALSE, TAttribute.sizeof, cast(void*) field.offsetof);
            }
            else static if (is(F : Vector!(T, N), T, int N))
            {
                glVertexAttribPointer(location, N, GlType!T, GL_FALSE, TAttribute.sizeof, cast(void*) field.offsetof);
            }
            else 
            {
                pragma(msg, F);
                static assert(0);
            }
        }}
    }

    void create()
    {
        glGenBuffers(1, &id);
    }

    void bind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    void setData(const TAttribute[] vertices)
    {
        glBufferData(GL_ARRAY_BUFFER, vertices.length * TAttribute.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }
}

void doImgui(TUniforms)(TUniforms* uniforms)
{
    static foreach (field; TUniforms.tupleof)
    {{
        enum name = __traits(identifier, field);
        auto memory = &__traits(child, uniforms, field);

        // Builtin property
        static if (__traits(getAttributes, field).length == 0)
        {
            // Do something?
            // logger.log(name ~ " Builtin");
        }
        else static foreach(attr; __traits(getAttributes, field))
        {
            // Don't break, allow more than one ways to change a variable.
            static if (is(attr == Edit))
            {
                doEdit(name, memory);
            }
            else static if (is(attr == Color))
            {
                doColor(name, memory);
            } 
            else static if (is(typeof(attr) == Range))
            {
                doRange(name, cast(Range) attr, memory);
            }
        }
    }}
}

struct ShaderProgram(TUniforms)
{
    import std.range;
    import std.algorithm;
    private static Logger logger = Logger("Shaders");

    UniformInfo!TUniforms uniformInfos;
    uint id;
    uint vertexShaderId;
    uint fragmentShaderId;

    void setUniforms(TUniforms* uniforms)
    {
        static foreach (field; TUniforms.tupleof)
        {{
            enum string name = __traits(identifier, field);
            __traits(getMember, uniformInfos, name).set(__traits(child, uniforms, field));
        }}
    }

    bool initialize(string vertexSource, string fragmentSource)
    {
        import shaderplayground.shaderloader;

        import std.file;
        if (!exists("temp")) mkdir("temp");
        write(`temp\shader.vertex`, vertexSource);
        write(`temp\shader.fragment`, fragmentSource);

        vertexShaderId = compileShader(vertexSource, ShaderStage.vertex); 
        fragmentShaderId = compileShader(fragmentSource, ShaderStage.fragment); 
        if (vertexShaderId == 0 || fragmentShaderId == 0) return false;

        id = linkShaders(vertexShaderId, fragmentShaderId);
        if (id == 0) return false;

        uniformInfos.queryLocations(id);
        errors(logger);
        if (logger.hasErrors) return false;

        return true;
    }

    void use()
    {
        glUseProgram(id);
    }
}

void setupVertexBuffer(TAttribute)(ref VertexBuffer!TAttribute buffer, uint programId, const TAttribute[] data)
{
    buffer.create();
    buffer.bind();
    buffer.setup(programId);
    buffer.setData(data);
}

void setupIndexBuffer(ref IndexBuffer buffer, const ivec3[] data)
{
    buffer.create();
    buffer.bind();
    buffer.setData(data);
}
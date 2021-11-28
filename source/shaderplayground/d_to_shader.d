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

enum IsEditable(alias t) = is(typeof(t) == Range) || is(t == Edit) || is(t == Color);

/// Whether to be included by default in the text of the corresponding shader type.
enum Fragment;
enum Vertex;

private string getTypeName(F)()
{
    string getTypePrefix(T)()
    {
        static if (is(T == float))
            return "";
        else static if (is(T == int))
            return "i";
        else static if (is(T == bool))
            return "b";
        else static assert(0);
    }

    static if (is(F == float) || is(F == int) || is(F == bool))
    {
        return F.stringof;
    }
    else static if (is(F : Vector!(T, N), T, int N))
    {
        return getTypePrefix!T ~ "vec" ~ N.to!string();
    }
    else static if (is(F : Matrix!(T, N), T, int N))
    {
        static assert (is(T == float));
        return "mat" ~ N.to!string();
    }
    else static assert(0);
}

private string getUniformTypeName(F)()
{
    import shaderplayground.texture : Texture2D, CubeMap;
    static if (is(F == Texture2D))
        return "sampler2D";
    else static if (is(F == CubeMap))
        return "samplerCube";
    else
        return getTypeName!F;
}

string VertexAttributeShaderDeclarations(TAttribute)()
{
    string result = "";
    static foreach (field; TAttribute.tupleof)
    {
        result ~= `in ` ~ getTypeName!(typeof(field)) ~ ` ` ~ __traits(identifier, field) ~ ";\n";
    }
    return result;
}

private string ShaderMarkedUniformDeclarations(TUniforms, alias shaderType)()
{
    string result = "";
    static foreach (field; TUniforms.tupleof)
    static foreach (uda; __traits(getAttributes, field))
    static if (is(uda == shaderType))
    {
        result ~= `uniform ` ~ getUniformTypeName!(typeof(field)) ~ ` ` ~ __traits(identifier, field) ~ ";\n";
    }
    return result;
}

string VertexMarkedUniformDeclarations(TUniforms)() { return ShaderMarkedUniformDeclarations!(TUniforms, Vertex); }
string FragmentMarkedUniformDeclarations(TUniforms)() { return ShaderMarkedUniformDeclarations!(TUniforms, Fragment); }

string VertexDeclarations(TAttribute, TUniforms)() 
{ 
    return VertexAttributeShaderDeclarations!TAttribute ~ VertexMarkedUniformDeclarations!TUniforms;
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

    void setData(const ivec3[] indices, uint mode = GL_STATIC_DRAW)
    {
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * ivec3.sizeof, indices.ptr, mode);
    }
}

struct VertexBuffer(TAttribute)
{
    import std.conv : to;

    uint id;
    static Logger logger = Logger("VBO");

    void setup(uint programId)
    {
        // template GlType(T)
        // {
        //     static if (is(T == int))
        //         enum GlType = GL_INT;
        //     else static if (is(T == float))
        //         enum GlType = GL_FLOAT;
        //     // else static if (is(T == bool))
        //     //     enum GlType = GL_BOOL;
        //     else static assert(0);
        // } 

        void GlVertexAttribPointer(T)(uint location, int n, int size, size_t offset)
        {
            static if (is(T == int))
                glVertexAttribIPointer(location, n, GL_INT, size, cast(void*) offset);
            else static if (is(T == float))
                glVertexAttribPointer(location, n, GL_FLOAT, GL_FALSE, size, cast(void*) offset);
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
                GlVertexAttribPointer!F(location, 1, TAttribute.sizeof, field.offsetof);
            }
            else static if (is(F : Vector!(T, N), T, int N))
            {
                GlVertexAttribPointer!T(location, N, TAttribute.sizeof, field.offsetof);
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

    void setData(const TAttribute[] vertices, uint mode = GL_STATIC_DRAW)
    {
        glBufferData(GL_ARRAY_BUFFER, vertices.length * TAttribute.sizeof, vertices.ptr, mode);
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
        uint textureUnitIndex = 0;
        static foreach (field; TUniforms.tupleof)
        {{
            enum string name = __traits(identifier, field);
            import shaderplayground.texture;

            static if (is(typeof(field) == Texture2D) || is(typeof(field) == CubeMap))
            {
                __traits(getMember, uniformInfos, name).set(__traits(child, uniforms, field), textureUnitIndex);
                textureUnitIndex++;
            }
            else
            {
                __traits(getMember, uniformInfos, name).set(__traits(child, uniforms, field));
            }
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

import std.json;
import std.stdio;

JSONValue uniformsToJson(T)(in T obj)
{
    JSONValue result;
    static foreach (field; T.tupleof)
    {
        static foreach (attribute; __traits(getAttributes, field))
        {
            static if (IsEditable!attribute)
            {
                static if (__traits(hasMember, typeof(field), "arrayof"))
                {
                    result[__traits(identifier, field)] = JSONValue(__traits(child, obj, field).arrayof);
                }
                else static if (is(typeof(field) : double) || is(typeof(field) == bool)) 
                {
                    result[__traits(identifier, field)] = JSONValue(__traits(child, obj, field));
                }
                else static assert(0);
            }
        }
    }
    return result;
}

void uniformsFromJson(T)(JSONValue json, out T obj)
{
    if (json.type != JSONType.object)
        return;

    static foreach (field; T.tupleof)
    {
        if (auto p = __traits(identifier, field) in json)
        {
            static foreach (attribute; __traits(getAttributes, field))
            {{
                static if (IsEditable!attribute)
                {
                    try 
                    {
                        static if (__traits(hasMember, typeof(field), "arrayof"))
                        {
                            auto t = p.array();
                            if (t.length == __traits(child, obj, field).arrayof.length)
                            {
                                foreach (index; 0 .. t.length)
                                    __traits(child, obj, field).arrayof[index] = t[index].get!(typeof(field.arrayof[0]));
                            }
                        }
                        else static if (is(typeof(field) : double) || is(typeof(field) == bool)) 
                        {
                            __traits(child, obj, field) = p.get!(typeof(field));
                        }
                        else static assert(0);
                    }
                    catch (JSONException exc)
                    {
                    }
                }
            }}
        }
    }
}

unittest
{
    struct U 
    {
        // Not serialized
        int a = 0;
        // Also not serialized
        bool b = true;
        
        @Range(0, 1)    float c = 0.5;
        @Edit           ivec2 d = ivec2(1, 2);
        @Color          vec3 e = vec3(1, 0.2, 0.5);
    }

    static assert(__traits(compiles, { U u; doImgui(&u); }));

    U u;
    JSONValue v = uniformsToJson(u);

    U u2;
    uniformsFromJson(v, u2);

    assert(u == u2);

    // writeln(u);
    // writeln(u2);
}

static import std.file;

void writeUniforms(T)(in T uniforms, string filename)
{
    JSONValue j = uniformsToJson(uniforms);
    std.file.write(filename, j.toPrettyString());
}

void tryReadUniforms(T)(out T uniforms, string filename)
{
    string jsonString;
    try jsonString = std.file.readText(filename);
    catch (Exception exc) {}
    uniformsFromJson(parseJSON(jsonString), uniforms);
}


import std.traits : fullyQualifiedName;

void save(T)(in T uniforms)
{
    enum name = fullyQualifiedName!T ~ ".json";
    writeUniforms(uniforms, name);
}

void load(T)(out T uniforms)
{
    enum name = fullyQualifiedName!T ~ ".json";
    tryReadUniforms(uniforms, name);
}




module shaderplayground.d_to_shader;

public import shaderplayground.shaderloader : ShaderStage;
import shaderplayground.shadercommon;
import imgui;

import std.conv : to;
import std.string : toStringz;
import std.stdio;

enum ValuesSetCallback;
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
    else static if (is(F : T[N], T, size_t N))
    {
        return getTypeName!T ~ `[` ~ N.to!string() ~ `]`;
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

private void doEdit(string name, T)(T* memory)
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

private void doColor(string name, T)(T* vector)
{
    static if (is(T : Vector!(float, N), int N) && (N == 3 || N == 4))
    {
        mixin(`ImGui.ColorEdit` ~ N.to!string())(name.ptr, cast(float*) vector);
    }
    else static assert(0);
}

private void doRange(string name, T)(Range range, T* memory)
if (is(T == float))
{
    ImGui.SliderFloat(name.toStringz, memory, range.a, range.b);
}

private template UniformInfoThing(alias field)
{
    static if (is(typeof(field) : T[N], T, size_t N))
    {
        static foreach (i; 0 .. N)
            mixin("auto " ~ __traits(identifier, field) ~ i.to!string ~ " = UniformLocation!(__traits(identifier, field) ~ `[` ~ i.to!string ~ `]`, T)();");
    }
    else
    {
        mixin("auto " ~ __traits(identifier, field) ~ " = UniformLocation!(__traits(identifier, field), typeof(field))();");
    }
}

private struct UniformInfo(TUniforms)
{
    static foreach (field; TUniforms.tupleof)
    {
        mixin UniformInfoThing!field;
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

private void doCorrectThingWithMemory(alias attr, string name, M)(M* memory)
{
    static if (is(M == T[N], T, size_t N))
    {
        static foreach (i; 0 .. N)
            doCorrectThingWithMemory!(attr, name ~ `[` ~ to!string(i) ~ `]`)(&(*memory)[i]);
    }
    else static if (is(attr == Edit))
    {
        doEdit!(name)(memory);
    }
    else static if (is(attr == Color))
    {
        doColor!(name)(memory);
    } 
    else static if (is(typeof(attr) == Range))
    {
        doRange!(name)(cast(Range) attr, memory);
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
            doCorrectThingWithMemory!(attr, name)(memory);
        }
    }}
    static foreach (member; __traits(allMembers, TUniforms))
    {{
        static if (is(typeof(__traits(getMember, TUniforms, member)) == function))
        {
            static foreach(attr; __traits(getAttributes, __traits(getMember, TUniforms, member)))
            {
                static if (is(attr == ValuesSetCallback))
                {
                    __traits(getMember, uniforms, member)();
                }
            }
        }
    }}
}

void setUniforms(TUniforms)(ref UniformInfo!TUniforms infos, TUniforms* uniforms)
{
    uint textureUnitIndex = 0;
    static foreach (field; TUniforms.tupleof)
    {{
        enum string name = __traits(identifier, field);
        import shaderplayground.texture;

        static if (is(typeof(field) == Texture2D) || is(typeof(field) == CubeMap))
        {
            __traits(getMember, infos, name).set(__traits(child, uniforms, field), textureUnitIndex);
            textureUnitIndex++;
        }
        else static if (is(typeof(field) == T[N], T, size_t N))
        {
            static foreach (i; 0 .. N)
                __traits(getMember, infos, name ~ i.to!string).set(__traits(child, uniforms, field)[i]);
        }
        else
        {
            __traits(getMember, infos, name).set(__traits(child, uniforms, field));
        }
    }}
}


struct ShaderProgram(TUniforms)
{
    private static Logger logger = Logger("Shaders");

    UniformInfo!TUniforms uniformInfos;
    uint id;
    uint vertexShaderId;
    uint fragmentShaderId;

    void setUniforms(TUniforms* uniforms)
    {
        .setUniforms(uniformInfos, uniforms);
    }

    bool initialize(S)(in S vertexSource, in S fragmentSource)
    {
        import shaderplayground.shaderloader;

        string[2] sources;
        // This has way more info.
        // TODO: Adjust the file and line received from open gl using info in here.
        // TODO: Watch the source file, adjust the source, if possible.
        // TODO: Figure out imports (remove duplicate imports).  
        static if (is(S == ShaderSource))
        {
            sources[0] = vertexSource.text;
            sources[1] = fragmentSource.text;
        }
        else
        {
            sources[0] = vertexSource;
            sources[1] = fragmentSource;
        }
        vertexShaderId = compileShader(sources[0], ShaderStage.vertex); 
        fragmentShaderId = compileShader(sources[1], ShaderStage.fragment); 
        if (vertexShaderId == 0 || fragmentShaderId == 0) return false;

        id = linkShaders(vertexShaderId, fragmentShaderId);
        if (id == 0) return false;

        uniformInfos.queryLocations(id);

        return !logger.hasErrors;
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


private JSONValue GetJsonValue(F)(in F field)
{
    static if (is(F == T[N], T, size_t N))
    {
        JSONValue[] result;
        foreach (i; 0 .. N)
            result ~= GetJsonValue!T(field[i]);
        return JSONValue(result);
    }
    else static if (__traits(hasMember, F, "arrayof"))
    {
        return JSONValue(field.arrayof);
    }
    else static if (is(F : double) || is(F == bool)) 
    {
        return JSONValue(field);
    }
    else static assert(0);
}

JSONValue uniformsToJson(T)(in T obj)
{
    JSONValue result;
    static foreach (field; T.tupleof)
    {
        static foreach (attribute; __traits(getAttributes, field))
        {
            static if (IsEditable!attribute)
            {
                result[__traits(identifier, field)] = GetJsonValue(__traits(child, obj, field));
            }
        }
    }
    return result;
}


private void SetJsonValue(F)(const(JSONValue)* value, out F field)
{
    static if (__traits(hasMember, F, "arrayof"))
    {
        auto t = value.array();
        if (t.length == field.arrayof.length)
        {
            foreach (index; 0 .. t.length)
                field.arrayof[index] = t[index].get!(typeof(field.arrayof[0]));
        }
    }
    else static if (is(F : T[N], T, size_t N))
    {
        auto t = value.array();
        import std.algorithm : min;
        foreach (index; 0 .. min(t.length, field.length))
            SetJsonValue(&t[index], field[index]);
    }
    else static if (is(typeof(field) : double) || is(typeof(field) == bool)) 
    {
        field = value.get!(typeof(field));
    }
    else static assert(0);
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
                        SetJsonValue(p, __traits(child, obj, field));
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

enum UniformsDefaultFileName(TUniforms) = fullyQualifiedName!TUniforms ~ ".json";

// NOTE:
// It's funny, how the more abstractions you roll out, the more abstract
// your namings become. `save` is just convenient to use, and it's clear what it does
// from the usage. You want it to be simple, but at the same time, it hides the
// complexity, about which you will still probably have to know if you are to learn the system.
// I'm not sure whether this tendency is a good or a bad thing, but it comes naturally,
// as I have noticed.

/// Save the uniforms to the default file.
void save(T)(in T uniforms)
{
    writeUniforms(uniforms, UniformsDefaultFileName!T);
}

/// Try to read the uniforms from the default file.
void load(T)(out T uniforms)
{
    tryReadUniforms(uniforms, UniformsDefaultFileName!T);
}


import std.algorithm : count;

struct ShaderData
{
    /// The source code
    string source;
    const (ShaderImport*)[] imports;
    /// The full name of the source file that this can be found in.
    /// Currently, I assume all shaders are defined in D source files as strings.
    string file;
    /// The line number of where it was defined.
    size_t line;
}

/// Shader source for a particular stage of the OpenGL pipeline.
struct ShaderSource
{
    ShaderData data;
    alias data this;
    
    ShaderStage stage;
    /// Autogenerated things like the attribute bindings or the uniforms.
    string declarations;
    /// The preamble
    string header;
    
    const:

    /// Returns the source code of this shader source, 
    /// including the header, the annotations and and all of its imports.
    string text()
    {
        string result = header;
        result ~= declarations;
        foreach (i; imports)
            result ~= i.text();
        result ~= source;
        return result;
    }

    /// Returns the length, discluding source and the imports
    size_t getAnnotationLineCount()
    {
        return 1 + declarations.count('\n');
    }
}

/// Source code imported into other shaders.
/// May recursively import other imports.
struct ShaderImport
{
    ShaderData data;
    alias data this;

    const:
    /// Returns the source code of this import and all of its imports.
    string text()
    {
        string result = "";
        foreach (i; imports)
            result ~= i.text();
        result ~= source;
        return result;
    }

    /// Returns the length, discluding source and the imports
    size_t getAnnotationLineCount()
    {
        return 0;
    }
}

// size_t getLineCount(const (ShaderImport*)[] imports)
// {
//     return imports.map!(a => a.getLineCount()).fold!(`a + b`)(0UL);
// }

struct ImportPositionResult
{
    const(ShaderData)* shaderData;
    int lineOffsetWithinImport;
}

/// See `getShaderDataAtLine`.
/// The only difference is that the total line count of the dependencies is returned,
/// if the line is not within the given import or its imports.
private ImportPositionResult getShaderDataAtLineInternal(const(ShaderData)* data, int line)
{
    int lineCount = 0;

    foreach (imp; data.imports)
    {
        auto recursionResult = getShaderDataAtLineInternal(&(imp.data), line);
        if (recursionResult.shaderData)
            return recursionResult;

        assert(recursionResult.lineOffsetWithinImport >= 0);
        lineCount += recursionResult.lineOffsetWithinImport;
        int numLinesInSource = cast(int) imp.source.count('\n');

        if (lineCount + numLinesInSource > line)
            return typeof(return)(&(imp.data), line - lineCount);

        lineCount += numLinesInSource;
    }

    return typeof(return)(null, lineCount);
}

/// Essentially walks the import tree of the shader source 
/// and returns a pointer to the import within which the current line
/// of the shader source is. If the line is within the source code of the
/// `shaderSource`, then that is returned instead, and the offset is relative to 
/// that source code (within the `source` field, if it points to the header
/// or the declarations it will be negative).
ImportPositionResult getShaderDataAtLine(T)(const ref T shaderSource, int lineOffsetWithinSource)
{
    lineOffsetWithinSource -= cast(int) shaderSource.getAnnotationLineCount();
    auto result = getShaderDataAtLineInternal(&(shaderSource.data), lineOffsetWithinSource);
    if (result.shaderData is null)
    {
        result.lineOffsetWithinImport = lineOffsetWithinSource - result.lineOffsetWithinImport;
        result.shaderData = &(shaderSource.data);
    }
    return result;
}
unittest
{
    ShaderImport i0 = createShaderImport("\n");
    ShaderImport i1 = createShaderImport("\n", [&i0]);
    ShaderSource s0 = createShaderSource("\n\n", ShaderStage.vertex, "\n", [&i1]);

    // So its like this
    // s0 header, 1 line
    // s0 declarations, 1 line
    // i0, 1 line
    // i1, 1 line
    // s0 source, 2 lines
    
    // header + declarations
    assert(s0.getAnnotationLineCount() == 2);

    {
        auto imp = getShaderDataAtLine(s0, 2);
        // writeln(imp);
        assert(imp.shaderData == &(i0.data));
        assert(imp.lineOffsetWithinImport == 0);
    }
    {
        auto imp = getShaderDataAtLine(s0, 3);
        // writeln(imp);
        assert(imp.shaderData == &(i1.data));
        assert(imp.lineOffsetWithinImport == 0);
    }
    {
        auto imp = getShaderDataAtLine(s0, 5);
        // writeln(imp);
        assert(imp.shaderData == &(s0.data));
        assert(imp.lineOffsetWithinImport == 1);
    }
}


ShaderSource createShaderSource(
    string source,
    ShaderStage stage,
    string declarations = "",
    const (ShaderImport*)[] imports = null,
    string header = SHADER_HEADER,
    string file = __FILE_FULL_PATH__,
    size_t line = __LINE__)
{
    ShaderSource result;

    import std.string : replace;
    result.source = source.replace("\r\n", "\n");
    result.stage = stage;
    result.declarations = declarations;
    result.imports = imports;
    result.header = header;
    result.file = file;
    result.line = line;

    return result;
}

ShaderImport createShaderImport(
    string source,
    const ShaderImport*[] imports = null,
    string file = __FILE_FULL_PATH__,
    size_t line = __LINE__)
{
    import std.string : replace;
    return ShaderImport(ShaderData(source.replace("\r\n", "\n"), imports, file, line));
}

private struct SourceInfo
{
    ShaderSource source;
    string declarationString;
    uint id;
    bool isCompiled;
    void delegate(in SourceFilesHotreloadProvider, uint indexChanged)[] changedSubscribers;
}

// I might be overcomplicating this.
struct SourceFilesHotreloadProvider
{
    import shaderplayground.shaderloader;
    import std.algorithm;
    import std.string;
    import std.range;
    import std.array;

    SourceInfo[] shaderSourceInfos;

    // uint addOrFindShaderSource(in ShaderSource source)
    // {
    //     foreach (ref info; shaderSourceInfos)
    //     {
    //         if (source.file == info.source.file && 
    //     }
    // }

    uint addShaderSource(ShaderSource source)
    {
        // The file must exist
        assert(source.file != null, source.file);

        SourceInfo info;
        info.source = source;
        
        auto file = File(source.file, "r");
        scope(exit) file.close();
        auto lines = file.byLine().drop(source.line - 1);

        // We'll be doing the hotreload relative to this declaration.
        assert(lines.front.chomp[$ - 2 .. $] == "q{", 
            "Please use token strings with the hotreload feature.");
        info.declarationString = lines.front.idup;

        info.id = glCreateShader(shaderStageToGLenum(info.source.stage));
        // This needs to be initialized only once.
        recompileShaderSource(&info);
        shaderSourceInfos ~= info;

        return cast(uint) shaderSourceInfos.length - 1;
    }

    void recompileShaderSource(SourceInfo* info)
    {
        // writeln("Recompiling ", info.source.file);
        string text = info.source.text;
        const char* csource = text.ptr;
        GLint length = cast(GLint) text.length;
        glShaderSource(info.id, 1, &csource, &length);
        glCompileShader(info.id);

        info.isCompiled = checkShaderCompiled(info.id);

        LogBuffer buffer;
        auto log = getCompilationLog(buffer, info.id);
        auto processedLog = appender!string;
        processedLog.reserve(log.length);

        import std.typecons : Yes;
        import std.format;
        foreach (line; splitter!(`a == b`, Yes.keepSeparators)(log, "\n"))
        {
            if (!startsWith(line, "0("))
            {
                processedLog ~= line;
                continue;
            }

            auto closingParenIndex = 2 + countUntil(line[2..$], ')');
            auto numberString = line[2 .. closingParenIndex];
            int lineOffsetWithinShaderText = to!int(numberString) - 1;

            // Calculate the position withint the shader source code 
            // and the referenced shader source or import.
            auto positionResult = getShaderDataAtLine(info.source, lineOffsetWithinShaderText);

            processedLog ~= positionResult.shaderData.file;
            processedLog ~= '(';
            // Output the offset in the actual source code file. 
            formattedWrite(processedLog, "%d", positionResult.lineOffsetWithinImport + positionResult.shaderData.line);
            processedLog ~= ')';
            processedLog ~= line[closingParenIndex + 1 .. $];
        }

        if (log.length > 0)
            writeln(processedLog[]);

        // debug
        // {
        //     import std.path;
        //     auto file = File(baseName(info.source.file).setExtension("") ~ info.id.to!string ~ ".glsl", "w");
        //     file.write(info.source.text);
        //     file.close();
        // }
    }

    /// Will recompile the shaders the sources of which are in the file by `fullNormalizedPath`,
    /// if their text changed. By the means of callbacks, all shader programs dependent on that
    /// will presumably recompile too.
    void onFileModified(string fullNormalizedPath)
    {
        foreach (index, ref info; shaderSourceInfos)
        {
            // TODO: reload when the imports change too.
            // It's going to mean checking the paths of the import pointers, going ahead and mutating them.
            // Then we'll also have to mark the pointers that we have modified this time.
            // The annoying thing about this is that the imports will have to be __gshared, while the 
            // pointers to them can no longer be const, which is fine, I guess.
            if (info.source.file != fullNormalizedPath)
                continue;
            // 1. Recursively iterate imports.
            // 2. Skip marked imports.
            // 3. Update each of the imports.
            // 4. Recompile the sources after that.
            // Also, since we mark what we compile, might as well rebuild recursively and recompile at the end of the loop
            // to not waste work if a bunch of files were to be changed at once (the program is recompiled on every shader
            // change, so that means duplicate compilation, duplicate linking, duplicate errors, etc.)
            // I don't want to double down on the import system though, because I'm not even using it that much.

            // TODO: in order to not open this thing twice, should probably do a local associative array,
            // to map paths to files then close them all at once after the loop.
            auto file = File(fullNormalizedPath, "r");
            scope(exit) file.close();
            auto lines = file.byLine();

            if (lines.empty)
                continue;

            size_t lineCountUntilSource = 0;
            // findSkip cannot deduce arguments
            while (true)
            {
                auto front = lines.front;
                lines.popFront();

                if (front == info.declarationString)
                    break;
                
                lineCountUntilSource++;
                
                if (!lines.empty)
                    continue;

                // TODO: maybe only the declaration changed while the line is the same
                writeln("Please do not modify the declaration of the watched source. ", fullNormalizedPath);
                return;
            }
            info.source.line = lineCountUntilSource;

            int numParens = 0;
            auto buffer = appender!string;
            
            // This is the new line after the token string 
            buffer ~= '\n';

            outer: foreach (line; lines)
            {
                foreach (ch; line)
                {
                    switch (ch)
                    {
                        case '{':
                            numParens++;
                            goto default;
                        case '}':
                            numParens--;
                            if (numParens < 0)
                                break outer;
                            goto default;
                        default:
                            buffer ~= ch;
                            continue;
                    }
                }
                buffer ~= "\n";
            }

            string newText = buffer[];

            if (newText != info.source.source)
            {
                // writeln("Source changed. ", fullNormalizedPath);
                info.source.source = newText;
                recompileShaderSource(&info);

                foreach (s; info.changedSubscribers)
                    s(this, cast(uint) index);
            }
        }
    }
}


struct HotreloadShaderProgram(TUniforms)
{
    import shaderplayground.shaderloader;
    import std.algorithm;

    UniformInfo!TUniforms uniformInfos;
    // Indices into the provider's 
    uint[] shaderSourceIndices;
    uint id = cast(uint) -1;

    void delegate(HotreloadShaderProgram program)[] programRelinkedCallbacks;

    bool isPrimed() { return id != cast(uint) -1; }
    void initialize() { id = glCreateProgram(); }

    private void recompile(in SourceFilesHotreloadProvider provider, uint indexChanged)
    {
        size_t indexOfChangedShaderSource = shaderSourceIndices.countUntil(indexChanged);
        assert(indexOfChangedShaderSource < shaderSourceIndices.length, 
            "This means we have added the callback to a wrong thing.");
        
        // glDetachShader(id, provider.shaderSourceInfos[indexOfChangedShaderSource].id);

        if (shaderSourceIndices.all!(i => provider.shaderSourceInfos[i].isCompiled))
        {
            linkProgram();
        }
    }

    void linkProgram()
    {
        glLinkProgram(id);
        if (checkShaderProgramLinked(id))
        {
            uniformInfos.queryLocations(id);
            foreach (c; programRelinkedCallbacks)
                c(this);
        }

        LogBuffer buffer;
        // AFAIK this doesn't contain line info.
        auto log = getLinkingLog(buffer, id);
        if (log.length > 0)
            writeln(log);
    }

    void addRelinkedCallback(void delegate(typeof(this)) callback)
    {
        programRelinkedCallbacks ~= callback;
    }

    void setUniforms(TUniforms* uniforms)
    {
        .setUniforms(uniformInfos, uniforms);
    }

    void use()
    {
        assert(isLinked());
        glUseProgram(id);
    }

    /// Convenience property 
    bool isLinked() const
    {
        return checkShaderProgramLinked(id);
    }
}

void addSource(Program)(ref Program shaderProgram, 
    SourceFilesHotreloadProvider* provider, uint shaderSourceIndex)
{
    shaderProgram.shaderSourceIndices ~= shaderSourceIndex;
    auto info = &provider.shaderSourceInfos[shaderSourceIndex];

    // TODO: This is potentially dangerous, the subscribers need to be detached when the program is deleted.
    auto p = &shaderProgram;
    provider.shaderSourceInfos[shaderSourceIndex].changedSubscribers ~= &p.recompile;
    glAttachShader(shaderProgram.id, info.id);
}

void addSourcesGlobally(T)(ref T program, ShaderSource[] sources...)
{
    foreach (s; sources)
        addSourcesGlobally(program, s);
}

uint addSourcesGlobally(T)(ref T program, ShaderSource source)
{
    import shaderplayground.globals : g_SourceFilesHotreloadProvider;
    uint index = g_SourceFilesHotreloadProvider.addShaderSource(source);
    addSource(program, &g_SourceFilesHotreloadProvider, index);
    return g_SourceFilesHotreloadProvider.shaderSourceInfos[index].id;
}

/// A convenience thing that initializes the program globally, if not initialized.
bool reinitializeHotloadShaderProgram(T)(ref T program, ShaderSource[] sources...)
{
    // TODO: reattach handlers if inited the second time.
    // TODO: detach handlers if terminated, but keep the shaders around.
    if (!program.isPrimed)
    {
        program.initialize();
        addSourcesGlobally(program, sources);
        program.linkProgram();

        import shaderplayground.shaderloader;
        // This is only called at initialization.
        // If the program does not link initially, all draw calls break and give errors,
        // which is why it's helpful to stop the exection and fix the shaders first.
        assert(program.isLinked());

        return true;
    }
    return false;
}
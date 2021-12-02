module shaderplayground.d_to_shader;

public import shaderplayground.shaderloader : ShaderStage;
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
        else
        {
            __traits(getMember, infos, name).set(__traits(child, uniforms, field));
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


import std.algorithm;
import std.range;

struct ShaderData
{
    string source;
    const (ShaderImport*)[] imports;
    string file;
    size_t line;
}

struct ShaderSource
{
    ShaderData data;
    alias data this;
    
    ShaderStage stage;   
    string declarations;
    string header;
    
    const:
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

struct ShaderImport
{
    ShaderData data;
    alias data this;

    const:
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
    const (ShaderData)* shaderData;
    int lineOffsetWithinImport;
}

private ImportPositionResult getShaderDataAtLineInternal(in ShaderData data, int line)
{
    int lineCount = 0;

    foreach (imp; data.imports)
    {
        auto recursionResult = getShaderDataAtLineInternal(imp.data, line);
        if (recursionResult.shaderData)
            return recursionResult;

        assert(recursionResult.lineOffsetWithinImport >= 0);
        lineCount += recursionResult.lineOffsetWithinImport;
        int numLinesInSource = cast(int) imp.source.count('\n');

        if (lineCount + numLinesInSource > line)
            return typeof(return)(&imp.data, line - lineCount);

        lineCount += numLinesInSource;
    }

    return typeof(return)(null, lineCount);
}
ImportPositionResult getShaderDataAtLine(T)(in T source, int line)
{
    line -= cast(int) source.getAnnotationLineCount();
    auto result = getShaderDataAtLineInternal(source.data, line);
    if (result.shaderData is null)
    {
        result.lineOffsetWithinImport = line - result.lineOffsetWithinImport;
        result.shaderData = &source.data;
    }
    return result;
}
unittest
{
    ShaderImport i0 = createShaderImport("\n");
    ShaderImport i1 = createShaderImport("\n", [&i0]);
    ShaderSource s0 = createShaderSource("\n\n", ShaderStage.vertex, "", [&i1]);

    // So its like this
    // s0 header, 1 line
    // i0, 1 line
    // i1, 1 line
    // s0 source, 2 lines
    {
        auto imp = getShaderDataAtLine(s0, 1);
        assert(imp.shaderData == &i0);
        assert(imp.lineOffsetWithinImport == 0);
    }
    {
        auto imp = getShaderDataAtLine(s0, 2);
        writeln(imp);
        assert(imp.shaderData == &i1);
        assert(imp.lineOffsetWithinImport == 0);
    }
    {
        auto imp = getShaderDataAtLine(s0, 4);
        writeln(imp);
        assert(imp.shaderData == null);
        assert(imp.lineOffsetWithinImport == 1);
    }
    assert(s0.getAnnotationLineCount() == 1);
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
        writeln("Recompiling ", info.source.file);
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

            auto positionResult = getShaderDataAtLine(info.source, lineOffsetWithinShaderText);

            processedLog ~= positionResult.shaderData.file;
            processedLog ~= '(';
            formattedWrite(processedLog, "%d", positionResult.lineOffsetWithinImport + positionResult.shaderData.line);
            processedLog ~= ')';
            processedLog ~= line[closingParenIndex + 1 .. $];
        }

        if (log.length > 0)
            writeln(processedLog[]);

        debug
        {
            import std.path;
            auto file = File(baseName(info.source.file).setExtension("") ~ info.id.to!string ~ ".glsl", "w");
            file.write(info.source.text);
            file.close();
        }
    }

    void fileModified(string fullNormalizedPath)
    {
        foreach (index, ref info; shaderSourceInfos)
        {
            if (info.source.file != fullNormalizedPath)
                continue;

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
        glUseProgram(id);
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

bool reinitializeHotloadShaderProgram(T)(ref T program, ShaderSource[] sources...)
{
    if (!program.isPrimed)
    {
        program.initialize();
        addSourcesGlobally(program, sources);
        program.linkProgram();

        import shaderplayground.shaderloader;
        assert(checkShaderProgramLinked(program.id));
        return true;
    }
    return false;
}
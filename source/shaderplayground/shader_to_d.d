module shaderplayground.shader_to_d;
import shaderplayground.shadercommon;

enum Qualifier
{
    In = "in", 
    Out = "out", 
    Uniform = "uniform" 
}

// string QualifierToString(Qualifier qualifier)
// {
//     final switch (qualifier)
//     {
//     case Qualifier.inQualifier: return "in";
//     case Qualifier.outQualifier: return "out";
//     case Qualifier.uniformQualifier: return "uniform";
//     }
// }

struct CTVariable
{
    int location;
    Qualifier qualifier;
    string type;
    string name;
}

import std.ascii;
import std.range;
import std.string : startsWith;

string tryMatchIdentifier(ref string source)
{
    auto s = source;
    if (s.empty) return null;
    if (!isAlpha(s.front) && s.front != '_') return null;
    s.popFront();
    while (!s.empty && (isAlphaNum(s.front) || s.front == '_'))
    {
        s.popFront();
    }
    string ident = source[0..$-s.length];
    source = s;
    return ident;
}

unittest
{
    string s;
    s = "123";
    assert(tryMatchIdentifier(s) == null);
    assert(s == "123");
    s = "abc";
    assert(tryMatchIdentifier(s) == "abc");
    assert(s == "");
    s = "_ab1";
    assert(tryMatchIdentifier(s) == "_ab1");
    assert(s == "");
    s = " a1";
    assert(tryMatchIdentifier(s) == null);
    assert(s == " a1");
}

bool tryMatchUint(ref string source, out uint number)
{
    auto s = source;
    while (!s.empty && s.front >= '0' && s.front <= '9')
    {
        s.popFront();
    }
    if (s.length == source.length) return false;

    import std.conv : to;
    number = to!uint(source[0..$-s.length]);
    source = s;
    return true;
}
unittest
{
    string s;
    uint number;
    s = "123";
    assert(tryMatchUint(s, number));
    assert(number == 123);
    assert(s == "");
    s = "a";
    assert(!tryMatchUint(s, number));
    assert(s == "a");
}

void skipWhitespace(ref string source)
{
    while (!source.empty && isWhite(source.front))
    {
        source.popFront();
    }
}
unittest
{
    string s;
    s = "  a";
    s.skipWhitespace();
    assert(s == "a");
    s.skipWhitespace();
    assert(s == "a");
}

string tryMatchEitherOf(ref string input, string[] options)
{
    foreach (option; options)
    {
        if (input.startsWith(option))
        {
            input = input[option.length..$];
            return option;
        }
    }
    return null;
}
unittest
{
    string s;
    s = "123";
    assert(tryMatchEitherOf(s, ["123", "234"]) == "123");
    assert(s == "");
    s = "234";
    assert(tryMatchEitherOf(s, ["123", "234"]) == "234");
    assert(s == "");
    assert(tryMatchEitherOf(s, ["123"]) == null);
    assert(s == "");
}

bool tryMatch(string str, ref string input)
{
    if (input.startsWith(str))
    {
        input = input[str.length..$];
        return true;
    }
    return false;
}
unittest
{
    string s;
    s = "1231";
    assert(tryMatch("123", s));
    assert(s == "1");
}

bool tryMaybeMatchLayout(ref string source, out int location)
{
    location = -1;
    auto s = source;
    s.skipWhitespace();
    if (!tryMatch("layout", s))     { source = s; return true; }
    s.skipWhitespace();
    if (!tryMatch("(", s))          return false;
    s.skipWhitespace();
    if (!tryMatch("location", s))   return false;
    s.skipWhitespace();
    if (!tryMatch("=", s))          return false;
    s.skipWhitespace();
    
    uint number;
    if (!tryMatchUint(s, number))   return false;
    location = cast(int) number;

    s.skipWhitespace();
    if (!tryMatch(")", s))          return false;

    source = s;
    return true;
}
unittest
{
    string s;
    int location;
    s = " layout";
    assert(!tryMaybeMatchLayout(s, location));
    assert(s == " layout");
    assert(location == -1);

    s = "1";
    assert(tryMaybeMatchLayout(s, location));
    assert(s == "1");
    assert(location == -1);

    s = "layout (location = 4)";
    assert(tryMaybeMatchLayout(s, location));
    assert(s == "");
    assert(location == 4);
}

bool tryMatchVariable(string input, out CTVariable variable)
{
    if (!tryMaybeMatchLayout(input, variable.location)) return false;

    input.skipWhitespace();
    variable.qualifier = cast(Qualifier) tryMatchEitherOf(input, ["in", "out", "uniform"]);
    if (variable.qualifier is null) return false;
    
    if (!tryMatch(" ", input)) return false;
    input.skipWhitespace();

    variable.type = tryMatchIdentifier(input);
    if (variable.type is null) return false;
    if (!tryMatch(" ", input)) return false;
    input.skipWhitespace();

    variable.name = tryMatchIdentifier(input);
    if (variable.name is null) return false;

    return true;
}
unittest
{
    auto input = "layout (location = 7) in a b";
    CTVariable variable;
    assert(tryMatchVariable(input, variable));
    assert(variable.location == 7);
    assert(variable.qualifier == Qualifier.In);
    assert(variable.type == "a");
    assert(variable.name == "b");
}

/// Takes in a `bool function(TIn, out TOut)` and an input range.
/// Constructs a new input range, which consists of elements of type TOut.
/// Only those elements are kept for which the function returned true.
template mapFilter(alias func)
{
    template mapFilter(R) if (isInputRange!R)
    {
        import std.traits;

        static if (__traits(isTemplate, func))
            // template with one required template argument
            // TODO: check if the template can be instantiated with exactly 1 argument before doing this.
            alias _func = func!(ElementType!R);
        else 
            alias _func = func;

        static assert(isCallable!_func, "The provided function must be a callable object");
        static assert(
            ParameterStorageClassTuple!_func[1] == ParameterStorageClass.out_, 
            "The second parameter must be an out parameter");
        
        auto mapFilter(R range)
        { 
            return MapFilter(range);
        }

        struct MapFilter
        {
            R range;
            Unqual!(Parameters!_func[1]) front;

            bool empty;

            this(R range) 
            { 
                this.range = range; 
                popFront(); 
            }
            
            void popFront() 
            {
                while (!range.empty)
                {
                    const rangeFront = range.front;
                    range.popFront();
                    // front gets value via `out`
                    if (_func(rangeFront, front)) return;
                }
                empty = true;
            }
        }
    }
}
unittest
{
    static bool thing(int source, out uint output)
    {
        if (source >= 0)
        {
            output = cast(uint) source;
            return true;
        }
        return false;
    }
    import std.algorithm.comparison : equal;
    auto result = [1, 2, -1, -2].mapFilter!(thing);
    assert(equal(result, [1u, 2u]));
}
unittest
{
    enum works = __traits(compiles, [1, 2, 3, 4].mapFilter!((a, out uint b) { b = a; return true; }));
    assert(works);
}

auto getVariables(string input)
{
    import std.range;
    import std.algorithm;
    import std.string : lineSplitter;

    return input.lineSplitter()
         .mapFilter!tryMatchVariable
         .array();
}


struct VertexAttribute(CTVariable[] VertexAttribInfos)
{
    static foreach (Info; VertexAttribInfos)
    {
        mixin(Info.type ~ " " ~ Info.name ~ ";");
    }
}

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

static struct VertexBuffer(CTVariable[] vertexAttributeInfos)
{
    import std.conv : to;

    alias Vertex = VertexAttribute!(vertexAttributeInfos);
    static foreach (info; vertexAttributeInfos)
    {
        mixin(`auto ` ~ info.name ~ ` = VertexAttributeInfo!(` ~ info.type ~ `, ` ~ info.location.to!string() ~ `)("` ~ info.name ~ `");`);
    }

    uint id;

    static Logger logger = Logger("VBO");

    void create()
    {
        glGenBuffers(1, &id);
    }

    void bind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    void setupAttributes()
    {
        uint offset = 0;
        static foreach (info; vertexAttributeInfos)
        {
            mixin(info.name ~ `.setupInBuffer(Vertex.sizeof, offset);`);
        }
    }

    void queryLocations(uint programId)
    {
        static foreach (info; vertexAttributeInfos)
        static if (info.location == -1)
        {
            mixin(info.name ~ `.findLocation(programId);
                if (` ~ info.name ~ `.location < 0)
                    logger.error("Vertex attribute '` ~ info.name ~ `' failed to find location");`);
            errors(info.name);
        }
    }

    void setData(Vertex[] vertices)
    {
        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }
}

template ShaderProgramInfo(string vertexSource, string fragmentSource)
{
    import std.range;
    import std.algorithm;
    
    enum vertexVariables = getVariables(vertexSource);
    enum fragmentVariables = getVariables(fragmentSource);
    enum allVariables = vertexVariables ~ fragmentVariables;
    enum uniforms = allVariables.filter!(v => v.qualifier == Qualifier.Uniform).uniq!`a.name == b.name`().array();
    enum vertexAttributeInfos = vertexVariables.filter!(v => v.qualifier == Qualifier.In).array();
    
    struct ShaderProgram
    {
        static foreach (uniform; uniforms)
        {
            mixin(`auto ` ~ uniform.name ~ ` = Uniform!(` ~ uniform.type ~ `)("` ~ uniform.name ~ `");`);
        }

        uint id;
        uint vertexShaderId;
        uint fragmentShaderId;

        static Logger logger = Logger("Shaders");

        bool initialize()
        {
            import shaderplayground.shaderloader;

            vertexShaderId = compileShader(vertexSource, ShaderStage.vertex); 
            fragmentShaderId = compileShader(fragmentSource, ShaderStage.fragment); 
            if (vertexShaderId == 0 || fragmentShaderId == 0) return false;

            id = linkShaders(vertexShaderId, fragmentShaderId);
            if (id == 0) return false;

            queryLocations();
            errors(logger);
            if (logger.hasErrors) return false;

            return true;
        }

        void queryLocations()
        {
            static foreach (uniform; uniforms)
            static if (uniform.location == -1)
            {
                mixin(uniform.name ~ `.findLocation(id);
                    if (` ~ uniform.name ~ `.location < 0)
                        logger.error("Uniform '` ~ uniform.name ~ `' failed to find location");`);
            }
        }

        void use()
        {
            glUseProgram(id);
        }
    }
}
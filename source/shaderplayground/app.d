module shaderplayground.app;
import std.string;
import dlib.math; 

immutable string vertexShaderText = q{
    #version 330 core

    layout (location = 0) in vec3 aColor;
    layout (location = 1) in vec2 aPosition;

    uniform mat4 uModelViewProjection;

    out vec3 vColor;
    
    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition, 0.0, 1.0);
        vColor = aColor;
    }
};

immutable string fragmentShaderText = q{
    #version 330 core

    in vec3 vColor;
    layout(location = 0) out vec4 fragColor;

    void main()
    {
        fragColor = vec4(vColor, 1.0);
    }
};


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

/// Checks for `bool function(TIn, out TOut)`.
template isMapFunc(alias Func)
{
    import std.traits : ParameterStorageClassTuple, ParameterStorageClass, ReturnType;
    alias type = typeof(Func);
    alias psct = ParameterStorageClassTuple!type;
    enum isMapFunc = psct[1] == ParameterStorageClass.out_ && is(ReturnType!Func == bool);
}

/// Takes in a `bool function(TIn, out TOut)` and an input range.
/// Constructs a new input range, which consists of elements of type TOut.
/// Only those elements are kept for which the function returned true.
template mapFilter(alias Func)
if (isMapFunc!Func)
{
    import std.traits : Parameters;
    alias TOut = Parameters!(typeof(Func))[1];

    // TODO: deduce T from Func
    auto mapFilter(R)(R range)
    if (isInputRange!R)
    {
        return MapFilter!(R)(range);
    }

    struct MapFilter(R)
    {
        R range;
        TOut front;
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
                if (Func(rangeFront, front)) return;
            }
            empty = true;
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

auto getVariables(string input)
{
    import std.range;
    import std.algorithm;
    import std.string : lineSplitter;

    return input.lineSplitter()
         .mapFilter!tryMatchVariable
         .array();
}

struct VertexAttributeInfo(T, int loc)
{
    import bindbc.opengl;

    static if (loc == -1)
    {
        int location;
       
        void findLocation(int programId)
        {
            location = glGetAttribLocation(programId, name);
        }
    }
    else
        enum location = loc;

    string name;
    
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
    } 
}

void errors(string name)
{
    import shaderplayground.logger;
    import std.conv : to;
    import bindbc.opengl;
    
    GLenum err;
    while((err = glGetError()) != GL_NO_ERROR)
    {
        auto logger = Logger(name);
        logger.error(err.to!string());
    }
}

struct Uniform(T)
{
    string name; 
    int location = -1;

    import bindbc.opengl;

    void findLocation(uint programId)
    {
        location = glGetUniformLocation(programId, name.toStringz());
    }

    void set(T value)
    {
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
        import std.conv : to;

        static if (is(T == float) || is(T == int) || is(T == uint))
        {
            mixin(`glUniform1` ~ TypeSuffix!(T) ~ `(location, value);`);
        }
        else static if (is(T : Vector!Args, Args...))
        {
            mixin(`glUniform` ~ Args[1].to!string() ~ TypeSuffix!(Args[0]) ~ `v(location, 1, value.arrayof.ptr);`);
        }
        else static if (is(T : Matrix!Args, Args...))
        {
            mixin(`glUniformMatrix` ~ Args[1].to!string() ~ TypeSuffix!(Args[0]) ~ `v(location, 1, GL_FALSE, value.arrayof.ptr);`);
        }
        errors("Uniform");
    }
}

struct VertexAttribute(CTVariable[] VertexAttribInfos)
{
    static foreach (Info; VertexAttribInfos)
    {
        mixin(Info.type ~ " " ~ Info.name ~ ";");
    }
}


static struct VertexBuffer(CTVariable[] vertexAttributeInfos)
{
    import std.conv : to;
    import shaderplayground.logger;
    import bindbc.opengl;

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
        bind();

        uint offset = 0;
        static foreach (info; vertexAttributeInfos)
        {
            mixin(info.name ~ `.setupInBuffer(Vertex.sizeof, offset);`);
        }
    }

    void bind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    void queryLocations(uint programId)
    {
        static foreach (info; vertexAttributeInfos)
        static if (info.location == -1)
        {
            mixin(info.name ~ `.findLocation(programId);
                if (` ~ info.name ~ `.location < 0)
                    logger.error("Vertex attribute '` ~ info.name ~ `' failed to find location");`);
        }
    }

    void setData(Vertex[] vertices)
    {
        auto ptr = vertices.ptr;
        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, &ptr, GL_STATIC_DRAW);
    }
}


template ShaderProgramInfo(string vertexSource, string fragmentSource)
{
    import std.range;
    import std.algorithm;
    import shaderplayground.logger;
    
    enum vertexVariables = getVariables(vertexSource);
    enum fragmentVariables = getVariables(fragmentSource);
    enum allVariables = vertexVariables ~ fragmentVariables;
    enum uniforms = allVariables.filter!(v => v.qualifier == Qualifier.Uniform).array();
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

            id = linkShaders(vertexShaderId, vertexShaderId);
            if (id == 0) return false;

            queryLocations();
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
            import bindbc.opengl;
            glUseProgram(id);
        }
    }
}


alias vec2 = Vector!(float, 2);
alias vec3 = Vector!(float, 3);
alias vec4 = Vector!(float, 4);

alias ivec2 = Vector!(int, 2);
alias ivec3 = Vector!(int, 3);
alias ivec4 = Vector!(int, 4);

alias bvec2 = Vector!(bool, 2);
alias bvec3 = Vector!(bool, 3);
alias bvec4 = Vector!(bool, 4);

void run()
{
    import bindbc.opengl;
    import bindbc.glfw;
    import shaderplayground.initialization : g_Window;
    import shaderplayground.shaderloader;
    import shaderplayground.logger;
    import std.conv;

    glfwSwapInterval(1);

    alias Info = ShaderProgramInfo!(vertexShaderText, fragmentShaderText);
    Info.ShaderProgram program;
    alias VBuffer = VertexBuffer!(Info.vertexAttributeInfos);
    VBuffer buffer;

    if (!program.initialize()) return;
    buffer.create();
    buffer.queryLocations(program.id);

    VBuffer.Vertex v1;
    v1.aColor = vec3(-0.6, -0.4, 1);
    v1.aPosition = vec2(0, 0);

    VBuffer.Vertex[3] vertexData = [
        v1,
        { vec3(0.6,  -0.4, 0), vec2(1, 0) },
        { vec3(0,    -0.6, 0), vec2(0, 1) }
    ];
    buffer.setData(vertexData);

 
    while (!glfwWindowShouldClose(g_Window))
    {
        float ratio;
        int width, height;
 
        glfwGetFramebufferSize(g_Window, &width, &height);
        ratio = width / cast(float) height;
 
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);

        mat4 model = rotationQuaternion(Vector3f(1.0f, 0.0f, 0.0f), cast(float) glfwGetTime()).toMatrix4x4();
        mat4 projection = orthoMatrix(-ratio, ratio, -1.0f, 1.0f, 1.0f, -1.0f);
        mat4 mvp = projection * model;

        program.use();
        program.uModelViewProjection.set(mvp);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(g_Window);
        glfwPollEvents();
    }
}
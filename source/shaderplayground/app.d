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
    inQualifier = "in", 
    outQualifier = "out", 
    uniformQualifier = "uniform" 
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


import std.regex;

enum ident = `[_a-zA-Z][_a-zA-Z0-9]*`;
enum layout = `layout\s*\(\s*location\s*=\s*([0-9]+)\s*\)\s*`;
enum variableRegexString = `\s*(` ~ layout ~ `)?(in|out|uniform)\s+(` ~ ident ~ `)\s+(` ~ ident ~ `)`;
enum variableDeclarationRegex = ctRegex!(variableRegexString);

unittest
{
    import std.regex;
    auto result = matchFirst("layout (location = 7) in a b", variableDeclarationRegex);
    assert(result.count == 6);
    assert(result[0] == `layout (location = 7) in a a`);
    assert(result[1] == `layout (location = 7)`);
    assert(result[2] == `7`);
    assert(result[3] == `in`);
    assert(result[4] == `a`);
    assert(result[5] == `b`);
}

alias whateverItReturns = typeof(matchFirst("", variableDeclarationRegex));
CTVariable fromMatch(whateverItReturns match)
{
    import std.conv : to;
    CTVariable result;
    result.location  = match[2] != "" ? to!int(match[2]) : -1;
    result.qualifier = cast(Qualifier) match[3];
    result.type      = match[4];
    result.name      = match[5];
    return result;
} 

CTVariable[] getVariables(string input)
{
    import std.range;
    import std.algorithm;
    import std.string : lineSplitter;

    return input.lineSplitter()
         .map!(s => matchFirst(s, variableDeclarationRegex))
         .map!(fromMatch)
         .array();
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


struct Attribute
{
    float x;
    float y;
    float r;
    float g;
    float b;
}

immutable Attribute[3] vertices =
[
    Attribute(-0.6f, -0.4f,  1.0f, 0.0f, 0.0f ),
    Attribute(0.6f,  -0.4f,  0.0f, 1.0f, 0.0f ),
    Attribute(0.0f,  0.6f,   0.0f, 0.0f, 1.0f )
];

void run()
{
    import bindbc.opengl;
    import bindbc.glfw;
    import shaderplayground.initialization : g_Window;
    import shaderplayground.shaderloader;

    glfwSwapInterval(1);

    GLuint vertex_buffer;
    glGenBuffers(1, &vertex_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, &vertices, GL_STATIC_DRAW);
    

    GLuint vertex_shader = compileShader(vertexShaderText, ShaderStage.vertex); 
    GLuint fragment_shader = compileShader(fragmentShaderText, ShaderStage.fragment); 
    if (vertex_shader == 0 || fragment_shader == 0) return;

    GLuint program = linkShaders(vertex_shader, fragment_shader);
    if (program == 0) return;
 
    GLint mvp_location = glGetUniformLocation(program, "uModelViewProjection");
    GLint pos_location = glGetAttribLocation(program, "aPosition");
    GLint col_location = glGetAttribLocation(program, "aColor");
 
    glEnableVertexAttribArray(pos_location);
    glVertexAttribPointer(pos_location, 2, GL_FLOAT, GL_FALSE, Attribute.sizeof, cast(const(GLvoid)*) 0);
    glEnableVertexAttribArray(col_location);
    glVertexAttribPointer(col_location, 3, GL_FLOAT, GL_FALSE, Attribute.sizeof, cast(const(GLvoid)*) 8);
 
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
 
        glUseProgram(program);
        glUniformMatrix4fv(mvp_location, 1, GL_FALSE, mvp.arrayof.ptr);
        glDrawArrays(GL_TRIANGLES, 0, 3);
 
        glfwSwapBuffers(g_Window);
        glfwPollEvents();
    }
}
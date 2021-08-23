module shaderplayground.shader_to_d;
import shaderplayground.parsing;
import shaderplayground.shadercommon;

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
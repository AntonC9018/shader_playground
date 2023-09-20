module shaderplayground.axes_object;

import shaderplayground;

struct LineUniforms
{
    @Vertex {
        mat4 uModelViewProjection;
    }
}

struct LineAttribute
{
    vec3 aPosition;
    vec3 aColor;
}

alias LineA = TypeAliases!(LineAttribute, LineUniforms);

immutable lineVertexShaderSource = LineA.vertexShaderSource(q{
    out vec3 vColor;

    void main()
    {
        // gl_Position = vec4(aPosition, 1.0);
        gl_Position = uModelViewProjection * vec4(aPosition, 1.0);
        vColor = aColor;
    }
});

immutable lineFragmentShaderSource = LineA.fragmentShaderSource(q{
    in vec3 vColor;

    out vec4 fragColor;

    void main()
    {
        fragColor = vec4(vColor, 1.0);
    }
});

struct AxesContext
{
    ShaderProgram!LineUniforms lineProgram;
    VertexBuffer!LineAttribute lineVertexBuffer;
    uint lineVaoId;
    static immutable int lineVertexCount = 6;

    void setup()
    {
        lineProgram.initialize(lineVertexShaderSource, lineFragmentShaderSource);

        // Set up lines' array buffers
        vec3[lineVertexCount] lineVertexPositions = [
            vec3(0, 1, 0), vec3(0, -1, 0),
            vec3(1, 0, 0), vec3(-1, 0, 0),
            vec3(0, 0, 1), vec3(0, 0, -1),
        ] * 100;
        vec3[lineVertexCount / 2] lineColors = [
            vec3(1, 0, 0),
            vec3(0, 1, 0),
            vec3(0, 0, 1),
        ];
        LineAttribute[lineVertexCount] lineVertices;
        foreach (i; 0 .. lineVertexCount)
        {
            lineVertices[i].aPosition = lineVertexPositions[i];
            lineVertices[i].aColor = lineColors[i / 2];
        }

        glGenVertexArrays(1, &lineVaoId);
        glBindVertexArray(lineVaoId);

        setupVertexBuffer(lineVertexBuffer, lineProgram.id, lineVertices[]);
    }

    void draw(mat4 transform = mat4.identity, float lineWidth = 5)
    {
        glLineWidth(lineWidth);
        glBindVertexArray(lineVaoId);
        lineProgram.use();
        LineUniforms lineUniforms;
        setModelRelatedUniforms(transform, &lineUniforms);
        lineProgram.setUniforms(&lineUniforms);
        glDrawArrays(GL_LINES, 0, lineVertexCount);
    }
}

struct AxesObject
{
    AxesContext* model;
    mat4 transform;
    float lineWidth;

    void draw()
    {
        model.draw(transform, lineWidth);
    }
}
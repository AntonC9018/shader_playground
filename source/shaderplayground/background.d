module shaderplayground.background;

import shaderplayground;

struct BackgroundUniforms
{
    @Fragment Texture2D uBackground;
}

struct BackgroundAttribute
{
    vec2 aPosition;
}


private alias A = TypeAliases!(BackgroundAttribute, BackgroundUniforms);

private immutable vertexShader = A.vertexShaderSource(q{
    out vec2 vTexCoord;

    void main()
    {
        gl_Position = vec4(aPosition, 0.0, 1.0);
        vTexCoord = (aPosition + vec2(1.0, 1.0)) / 2.0;
    }
});

private immutable fragmentShader = A.fragmentShaderSource(q{
    in vec2 vTexCoord;

    out vec4 fragColor;

    void main()
    {
        fragColor = texture(uBackground, vTexCoord);
    }
});

struct BackgroundModel
{
    enum vertexCount = 6;

    VertexArrayObject vao;
    A.ShaderProgram program;

    void initialize()
    {
        auto vertices = cast(BackgroundAttribute[vertexCount]) [
            vec2(-1.0, -1.0),
            vec2(-1.0, 1.0),
            vec2(1.0, 1.0),

            vec2(-1.0, -1.0),
            vec2(1.0, 1.0),
            vec2(1.0, -1.0),
        ];
        program.initialize(vertexShader, fragmentShader);
        vao.setup();
        vao.bind();
        VertexBuffer!BackgroundAttribute vertexBuffer;
        setupVertexBuffer(vertexBuffer, program.id, vertices);
    }

    void draw(Texture2D texture)
    {
        vao.bind();
        program.use();
        auto uniforms = BackgroundUniforms(texture);
        program.setUniforms(&uniforms);
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}

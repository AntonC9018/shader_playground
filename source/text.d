module text;

import shaderplayground;

struct TextAttribute
{
    vec2 aPosition;
    vec2 aTexCoord;
}

struct TextUniforms
{
    Texture2D uTexture;
}

private immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TextAttribute ~ q{ 
    out vec2 vTexCoord;
    void main()
    {
        gl_Position = vec4(aPosition, 0.0, 1.0);
        vTexCoord = vec2(aTexCoord);
    }
};

private immutable string fragmentShaderText = SHADER_HEADER ~ q{
    
    // Has the pixel texture coordinates
    in vec2 vTexCoord;
    out vec4 fragColor;

    uniform sampler2D uTexture;

    void main()
    {
        vec4 sampled = vec4(1.0, 1.0, 1.0, texture(uTexture, vTexCoord).r);
        fragColor = sampled; // white
    }
};


class TextApp : IApp
{

    TextUniforms uniforms;
    VertexBuffer!TextAttribute vbo;
    IndexBuffer ibo;
    ShaderProgram!TextUniforms program;
    TrueColorImage fontBitmap;
    uint vaoId;
    
    char charToDraw = 'A';

    void setup()
    {
        import arsd.bmp;

        glGenVertexArrays(1, &vaoId);
        glBindVertexArray(vaoId);

        program = ShaderProgram!TextUniforms();
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");
        fontBitmap = cast(TrueColorImage) readBmp(getAssetPath("bmp_fonts/consolas.bmp"));
        uniforms.uTexture = Texture2D.make(fontBitmap);

        vbo.create();
        vbo.bind();
        vbo.setup(program.id); 

        setupIndexBuffer(ibo, [ivec3(0, 1, 2), ivec3(0, 2, 3)]);
        // uniforms.uTexSize = ivec2(fontBitmap.width, fontBitmap.height);
        import std.stdio;
        writeln(TextAttribute.sizeof);
    }

    TextAttribute[4] vertices;

    void loop(double dt)
    {
        auto characterHeight = 32;
        auto characterWidth = 16;
        char firstCharacter = ' ';
        auto charsPerRow = fontBitmap.width / characterWidth;
        auto charsPerCol = fontBitmap.height / characterHeight;
        auto charWidthInTexCoords = 1.0f / charsPerRow;
        auto charHeigthInTexCoords = 1.0f / charsPerCol;
        auto charIndexOffset = cast(int) (charToDraw - firstCharacter);

        auto rowIndex = charIndexOffset / charsPerRow;
        auto colIndex = charIndexOffset - rowIndex * charsPerRow;

        auto onePixelWidthInTexCoords = charWidthInTexCoords / 16;
        auto onePixelHeightInTexCoords = charHeigthInTexCoords / 16;

        auto x = cast(float) colIndex / charsPerRow + onePixelWidthInTexCoords / 2;
        auto y = cast(float) rowIndex / charsPerCol + onePixelHeightInTexCoords / 2;

        // auto x = colIndex * characterWidth;
        // auto y = rowIndex * characterHeight;

        // left bottom
        vertices[0].aTexCoord = vec2(x, y + charHeigthInTexCoords);
        vertices[0].aPosition = vec2(0, 0);
        // left top
        vertices[1].aTexCoord = vec2(x, y);
        vertices[1].aPosition = vec2(0, 1);
        // right top
        vertices[2].aTexCoord = vec2(x + charWidthInTexCoords, y);
        vertices[2].aPosition = vec2(0.5, 1);
        // bottom right
        vertices[3].aTexCoord = vec2(x + charWidthInTexCoords, y + charHeigthInTexCoords);
        vertices[3].aPosition = vec2(0.5, 0);

        
        glBindVertexArray(vaoId);
        program.use();
        vbo.setData(vertices[], GL_DYNAMIC_DRAW);
        program.setUniforms(&uniforms);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
    }

    void doImgui()
    {
    }
}
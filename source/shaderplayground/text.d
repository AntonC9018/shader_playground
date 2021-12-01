module shaderplayground.text;

import shaderplayground;

struct TextAttribute
{
    vec2 aPosition;
    vec2 aTexCoord;
}

struct TextUniforms
{
    Texture2D uTexture;
    // TODO: add a `manual` attribute
    enum Manual;
    @Manual vec2 uTexCoord;
    @Manual vec2 uOffset;
    mat4 uModelViewProjection;
}

private immutable string vertexShaderText = SHADER_HEADER 
    ~ VertexAttributeShaderDeclarations!TextAttribute ~ q{ 
    
    out vec2 vTexCoord;
    uniform mat4 uModelViewProjection;
    uniform vec2 uTexCoord;
    uniform vec2 uOffset;

    void main()
    {
        gl_Position = uModelViewProjection * vec4(aPosition + uOffset, 0.0, 1.0);
        vTexCoord = vec2(aTexCoord) + uTexCoord;
    }
};

private immutable string fragmentShaderText = SHADER_HEADER ~ q{
    
    in vec2 vTexCoord;
    out vec4 fragColor;
    uniform sampler2D uTexture;

    void main()
    {
        vec4 sampled = vec4(1.0, 1.0, 1.0, texture(uTexture, vTexCoord).r);
        fragColor = sampled; // white
    }
};

struct FontBitmapMetadata
{
    char firstCharacter;

    ivec2 characterDimensions;
    ivec2 dimensions;

    ivec2 charactersPer;
    int charactersPerRow() { return charactersPer.x; }
    int charactersPerColumn() { return charactersPer.y; }

    vec2 onePixelInTexCoords;
    vec2 oneCharacterInTexCoords;

    float heightToWidthRatio;

    this(TrueColorImage image, int characterWidth = 16, int characterHeight = 32, char firstCharacter = ' ')
    {
        this.characterDimensions = ivec2(characterWidth, characterHeight);
        this.firstCharacter = firstCharacter;
        this.dimensions = ivec2(image.width, image.height);

        this.charactersPer = dimensions / characterDimensions;

        this.oneCharacterInTexCoords = vec2(characterDimensions) / vec2(dimensions);
        this.onePixelInTexCoords = vec2(1, 1) / vec2(dimensions);

        this.heightToWidthRatio = cast(float) (characterDimensions.y) / characterDimensions.x;
    }

    ivec2 getCharTableCoords(char ch)
    {
        int charIndexOffset = cast(int) (ch - firstCharacter);
        int rowIndex = charIndexOffset / charactersPerRow;
        int colIndex = charIndexOffset - rowIndex * charactersPerRow;
        if (!(rowIndex >= 0 && rowIndex < charactersPerColumn && colIndex >= 0 && colIndex < charactersPerRow))
        {
            g_Logger.log("Only ascii characters starting from space are allowed");
            rowIndex = 0;
            colIndex = 0;
        }
        return ivec2(colIndex, rowIndex);
    }

    vec2 getTexCoordsFromTableCoords(ivec2 tableCoords)
    {
        auto a = vec2(tableCoords) / vec2(charactersPer);
        return a + onePixelInTexCoords / 2;
    }

    vec2 getCharTexCoords(char ch)
    {
        return getTexCoordsFromTableCoords(getCharTableCoords(ch));
    }

    enum characterWidth = 1;

    void fillAttributes(ref TextAttribute[4] attributes)
    {
        attributes[0].aTexCoord = vec2(0, oneCharacterInTexCoords.y); 
        attributes[1].aTexCoord = vec2(0, 0); 
        attributes[2].aTexCoord = vec2(oneCharacterInTexCoords.x, 0); 
        attributes[3].aTexCoord = oneCharacterInTexCoords;
        
        attributes[0].aPosition = vec2(0, 0);
        attributes[1].aPosition = vec2(0, 0 + characterWidth * heightToWidthRatio);
        attributes[2].aPosition = vec2(0 + characterWidth, 0 + characterWidth * heightToWidthRatio);
        attributes[3].aPosition = vec2(0 + characterWidth, 0);
    }

    vec2 getInitialOffset(TextAlignment alignment = TextAlignment.Left|TextAlignment.Bottom, int lineWidth = 1, int lineCount = 1)
    {
        float x = 0;
        float y = 0;

        float lineHeight = characterWidth * heightToWidthRatio * lineCount;

        // if (alignment & TextAlignment.Left)
        // {
        //     x = 0;
        // }
        if (alignment & TextAlignment.Center)
        {
            x = -lineWidth / 2;
        }
        else if (alignment & TextAlignment.Right)
        {
            x = -lineWidth;
        }

        // if (alignment & TextAlignment.Bottom)
        // {
        //     y = 0;
        // }
        if (alignment & TextAlignment.Middle)
        {
            y = -lineHeight / 2;
        }
        else if (alignment & TextAlignment.Top)
        {
            y = -lineHeight;
        }

        return vec2(x, y);
    }
}

enum TextAlignment
{
    Left    = 1,
    Middle  = 2,
    Right   = 4,
    Top     = 8,
    Center  = 16,
    Bottom  = 32
}

struct TextDrawer
{
    TextUniforms uniforms;
    ShaderProgram!TextUniforms program;
    VertexBuffer!TextAttribute vbo;
    FontBitmapMetadata fontBitmapMetadata;
    IndexBuffer ibo;
    uint vaoId;

    void setup()
    {
        import arsd.bmp;

        program = ShaderProgram!TextUniforms();
        errors("Before text");
        assert(program.initialize(vertexShaderText, fragmentShaderText), "Shader program failed to initialize");
        auto fontBitmap = cast(TrueColorImage) readBmp(getAssetPath("bmp_fonts/consolas.bmp"));
        fontBitmapMetadata = FontBitmapMetadata(fontBitmap);

        uniforms.uTexture = texture2D(fontBitmap);
        
        glGenVertexArrays(1, &vaoId);
        glBindVertexArray(vaoId);

        TextAttribute[4] vertices;
        fontBitmapMetadata.fillAttributes(vertices);
        setupVertexBuffer(vbo, program.id, vertices);
        setupIndexBuffer(ibo, [ivec3(1, 0, 2), ivec3(2, 0, 3)]);
    }

    private void startDraw(ref mat4 bottomLeftCornerModelTransform)
    {
        glBindVertexArray(vaoId);
        program.use();
        setModelRelatedUniforms(bottomLeftCornerModelTransform, &uniforms);
        program.setUniforms(&uniforms);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

    void drawLetter(char letter, TextAlignment alignment = TextAlignment.Left|TextAlignment.Bottom, 
        auto ref mat4 bottomLeftCornerModelTransform = mat4.identity)
    {
        uniforms.uOffset = fontBitmapMetadata.getInitialOffset(alignment, 1, 1);
        uniforms.uTexCoord = fontBitmapMetadata.getCharTexCoords(letter);
        startDraw(bottomLeftCornerModelTransform);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
    }

    void drawLine(string characters, TextAlignment alignment = TextAlignment.Left|TextAlignment.Bottom, 
        auto ref mat4 bottomLeftCornerModelTransform = mat4.identity)
    {
        startDraw(bottomLeftCornerModelTransform);
        auto offset = fontBitmapMetadata.getInitialOffset(alignment, cast(int) characters.length, 1);

        TextAttribute[4] vertices;

        foreach (ch; characters)
        {
            program.uniformInfos.uTexCoord.set(fontBitmapMetadata.getCharTexCoords(ch));
            program.uniformInfos.uOffset.set(offset);
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
            
            offset.x += 1;
        }
    }

    void drawLines(
        string characters, 
        TextAlignment alignment = TextAlignment.Left|TextAlignment.Bottom, 
        int maxCharactersPerLine = 0,
        auto ref mat4 bottomLeftCornerModelTransform = mat4.identity)
    {
        if (maxCharactersPerLine <= 0)
            return drawLine(characters, alignment, bottomLeftCornerModelTransform);

        startDraw(bottomLeftCornerModelTransform);
        // TODO: proper wrapping
        int numLines = cast(int) characters.length / maxCharactersPerLine;

        auto offset = fontBitmapMetadata.getInitialOffset(alignment, cast(int) characters.length, 1);
        float initialX = offset.x;

        size_t currentIndex = 0;
        foreach (lineNumber; 0..numLines)
        {
            auto t = currentIndex + maxCharactersPerLine;
            foreach (ch; characters[currentIndex..(t > $ ? $ : t)])
            {
                program.uniformInfos.uTexCoord.set(fontBitmapMetadata.getCharTexCoords(ch));
                program.uniformInfos.uOffset.set(offset);
                glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);

                offset.x += 1;
            }
            offset.x = initialX;
            offset.y += fontBitmapMetadata.heightToWidthRatio;
        }
    }

    float getWidth(string str)
    {
        return str.length;
    }

    float getHeight(string str = "")
    {
        return fontBitmapMetadata.heightToWidthRatio;
    }
}

struct TextObject
{
    string text;
    TextAlignment alignment = TextAlignment.Left|TextAlignment.Bottom;
    mat4 transform = mat4.identity;
    int maxCharactersPerLine = 0;

    // set the other parameters manually
    this(string text) { this.text = text; }

    void draw()
    {
        import shaderplayground.globals : g_TextDrawer;
        // TODO: draw onto a texture, store the texture, then just redraw the texture here
        g_TextDrawer.drawLines(text, alignment, maxCharactersPerLine, transform);
    }
}

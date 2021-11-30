module shaderplayground.userutils;

interface IApp
{
    void setup();
    void doImgui();
    void loop(double dt);
}

// TODO: this is too verbose??
interface ITerminate
{
    void terminate();
}

class AppBase(Uniforms) : IApp, ITerminate
{
    Unforms uniforms;

    import shaderplayground;
    void setup()
    {
        load(uniforms);
    }

    void doImgui()
    {
        .doImgui(&uniforms);
    }

    void loop(double dt)
    {
    }

    void terminate()
    {
        save(uniforms);
    }
}

/// A helper template that can be used to eliminate some boilerplate 
/// by using some predefined aliases and helper functions.
template TypeAliases(TAttribute, TUniforms)
{
    import shaderplayground;

    alias Model                = shaderplayground.model.Model!(TAttribute, TUniforms);
    alias Object               = shaderplayground.object.Object!(TAttribute, TUniforms);
    alias VertexDeclarations   = shaderplayground.d_to_shader.VertexDeclarations!(TAttribute, TUniforms);
    alias FragmentDeclarations = shaderplayground.d_to_shader.FragmentMarkedUniformDeclarations!TUniforms;
    alias ShaderProgram        = shaderplayground.d_to_shader.ShaderProgram!TUniforms;

    ShaderSource vertexShaderSource(string shaderText, const ShaderSource[] imports = null, string file = __FILE_FULL_PATH__, size_t line = __LINE__)
    {
        return createShaderSource(shaderText, VertexDeclarations, imports, SHADER_HEADER, file, line);
    }

    ShaderSource fragmentShaderSource(string shaderText, const ShaderSource[] imports = null, string file = __FILE_FULL_PATH__, size_t line = __LINE__)
    {
        return createShaderSource(shaderText, FragmentDeclarations, imports, SHADER_HEADER, file, line);
    }
}

import shaderplayground.d_to_shader : createShaderImport;

immutable importNoise = createShaderImport(q{
    // 2D Random
    float random (in vec2 st) 
    {
        return fract(sin(dot(st.xy,
                            vec2(12.9898,78.233)))
                    * 43758.5453123);
    }

    // 2D Noise based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise (in vec2 st) 
    {
        vec2 i = floor(st);
        vec2 f = fract(st);

        // Four corners in 2D of a tile
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));

        // Smooth Interpolation

        // Cubic Hermine Curve.  Same as SmoothStep()
        vec2 u = f * f * (3.0 - 2.0 * f);
        // u = smoothstep(0.0, 1.0, f);

        // Mix 4 coorners percentages
        return mix(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
    }
});
module shaderplayground.userutils;

interface IApp
{
    void setup();
    void doImgui();
    void loop(double dt);
}

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

template TypeAliases(TAttribute, TUniforms)
{
    import shaderplayground;

    alias Model                = shaderplayground.model.Model!(TAttribute, TUniforms);
    alias Object               = shaderplayground.object.Object!(TAttribute, TUniforms);
    alias VertexDeclarations   = shaderplayground.d_to_shader.VertexDeclarations!(TAttribute, TUniforms);
    alias FragmentDeclarations = shaderplayground.d_to_shader.FragmentMarkedUniformDeclarations!TUniforms;
    alias ShaderProgram        = shaderplayground.d_to_shader.ShaderProgram!TUniforms;
}

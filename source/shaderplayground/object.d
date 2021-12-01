module shaderplayground.object;

import shaderplayground.model;
import dlib.math;


struct Object(TAttribute)
{
    Model!(TAttribute)* model;
    mat4 transform = mat4.identity;

    void draw(TProgram, TUniforms)(TProgram* shaderProgram, TUniforms* uniforms)
    {
        model.draw(shaderProgram, uniforms, transform);
    }
}

auto makeObject(TAttribute)
    (Model!TAttribute* model, mat4 transform = mat4.identity)
{
    return Object!(TAttribute)(model, transform);
}
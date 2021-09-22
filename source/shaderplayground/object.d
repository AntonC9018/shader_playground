module shaderplayground.object;

import shaderplayground.model;
import dlib.math;


struct Object(TAttribute, TUniforms)
{
    Model!(TAttribute, TUniforms)* model;
    mat4 transform = mat4.identity;

    void draw(TUniforms* uniforms)
    {
        model.draw(uniforms, transform);
    }
}

auto makeObject(TAttribute, TUniforms)
    (Model!(TAttribute, TUniforms)* model, mat4 transform = mat4.identity)
{
    return Object!(TAttribute, TUniforms)(model, transform);
}
module shaderplayground.object;

import shaderplayground.model;

struct Object(TAttribute, TUniforms)
{
    Model!(TAttribute, TUniforms)* model;
    mat4 transform;

    void draw(TUniforms* uniforms)
    {
        model.draw(uniforms, transform);
    }
}
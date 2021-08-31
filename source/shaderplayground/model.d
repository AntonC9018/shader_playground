module shaderplayground.model;
import dlib.math;
import shaderplayground.d_to_shader;
import bindbc.opengl;

// http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html

struct ModelData(TAttribute)
{
    TAttribute[] vertexData;
    ivec3[] indexData;
}

// void setCameraUniforms(TUniforms)(TUniforms* uniforms)
// {
//     mat4 projection = g_Camera.projection();
//     mat4 view       = g_Camera.invTransform;
// }

void setModelRelatedUniforms(TUniforms)(mat4 model, TUniforms* uniforms)
{
    import shaderplayground.initialization : g_Camera;

    mat4 projection = g_Camera.projection();
    mat4 view       = g_Camera.invTransform;

    void set(string name, alias expression)()
    {
        static if (__traits(hasMember, TUniforms, name))
            __traits(getMember, uniforms, name) = expression();
    }

    // Conditional setting of uniforms
    set!("uModel",                      () => model);
    set!("uModelView",                  () => view * model);
    set!("uView",                       () => view);
    set!("uProjection",                 () => projection);
    set!("uModelViewInverseTranspose",  () => matrix4x4to3x3((view * model).inverse.transposed));
    set!("uModelViewProjection",        () => projection * view * model);
}


struct Model(TAttribute, TUniforms)
{
    ShaderProgram!TUniforms program;
    VertexBuffer!TAttribute vertexBuffer;
    mat4 localTransform; 
    IndexBuffer indexBuffer;
    ModelData!TAttribute modelData;

    this(ShaderProgram!TUniforms program, ModelData!TAttribute modelData)
    {
        assert(program.id != 0, "The program must be initialized at this point");
        this.program = program;
        this.modelData = modelData;
        this.localTransform = mat4.identity;
        initializeBuffers();
    }

    void initializeBuffers()
    {
        import shaderplayground;
        import std;

        setupVertexBuffer(vertexBuffer, program.id, modelData.vertexData);
        enforce(indexBuffer.validateData(modelData.indexData, modelData.vertexData.length));
        setupIndexBuffer(indexBuffer, modelData.indexData);
    }

    void draw(TUniforms* uniforms)
    {
        program.use();
        vertexBuffer.bind();
        indexBuffer.bind();
        setModelRelatedUniforms(localTransform, uniforms);
        program.setUniforms(uniforms);

        glDrawElements(GL_TRIANGLES, cast(int) modelData.indexData.length * 3, GL_UNSIGNED_INT, cast(void*) 0);
        
        // parametrizationFunction(this);
    }
}

template createModel(TAttribute, TUniforms)
{
    auto createModel(ShaderProgram!TUniforms program, ModelData!TAttribute modelData)
    {
        return Model!(TAttribute, TUniforms)(program, modelData);
    }
}

template makeSquare(TAttribute)
{
    auto _getVertices()
    {
        TAttribute[4] result;
        result[0].aPosition = vec3(0, 0, 0);
        result[1].aPosition = vec3(0, 1, 0);
        result[2].aPosition = vec3(1, 1, 0);
        result[3].aPosition = vec3(1, 0, 0);
        return result;
    }
    
    static immutable vertices = _getVertices();
    static immutable indices = [ivec3(0, 1, 2), ivec3(0, 2, 3)];

    auto makeSphere()
    {
        return ModelData!TAttribute(vertices, indices);
    }
}

auto makeSphere(TAttribute)(uint recursionCount)
    in(recursionCount < 5, "What do you need this many vertices for?")
{
    struct IcoSphereCreator
    {
        import std.math;
        import std.algorithm;

        struct Result
        {
            vec3[] positions;
            ivec3[] indices;
        }

        size_t _index;
        size_t[ulong] _middlePointIndexCache;
        Result _result;

        // add vertex to mesh, fix position to be on unit sphere, return index
        size_t addVertex(vec3 point)
        {
            if (!canFind(_result.positions, point.normalized))
                _result.positions ~= point.normalized;

            return _index++;
        }

        // return index of point in the middle of p1 and p2
        size_t getMiddlePoint(size_t p1, size_t p2)
        {
            // first check if we have it already
            bool firstIsSmaller = p1 < p2;
            ulong smallerIndex = firstIsSmaller ? p1 : p2;
            ulong greaterIndex = firstIsSmaller ? p2 : p1;
            ulong key = (smallerIndex << 32) + greaterIndex;

            if (auto ret = key in _middlePointIndexCache)
            {
                return *ret;
            }

            // not in cache, calculate it
            vec3 point1 = _result.positions[p1];
            vec3 point2 = _result.positions[p2];
            vec3 middle = (point1 + point2) / 2.0f;

            // add vertex makes sure point is on unit sphere
            size_t i = addVertex(middle); 

            // store it, return index
            _middlePointIndexCache[key] = i;
            return i;
        }

        public Result Create(uint recursionLevel)
        {
            // create 12 vertices of a icosahedron
            auto t = (1.0 + sqrt(5.0)) / 2.0;

            addVertex(vec3(-1,  t,  0));
            addVertex(vec3( 1,  t,  0));
            addVertex(vec3(-1, -t,  0));
            addVertex(vec3( 1, -t,  0));

            addVertex(vec3( 0, -1,  t));
            addVertex(vec3( 0,  1,  t));
            addVertex(vec3( 0, -1, -t));
            addVertex(vec3( 0,  1, -t));

            addVertex(vec3( t,  0, -1));
            addVertex(vec3( t,  0,  1));
            addVertex(vec3(-t,  0, -1));
            addVertex(vec3(-t,  0,  1));


            // create 20 triangles of the icosahedron
            auto faces = [
                ivec3(0, 11, 5),
                ivec3(0, 5, 1),
                ivec3(0, 1, 7),
                ivec3(0, 7, 10),
                ivec3(0, 10, 11),

                ivec3(1, 5, 9),
                ivec3(5, 11, 4),
                ivec3(11, 10, 2),
                ivec3(10, 7, 6),
                ivec3(7, 1, 8),

                ivec3(3, 9, 4),
                ivec3(3, 4, 2),
                ivec3(3, 2, 6),
                ivec3(3, 6, 8),
                ivec3(3, 8, 9),

                ivec3(4, 9, 5),
                ivec3(2, 4, 11),
                ivec3(6, 2, 10),
                ivec3(8, 6, 7),
                ivec3(9, 8, 1)
            ];


            // refine triangles
            for (uint i = 0; i < recursionLevel; i++)
            {
                ivec3[] faces2;
                foreach (tri; faces)
                {
                    // replace triangle by 4 triangles
                    size_t a = getMiddlePoint(tri[0], tri[1]);
                    size_t b = getMiddlePoint(tri[1], tri[2]);
                    size_t c = getMiddlePoint(tri[0], tri[2]);

                    faces2 ~= ivec3(tri[0], a, c);
                    faces2 ~= ivec3(tri[1], b, a);
                    faces2 ~= ivec3(tri[2], c, b);
                    faces2 ~= ivec3(a, b, c);
                }
                faces = faces2;
            }

            _result.indices = faces;
            return _result;
        }
    }

    auto geometry = IcoSphereCreator().Create(recursionCount);

    static if (TAttribute.tupleof.length == 1 && TAttribute.tupleof[0] == "aPosition")
    {
        return ModelData!TAttribute(geometry.positions, geometry.indices);
    }
    else
    {
        TAttribute[] vertexData = new TAttribute[geometry.positions.length];

        foreach (i, position; geometry.positions)
        {
            static if (__traits(hasMember, vertexData[i], "aPosition"))
                vertexData[i].aPosition = position;

            static if (__traits(hasMember, vertexData[i], "aNormal"))
                vertexData[i].aNormal = position.normalized;
        }

        return ModelData!TAttribute(vertexData, geometry.indices);
    }
}

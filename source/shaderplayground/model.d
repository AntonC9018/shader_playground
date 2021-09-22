module shaderplayground.model;
import dlib.math;
import shaderplayground.d_to_shader;
import bindbc.opengl;

// http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html

struct ModelData(TAttribute)
{
    const (TAttribute)[] vertexData;
    const (ivec3)[] indexData;
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
    ShaderProgram!TUniforms* program;
    ModelData!TAttribute modelData;

    VertexBuffer!TAttribute vertexBuffer;
    IndexBuffer indexBuffer;
    
    mat4 localTransform; 
    uint vaoId;

    this(ShaderProgram!TUniforms* program, ModelData!TAttribute modelData)
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
        import std.exception;

        // This is a very important step.
        // Without this thing they vertices stomp over each other.
        glGenVertexArrays(1, &vaoId);
        glBindVertexArray(vaoId);

        setupVertexBuffer(vertexBuffer, program.id, modelData.vertexData);
        enforce(indexBuffer.validateData(modelData.indexData, modelData.vertexData.length));
        setupIndexBuffer(indexBuffer, modelData.indexData);
    }

    void draw(TUniforms* uniforms, mat4 transform = mat4.identity)
    {
        glBindVertexArray(vaoId);
        program.use();

        setModelRelatedUniforms(transform * localTransform, uniforms);
        program.setUniforms(uniforms);

        glDrawElements(GL_TRIANGLES, cast(int) modelData.indexData.length * 3, GL_UNSIGNED_INT, cast(void*) 0);
        
        // parametrizationFunction(this);
    }
}

template createModel(TAttribute, TUniforms)
{
    auto createModel(ShaderProgram!TUniforms* program, ModelData!TAttribute modelData)
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

        foreach (ref v; result[])
        {
            static if (__traits(hasMember, TAttribute, "aNormal"))
                v.aNormal = vec3(0, 0, 1);

            static if (__traits(hasMember, TAttribute, "aTexCoord"))
                v.aTexCoord = vec2(v.aPosition);
        }

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

            static if (__traits(hasMember, vertexData[i], "aTexCoord"))
                vertexData[i].aTexCoord = (vec2(position.normalized) + 1) / 2;
        }

        return ModelData!TAttribute(vertexData, geometry.indices);
    }
}




template makePrism(TAttribute)
{
    struct DataResult
    {
        TAttribute[6 * 4] vertices;
        uint[6 * 6] indices;
    }

    alias v3 = vec3;

    DataResult _getVerticesAndIndices()
    {
        DataResult result;

        v3[8] positions = [
            // bottom square
            v3(0, 0, 0),
            v3(0, 1, 0),
            v3(1, 1, 0),
            v3(1, 0, 0),

            // top square
            v3(0, 0, 1),
            v3(0, 1, 1),
            v3(1, 1, 1),
            v3(1, 0, 1),
        ];

        v3[6] normals = [
            // bottom
            v3(0, 0, -1),
            // left
            v3(-1, 0, 0),
            // front
            v3(0, -1, 0),
            // right
            v3(1, 0, 0),
            // back
            v3(0, 1, 0),
            // top
            v3(0, 0, 1),
        ];

        uint[] indexSetsPerSide = [
            // bottom
            1, 0, 3, 2,
            // left
            1, 5, 4, 0,
            // front
            0, 4, 7, 3,
            // right
            3, 7, 6, 2,
            // back
            2, 6, 5, 1,
            // top
            4, 5, 6, 7,
        ];

        size_t currentTriIndex = 0;
        size_t vertexIndex = 0;
        foreach (sideIndex; 0..6)
        {
            auto indexSetIndex = sideIndex * 4;
            auto normal = normals[sideIndex];

            import std.range;
            foreach (triIndex; [0, 1, 2, 0, 2, 3].retro)
                result.indices[currentTriIndex++] = cast(uint) vertexIndex + triIndex;

            size_t vertexIndexInCurrentQuad = 0;
            foreach (triVertexIndex; indexSetsPerSide[indexSetIndex..indexSetIndex + 4])
            {
                static if (__traits(hasMember, TAttribute, "aNormal"))
                    result.vertices[vertexIndex].aNormal = normal;

                static if (__traits(hasMember, TAttribute, "aTexCoord"))
                    result.vertices[vertexIndex].aTexCoord = vec2(positions[vertexIndexInCurrentQuad]);

                result.vertices[vertexIndex].aPosition = positions[triVertexIndex];
                vertexIndex++;
                vertexIndexInCurrentQuad++;
            }
        }

        return result;
    }
    
    static immutable verticesAndIndices = _getVerticesAndIndices();
    static immutable vertices = verticesAndIndices.vertices;
    static immutable indices = verticesAndIndices.indices;

    auto makePrism()
    {
        import std.stdio;
        writeln(vertices);
        writeln(cast(ivec3[])indices);
        return ModelData!TAttribute(vertices[], cast(ivec3[]) indices[]);
    }
}

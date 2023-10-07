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
    import shaderplayground.globals : g_Camera;

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


struct Model(TAttribute)
{
    ModelData!TAttribute modelData;

    VertexBuffer!TAttribute vertexBuffer;
    IndexBuffer indexBuffer;
    
    mat4 localTransform; 
    VertexArrayObject vao;

    private this(ModelData!TAttribute modelData)
    {
        this.modelData = modelData;
        this.localTransform = mat4.identity;
    }

    void initializeBuffers(uint programId)
    {
        import shaderplayground;
        import std.exception;

        // This is a very important step.
        // Without this thing they vertices stomp over each other.
        vao.setup();
        vao.bind();

        setupVertexBuffer(vertexBuffer, programId, modelData.vertexData);
        enforce(indexBuffer.validateData(modelData.indexData, modelData.vertexData.length));
        setupIndexBuffer(indexBuffer, modelData.indexData);
    }

    void draw(TProgram, TUniforms)(TProgram* shaderProgram, TUniforms* uniforms, auto ref mat4 transform = mat4.identity)
    {
        vao.bind();
        shaderProgram.use();

        setModelRelatedUniforms(transform * localTransform, uniforms);
        static assert(__traits(hasMember, TProgram, "setUniforms"));
        shaderProgram.setUniforms(uniforms);

        glDrawElements(
            GL_TRIANGLES,
            cast(int) modelData.indexData.length * 3,
            GL_UNSIGNED_INT,
            null);
        
        // parametrizationFunction(this);
    }
}

auto createModel(TAttribute)(ModelData!TAttribute modelData, uint programId)
{
    auto m = Model!(TAttribute)(modelData);
    m.initializeBuffers(programId);
    return m;
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

    auto makeSquare()
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
            alias Helper = AttributeHelper!TAttribute;
            Helper.setPosition(vertexData[i], position);
            Helper.setNormal(vertexData[i], position.normalized);
            Helper.setTexCoord(vertexData[i], (vec2(position.normalized) + 1) / 2);
        }

        return ModelData!TAttribute(vertexData, geometry.indices);
    }
}


template AttributeHelper(TAttribute)
{
    void setNormal(ref TAttribute attr, vec3 normal)
    {
        static if (__traits(hasMember, TAttribute, "aNormal"))
            attr.aNormal = normal;
    }

    void setPosition(ref TAttribute attr, vec3 normal)
    {
        static if (__traits(hasMember, TAttribute, "aPosition"))
            attr.aPosition = normal;
    }

    void setTexCoord(ref TAttribute attr, vec2 texCoord)
    {
        static if (__traits(hasMember, TAttribute, "aTexCoord"))
            attr.aTexCoord = texCoord;
    }
}


template makeCube(TAttribute)
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
                auto vert = &result.vertices[vertexIndex];

                alias Helper = AttributeHelper!TAttribute;
                Helper.setPosition(*vert, positions[triVertexIndex]);
                Helper.setNormal(*vert, normal);
                Helper.setTexCoord(*vert, vec2(positions[vertexIndexInCurrentQuad]));

                vertexIndex++;
                vertexIndexInCurrentQuad++;
            }
        }

        return result;
    }
    
    static immutable verticesAndIndices = _getVerticesAndIndices();
    static immutable vertices = verticesAndIndices.vertices;
    static immutable indices = verticesAndIndices.indices;

    auto makeCube()
    {
        import std.stdio;
        return ModelData!TAttribute(vertices[], cast(ivec3[]) indices[]);
    }
}


struct PathOnPointConfig
{
    vec2[] basePathPoints;
    vec3 topPointPosition;
    int numSections;

    /// Indicates if the last point should be connected to the first point.
    bool isClosed;
}

/// Aka if you give it the upper point and a circle, it will give you a cone.
/// The points must represent a convex surface.
ModelData!TAttribute makePathOntoPointData(TAttribute)(PathOnPointConfig config)
    in (config.basePathPoints.length >= 2 && config.numSections >= 1)
{
    static import std.math;

    int numBasePoints = cast(int) config.basePathPoints.length;
    int numVertices = numBasePoints * (config.numSections + 1);
    int numTrianglesPerSection = (numBasePoints - 1) * 2 + (config.isClosed ? 2 : 0);
    int numTriangles = numTrianglesPerSection * config.numSections;

    TAttribute[] vertexData = new TAttribute[numVertices];
    alias Helper = AttributeHelper!TAttribute;

    vec3[] normals = new vec3[numBasePoints];
    foreach (normalIndex; 0 .. numBasePoints)
    {
        vec3 p = config.basePathPoints[normalIndex];
        p.z = 0;
        vec3 diff = config.topPointPosition - p;
        vec3 axis = p.cross(diff);
        vec3 normal = diff.cross(axis);
        normals[normalIndex] = normal.normalized;
    }

    // vec2 centerPoint = sum(config.basePathPoints) / cast(float) numBasePoints;
    // foreach (normalIndex; 0 .. numBasePoints)
    //     normals[normalIndex] = (config.basePathPoints[normalIndex] - centerPoint).normalized;

    foreach (levelIndex; 0 .. config.numSections + 1)
    {
        float levelProgress = levelIndex / cast(float) (config.numSections);
        vec3 levelOffset = config.topPointPosition * levelProgress;
        float levelScale = 1 - levelProgress;
        foreach (levelVertexIndex; 0 .. numBasePoints)
        {
            float vertexProgress = levelVertexIndex / cast(float) numBasePoints;
            int vertexIndex = levelIndex * numBasePoints + levelVertexIndex;
            TAttribute* vertex = &vertexData[vertexIndex];

            vec3 position = config.basePathPoints[levelVertexIndex] * levelScale;
            position.z = 0;
            position += levelOffset;

            Helper.setPosition(*vertex, position);

            Helper.setNormal(*vertex, normals[levelVertexIndex]);
            Helper.setTexCoord(*vertex, vec2(vertexProgress, levelProgress));
        }
    }

    ivec3[] tris = new ivec3[numTriangles];
    int triIndex = 0;
    foreach (sectionIndex; 0 .. config.numSections)
    {
        int prevLevelIndex = sectionIndex;
        int levelIndex = sectionIndex + 1;
        int prevLevelIndexOffset = prevLevelIndex * numBasePoints;
        int levelIndexOffset = levelIndex * numBasePoints;
        foreach (vertexIndex; 0 .. numBasePoints - 1 + (config.isClosed ? 1 : 0))
        {
            // c---d
            // | \ |
            // a---b
            uint a = cast(uint) (prevLevelIndexOffset + vertexIndex % numBasePoints);
            uint b = cast(uint) (prevLevelIndexOffset + (vertexIndex + 1) % numBasePoints);
            uint c = cast(uint) (levelIndexOffset + vertexIndex % numBasePoints);
            uint d = cast(uint) (levelIndexOffset + (vertexIndex + 1) % numBasePoints);

            tris[triIndex++] = ivec3(a, c, b);
            tris[triIndex++] = ivec3(b, c, d);
        }
    }

    return ModelData!TAttribute(vertexData, tris);
}

struct CreateCircleConfig
{
    uint numPoints;
    bool isClosedLoop;
}

vec2[] getCircleBasePoints(TAttribute)(CreateCircleConfig config)
    in (config.numPoints >= 3)
{
    import std.math;
    float radius = 0.5f;
    float anglePerSplit = 2 * PI / cast(float) config.numPoints;
    vec2[] result = new vec2[config.numPoints + (config.isClosedLoop ? 1 : 0)];

    float angle = 0;
    vec2[] basePoints = result[0 .. config.numPoints];
    foreach (i, ref resultItem; basePoints)
    {
        const sinAngle = sin(angle);
        const cosAngle = cos(angle);
        const v = vec2(cosAngle, sinAngle) * radius;
        resultItem = v;
        angle += anglePerSplit;
    }

    if (config.isClosedLoop)
        result[$ - 1] = result[0];

    return result;
}
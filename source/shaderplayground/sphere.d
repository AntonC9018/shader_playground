module shaderplayground.sphere;
import dlib.math;
// http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html

struct MeshGeometry3D
{
    vec3[] Positions;
    ivec3[] TriangleIndexBuffer;
}

public class IcoSphereCreator
{
    import std.math;
    import std.algorithm;

    private MeshGeometry3D geometry;
    private int index;
    private int[long] middlePointIndexCache;

    // add vertex to mesh, fix position to be on unit sphere, return index
    private int addVertex(vec3 point)
    {
        if (!canFind(geometry.Positions, point.normalized))
            geometry.Positions ~= point.normalized;

        return index++;
    }

    // return index of point in the middle of p1 and p2
    private int getMiddlePoint(int p1, int p2)
    {
        // first check if we have it already
        bool firstIsSmaller = p1 < p2;
        long smallerIndex = firstIsSmaller ? p1 : p2;
        long greaterIndex = firstIsSmaller ? p2 : p1;
        long key = (smallerIndex << 32) + greaterIndex;

        if (auto ret = key in middlePointIndexCache)
        {
            return *ret;
        }

        // not in cache, calculate it
        vec3 point1 = this.geometry.Positions[p1];
        vec3 point2 = this.geometry.Positions[p2];
        vec3 middle = (point1 + point2) / 2.0f;

        // add vertex makes sure point is on unit sphere
        int i = addVertex(middle); 

        // store it, return index
        this.middlePointIndexCache[key] = i;
        return i;
    }

    public MeshGeometry3D Create(int recursionLevel)
    {
        this.geometry = MeshGeometry3D();
        clear(middlePointIndexCache);
        this.index = 0;

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
        for (int i = 0; i < recursionLevel; i++)
        {
            ivec3[] faces2;
            foreach (tri; faces)
            {
                // replace triangle by 4 triangles
                int a = getMiddlePoint(tri[0], tri[1]);
                int b = getMiddlePoint(tri[1], tri[2]);
                int c = getMiddlePoint(tri[0], tri[2]);

                faces2 ~= ivec3(tri[0], a, c);
                faces2 ~= ivec3(tri[1], b, a);
                faces2 ~= ivec3(tri[2], c, b);
                faces2 ~= ivec3(a, b, c);
            }
            faces = faces2;
        }

        this.geometry.TriangleIndexBuffer = faces;
        return this.geometry;        
    }
}
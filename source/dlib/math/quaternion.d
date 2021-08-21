/*
Copyright (c) 2011-2021 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * Quaternions
 *
 * Copyright: Timur Gafarov 2011-2021.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.math.quaternion;

import std.math;
import std.traits;

import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.utils;

/**
 * Quaternion representation
 */
struct Quaternion(T)
{
    Vector!(T,4) vectorof;
    alias vectorof this;

    this(T x, T y, T z, T w)
    {
        vectorof = Vector!(T,4)(x, y, z, w);
    }

    this(T[4] arr)
    {
        vectorof.arrayof = arr;
    }

    this(Vector!(T,4) v)
    {
        vectorof = v;
    }

    this(Vector!(T,3) v, T neww)
    {
        vectorof = Vector!(T,4)(v.x, v.y, v.z, neww);
    }

   /**
    * Identity quaternion
    */
    static Quaternion!(T) identity()
    {
        return Quaternion!(T)(T(0), T(0), T(0), T(1));
    }

   /**
    * Quaternion!(T) + Quaternion!(T)
    */
    Quaternion!(T) opBinary(string op)(Quaternion!(T) q) if (op == "+")
    {
        return Quaternion!(T)(x + q.x, y + q.y, z + q.z, w + q.w);
    }

   /**
    * Quaternion!(T) += Quaternion!(T)
    */
    Quaternion!(T) opOpAssign(string op)(Quaternion!(T) q) if (op == "+")
    {
        this = this + q;
        return this;
    }

   /**
    * Quaternion!(T) - Quaternion!(T)
    */
    Quaternion!(T) opBinary(string op)(Quaternion!(T) q) if (op == "-")
    {
        return Quaternion!(T)(x - q.x, y - q.y, z - q.z, w - q.w);
    }

   /**
    * Quaternion!(T) -= Quaternion!(T)
    */
    Quaternion!(T) opOpAssign(string op)(Quaternion!(T) q) if (op == "-")
    {
        this = this - q;
        return this;
    }

   /**
    * Quaternion!(T) * Quaternion!(T)
    */
    Quaternion!(T) opBinary(string op)(Quaternion!(T) q) if (op == "*")
    {
        return Quaternion!(T)
        (
            (x * q.w) + (w * q.x) + (y * q.z) - (z * q.y),
            (y * q.w) + (w * q.y) + (z * q.x) - (x * q.z),
            (z * q.w) + (w * q.z) + (x * q.y) - (y * q.x),
            (w * q.w) - (x * q.x) - (y * q.y) - (z * q.z)
        );
    }

   /**
    * Quaternion!(T) *= Quaternion!(T)
    */
    Quaternion!(T) opOpAssign(string op)(Quaternion!(T) q) if (op == "*")
    {
        this = this * q;
        return this;
    }

   /**
    * Quaternion!(T) * T
    */
    Quaternion!(T) opBinary(string op)(T k) if (op == "*")
    {
        return Quaternion!(T)(x * k, y * k, z * k, w * k);
    }

   /**
    * Quaternion!(T) *= T
    */
    Quaternion!(T) opOpAssign(string op)(T k) if (op == "*")
    {
        x *= k;
        y *= k;
        z *= k;
        w *= k;
        return this;
    }

   /**
    * T * Quaternion!(T)
    */
    Quaternion!(T) opBinaryRight(string op) (T k) if (op == "*")
    {
        return Quaternion!(T)(x * k, y * k, z * k, w * k);
    }

   /**
    * Quaternion!(T) / T
    */
    Quaternion!(T) opBinary(string op)(T k) if (op == "/")
    {
        T oneOverK = 1.0 / k;
        return Quaternion!(T)
        (
            x * oneOverK,
            y * oneOverK,
            z * oneOverK,
            w * oneOverK
        );
    }

   /**
    * Quaternion!(T) /= T
    */
    Quaternion!(T) opOpAssign(string op)(T k) if (op == "/")
    {
        T oneOverK = 1.0 / k;
        x *= oneOverK;
        y *= oneOverK;
        z *= oneOverK;
        w *= oneOverK;
        return this;
    }

   /**
    * Quaternion!(T) * Vector!(T,3)
    */
    Quaternion!(T) opBinary(string op)(Vector!(T,3) v) if (op == "*")
    {
        return Quaternion!(T)
        (
            (w * v.x) + (y * v.z) - (z * v.y),
            (w * v.y) + (z * v.x) - (x * v.z),
            (w * v.z) + (x * v.y) - (y * v.x),
          - (x * v.x) - (y * v.y) - (z * v.z)
        );
    }

   /**
    * Quaternion!(T) *= Vector!(T,3)
    */
    Quaternion!(T) opOpAssign(string op)(Vector!(T,3) v) if (op == "*")
    {
        this = this * v;
        return this;
    }

   /**
    * Conjugate
    * A quaternion with the opposite rotation
    */
    Quaternion!(T) conjugate()
    {
        return Quaternion!(T)(-x, -y, -z, w);
    }

    alias conj = conjugate;

   /**
    * Compute the W component of a unit length quaternion
    */
    void computeW()
    {
        T t = T(1.0) - (x * x) - (y * y) - (z * z);
        if (t < 0.0)
            w = 0.0;
        else
            w = -(t.sqrt);
    }

   /**
    * Rotate a point by quaternion
    */
    Vector!(T,3) rotate(Vector!(T,3) v)
    {
        Quaternion!(T) qf = this * v * this.conj;
        return Vector!(T,3)(qf.x, qf.y, qf.z);
    }

    Vector!(T,3) opBinaryRight(string op) (Vector!(T,3) v) if (op == "*")
    {
        Quaternion!(T) qf = this * v * this.conj;
        return Vector!(T,3)(qf.x, qf.y, qf.z);
    }

    static if (isNumeric!(T))
    {
       /**
        * Normalized version
        */
        Quaternion!(T) normalized()
        {
            Quaternion!(T) q = this;
            q.normalize();
            return q;
        }

       /**
        * Convert to 4x4 matrix
        */
        Matrix!(T,4) toMatrix4x4()
        {
            auto mat = Matrix!(T,4).identity;

            mat[0]  = 1.0 - 2.0 * (y * y + z * z);
            mat[1]  = 2.0 * (x * y + z * w);
            mat[2]  = 2.0 * (x * z - y * w);
            mat[3]  = 0.0;

            mat[4]  = 2.0 * (x * y - z * w);
            mat[5]  = 1.0 - 2.0 * (x * x + z * z);
            mat[6]  = 2.0 * (z * y + x * w);
            mat[7]  = 0.0;

            mat[8]  = 2.0 * (x * z + y * w);
            mat[9]  = 2.0 * (y * z - x * w);
            mat[10] = 1.0 - 2.0 * (x * x + y * y);
            mat[11] = 0.0;

            mat[12] = 0.0;
            mat[13] = 0.0;
            mat[14] = 0.0;
            mat[15] = 1.0;

            return mat;
        }

       /**
        * Convert to 3x3 matrix
        */
        Matrix!(T,3) toMatrix3x3()
        {
            auto mat = Matrix!(T,3).identity;

            mat[0] = 1.0 - 2.0 * (y * y + z * z);
            mat[1] = 2.0 * (x * y + z * w);
            mat[2] = 2.0 * (x * z - y * w);

            mat[3] = 2.0 * (x * y - z * w);
            mat[4] = 1.0 - 2.0 * (x * x + z * z);
            mat[5] = 2.0 * (z * y + x * w);

            mat[6] = 2.0 * (x * z + y * w);
            mat[7] = 2.0 * (y * z - x * w);
            mat[8] = 1.0 - 2.0 * (x * x + y * y);

            return mat;
        }

       /**
        * Setup the quaternion to perform a rotation,
        * given the angular displacement in matrix form
        */
        static Quaternion!(T) fromMatrix(Matrix!(T,4) m)
        {
            Quaternion!(T) q;

            T trace = m.a11 + m.a22 + m.a33 + 1.0;

            if (trace > 0.0001)
            {
                T s = 0.5 / sqrt(trace);
                q.w = 0.25 / s;
                q.x = (m.a23 - m.a32) * s;
                q.y = (m.a31 - m.a13) * s;
                q.z = (m.a12 - m.a21) * s;
            }
            else
            {
                if ((m.a11 > m.a22) && (m.a11 > m.a33))
                {
                    T s = 0.5 / sqrt(1.0 + m.a11 - m.a22 - m.a33);
                    q.x = 0.25 / s;
                    q.y = (m.a21 + m.a12) * s;
                    q.z = (m.a31 + m.a13) * s;
                    q.w = (m.a32 - m.a23) * s;
                }
                else if (m.a22 > m.a33)
                {
                    T s = 0.5 / sqrt(1.0 + m.a22 - m.a11 - m.a33);
                    q.x = (m.a21 + m.a12) * s;
                    q.y = 0.25 / s;
                    q.z = (m.a32 + m.a23) * s;
                    q.w = (m.a31 - m.a13) * s;
                }
                else
                {
                    T s = 0.5 / sqrt(1.0 + m.a33 - m.a11 - m.a22);
                    q.x = (m.a31 + m.a13) * s;
                    q.y = (m.a32 + m.a23) * s;
                    q.z = 0.25 / s;
                    q.w = (m.a21 - m.a12) * s;
                }
            }

            return q;
        }

       /**
        * Setup the quaternion to perform a rotation,
        * given the orientation in XYZ-Euler angles format (in radians)
        */
        static Quaternion!(T) fromEulerAngles(Vector!(T,3) e)
        {
            Quaternion!(T) q;

            T sr = sin(e.x * 0.5);
            T cr = cos(e.x * 0.5);
            T sp = sin(e.y * 0.5);
            T cp = cos(e.y * 0.5);
            T sy = sin(e.z * 0.5);
            T cy = cos(e.z * 0.5);

            q.w =  (cy * cp * cr) + (sy * sp * sr);
            q.x = -(sy * sp * cr) + (cy * cp * sr);
            q.y =  (cy * sp * cr) + (sy * cp * sr);
            q.z = -(cy * sp * sr) + (sy * cp * cr);

            return q;
        }

       /**
        * Setup the Euler angles, given a rotation Quaternion.
        * Returned x,y,z are in radians
        */
        Vector!(T,3) toEulerAngles()
        {
            Vector!(T,3) e;

            e.y = asin(2.0 * ((x * z) + (w * y)));

            T cy = cos(e.y);
            T oneOverCosY = 1.0 / cy;

            if (fabs(cy) > 0.001)
            {
                e.x = atan2(2.0 * ((w * x) - (y * z)) * oneOverCosY,
                           (1.0 - 2.0 *  (x*x + y*y)) * oneOverCosY);
                e.z = atan2(2.0 * ((w * z) - (x * y)) * oneOverCosY,
                           (1.0 - 2.0 *  (y*y + z*z)) * oneOverCosY);
            }
            else
            {
                e.x = 0.0;
                e.z = atan2(2.0 * ((x * y) + (w * z)),
                            1.0 - 2.0 *  (x*x + z*z));
            }

            return e;
        }

       /**
        * Return the rotation angle (in radians)
        */
        T rotationAngle()
        {
            return 2.0 * acos(w);
        }

       /**
        * Return the rotation axis
        */
        Vector!(T,3) rotationAxis()
        {
            T s = sqrt(1.0 - (w * w));

            if (s <= 0.0f)
                return Vector!(T,3)(x, y, z);
            else
                return Vector!(T,3)(x / s, y / s, z / s);
        }

       /**
        * Quaternion as an angular velocity
        */
        Vector!(T,3) generator()
        {
            T s = sqrt(1.0 - (w * w));

            Vector!(T,3) axis;

            if (s <= 0.0)
                axis = Vector!(T,3)(x, y, z);
            else
                axis = Vector!(T,3)(x * s, y * s, z * s);

            T angle = 2.0 * atan2(s, w);

            return axis * angle;
        }
    }
}

/*
 * Predefined quaternion type aliases
 */
/// Alias for single precision Quaternion
alias Quaternionf = Quaternion!(float);
/// Alias for double precision Quaternion
alias Quaterniond = Quaternion!(double);

///
unittest
{
    Quaternionf q1 = Quaternionf(0.0f, 0.0f, 0.0f, 1.0f);
    Vector3f v1 = q1.rotate(Vector3f(1.0f, 0.0f, 0.0f));
    assert(isAlmostZero(v1 - Vector3f(1.0f, 0.0f, 0.0f)));
    
    Quaternionf q2 = Quaternionf.identity;
    assert(isConsiderZero(q2.x));
    assert(isConsiderZero(q2.y));
    assert(isConsiderZero(q2.z));
    assert(isConsiderZero(q2.w - 1.0f));
    
    Quaternionf q3 = Quaternionf([1.0f, 0.0f, 0.0f, 1.0f]);
    Quaternionf q4 = Quaternionf([0.0f, 1.0f, 0.0f, 1.0f]);
    q4 = q3 * q4;
    assert(q4 == Quaternionf(1, 1, 1, 1));
    
    Vector3f v2 = Vector3f(0, 0, 1);
    Quaternionf q5 = Quaternionf(v2, 1.0f);
    q5 *= q5;
    assert(q5 == Quaternionf(0, 0, 2, 0));
    
    Quaternionf q6 = Quaternionf(Vector4f(1, 0, 0, 1));
    Quaternionf q7 = q6 + q6 - Quaternionf(2, 0, 0, 2);
    assert(q7 == Quaternionf(0, 0, 0, 0));
    
    Quaternionf q8 = Quaternionf(0.5f, 0.5f, 0.5f, 0.0f);
    q8.computeW();
    assert(q8.w == -0.5f);
    
    Quaternionf q9 = Quaternionf(0.5f, 0.0f, 0.0f, 0.0f);
    q9 = q9.normalized;
    assert(q9 == Quaternionf(1, 0, 0, 0));
    
    Quaternionf q10 = Quaternionf(0.0f, 0.0f, 0.0f, 1.0f);
    Matrix4f m1 = q10.toMatrix4x4;
    assert(m1 == matrixf(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1)
    );
    
    Matrix3f m2 = q10.toMatrix3x3;
    assert(m2 == matrixf(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1)
    );
}

/**
 * Setup a quaternion to rotate about world axis.
 * Theta must be in radians
 */
Quaternion!(T) rotationQuaternion(T)(uint rotaxis, T theta)
{
    Quaternion!(T) res = Quaternion!(T).identity;
    T thetaOver2 = theta * 0.5;

    switch (rotaxis)
    {
        case Axis.x:
            res.w = cos(thetaOver2);
            res.x = sin(thetaOver2);
            res.y = 0.0;
            res.z = 0.0;
            break;

        case Axis.y:
            res.w = cos(thetaOver2);
            res.x = 0.0;
            res.y = sin(thetaOver2);
            res.z = 0.0;
            break;

        case Axis.z:
            res.w = cos(thetaOver2);
            res.x = 0.0;
            res.y = 0.0;
            res.z = sin(thetaOver2);
            break;

        default:
        assert(0);
    }

    return res;
}

/**
 * Setup a quaternion to rotate about specified axis.
 * Theta must be in radians
 */
Quaternion!(T) rotationQuaternion(T)(Vector!(T,3) rotaxis, T theta)
{
    Quaternion!(T) res;

    T thetaOver2 = theta * 0.5;
    T sinThetaOver2 = sin(thetaOver2);

    res.w = cos(thetaOver2);
    res.x = rotaxis.x * sinThetaOver2;
    res.y = rotaxis.y * sinThetaOver2;
    res.z = rotaxis.z * sinThetaOver2;
    return res;
}

/**
 * Setup a quaternion to represent rotation
 * between two unit-length vectors
 */
Quaternion!(T) rotationBetween(T)(Vector!(T,3) a, Vector!(T,3) b)
{
    Quaternion!(T) q;

    float d = dot(a, b);
    float angle = acos(d);

    Vector!(T,3) axis;
    if (d < -0.9999)
    {
        Vector!(T,3) c;
        if (a.y != 0.0 || a.z != 0.0)
            c = Vector!(T,3)(1, 0, 0);
        else
            c = Vector!(T,3)(0, 1, 0);
        axis = cross(a, c);
        axis.normalize();
        q = rotationQuaternion(axis, angle);
    }
    else if (d > 0.9999)
    {
        q = Quaternion!(T).identity;
    }
    else
    {
        axis = cross(a, b);
        axis.normalize();
        q = rotationQuaternion(axis, angle);
    }

    return q;
}

/**
 * Quaternion logarithm
 */
Quaternion!(T) log(T)(Quaternion!(T) q)
{
    Quaternion!(T) res;
    res.w = 0.0;

    if (fabs(q.w) < 1.0)
    {
        T theta = acos(q.w);
        T sin_theta = sin(theta);

        if (fabs(sin_theta) > 0.00001)
        {
            T thetaOverSinTheta = theta / sin_theta;
            res.x = q.x * thetaOverSinTheta;
            res.y = q.y * thetaOverSinTheta;
            res.z = q.z * thetaOverSinTheta;
            return res;
        }
    }

    res.x = q.x;
    res.y = q.y;
    res.z = q.z;
    return res;
}

/**
 * Quaternion exponential
 */
Quaternion!(T) exp(T) (Quaternion!(T) q)
{
    T theta = sqrt(dot(q, q));
    T sin_theta = sin(theta);
    Quaternion!(T) res;
    res.w = cos(theta);

    if (fabs(sin_theta) > 0.00001)
    {
        T sinThetaOverTheta = sin_theta / theta;
        res.x = q.x * sinThetaOverTheta;
        res.y = q.y * sinThetaOverTheta;
        res.z = q.z * sinThetaOverTheta;
    }
    else
    {
        res.x = q.x;
        res.y = q.y;
        res.z = q.z;
    }

    return res;
}

/**
 * Quaternion exponentiation
 */
Quaternion!(T) pow(T) (Quaternion!(T) q, T exponent)
{
    if (fabs(q.w) > 0.9999)
        return q;
    T alpha = acos(q.w);
    T newAlpha = alpha * exponent;
    Vector!(T,3) n = Vector!(T,3)(q.x, q.y, q.z);
    n *= sin(newAlpha) / sin(alpha);
    return new Quaternion!(T)(n, cos(newAlpha));
}

/**
 * Spherical linear interpolation
 */
Quaternion!(T) slerp(T)(
    Quaternion!(T) q0,
    Quaternion!(T) q1,
    T t)
{
    if (t <= 0.0) return q0;
    if (t >= 1.0) return q1;

    T cosOmega = dot(q0, q1);
    T q1w = q1.w;
    T q1x = q1.x;
    T q1y = q1.y;
    T q1z = q1.z;

    if (cosOmega < 0.0)
    {
        q1w = -q1w;
        q1x = -q1x;
        q1y = -q1y;
        q1z = -q1z;
        cosOmega = -cosOmega;
    }
    assert (cosOmega < 1.1);

    T k0, k1;
    if (cosOmega > 0.9999)
    {
        k0 = 1.0 - t;
        k1 = t;
    }
    else
    {
        T sinOmega = sqrt(1.0 - (cosOmega * cosOmega));
        T omega = atan2(sinOmega, cosOmega);
        T oneOverSinOmega = 1.0 / sinOmega;
        k0 = sin((1.0 - t) * omega) * oneOverSinOmega;
        k1 = sin(t * omega) * oneOverSinOmega;
    }

    Quaternion!(T) res = Quaternion!(T)
    (
        (k0 * q0.x) + (k1 * q1x),
        (k0 * q0.y) + (k1 * q1y),
        (k0 * q0.z) + (k1 * q1z),
        (k0 * q0.w) + (k1 * q1w)
    );
    return res;
}

/**
 * Spherical cubic interpolation
 */
Quaternion!(T) squad(T)(
    Quaternion!(T) q0,
    Quaternion!(T) qa,
    Quaternion!(T) qb,
    Quaternion!(T) q1,
    T t)
{
    T slerp_t = 2.0 * t * (1.0 - t);
    Quaternion!(T) slerp_q0 = slerp(q0, q1, t);
    Quaternion!(T) slerp_q1 = slerp(qa, qb, t);
    return slerp(slerp_q0, slerp_q1, slerp_t);
}

/**
 * Compute intermediate quaternions for building spline segments
 */
Quaternion!(T) intermediate(T)(
    Quaternion!(T) qprev,
    Quaternion!(T) qcurr,
    Quaternion!(T) qnext,
ref Quaternion!(T) qa,
ref Quaternion!(T) qb)
in
{
    assert (dot(qprev, qprev) <= 1.0001);
    assert (dot(qcurr, qcurr) <= 1.0001);
}
do
{
    Quaternion!(T) inv_prev = qprev.conj;
    Quaternion!(T) inv_curr = qcurr.conj;

    Quaternion!(T) p0 = inv_prev * qcurr;
    Quaternion!(T) p1 = inv_curr * qnext;

    Quaternion!(T) arg = (log(p0) - log(p1)) * 0.25;

    qa = qcurr * exp( arg);
    qb = qcurr * exp(-arg);
}

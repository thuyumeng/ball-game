//
//  point3.metal
//  fractal-raytracing
//
//  Created by yumeng on 2023/4/29.
//

#include <metal_stdlib>
using namespace metal;


class vec3 {
    public:
        vec3() : e{0,0,0} {}
        vec3(float e0, float e1, float e2) : e{e0, e1, e2} {}

        float x() const { return e[0]; }
        float y() const { return e[1]; }
        float z() const { return e[2]; }

        vec3 operator-() const { return vec3(-e[0], -e[1], -e[2]); }
        float operator[](int i) const { return e[i]; }
        float operator[](int i) { return e[i]; }

        vec3 operator+=(const device vec3 &v) {
            e[0] += v.e[0];
            e[1] += v.e[1];
            e[2] += v.e[2];
            return *this;
        }

        vec3 operator*=(const float t) {
            e[0] *= t;
            e[1] *= t;
            e[2] *= t;
            return *this;
        }

        vec3 operator/=(const float t) {
            return *this *= 1/t;
        }

        float length() const {
            return sqrt(length_squared());
        }

        float length_squared() const {
            return e[0]*e[0] + e[1]*e[1] + e[2]*e[2];
        }

    public:
        float e[3];
};

vec3 operator*(float t, thread const vec3& v) {
    return vec3(t * v.x(),
                t * v.y(),
                t * v.z());
}

vec3 operator*(thread const vec3& v, float t) {
    return t * v;
}

vec3 operator+(thread const vec3& v1, thread const vec3& v2){
    return vec3(v1.x() + v2.x(),
                v1.y() + v2.y(),
                v1.z() + v2.z());
}

// Type aliases for vec3
using point3 = vec3;   // 3D point
using color = vec3;    // RGB color

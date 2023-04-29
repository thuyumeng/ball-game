//
//  ray.metal
//  fractal-raytracing
//
//  Created by yumeng on 2023/4/29.
//

#include <metal_stdlib>
#include "vec3.metal"
using namespace metal;

class ray {
    public:
        ray() {}
        ray(const device point3& origin, const device vec3& direction, float time = 0.0)
            : orig(origin), dir(direction), tm(time)
        {}

        point3 origin() const  { return orig; }
        vec3 direction() const { return dir; }
        float time() const    { return tm; }

        point3 at(float t) const {
            return orig + t*dir;
        }

    public:
        point3 orig;
        vec3 dir;
        float tm;
};

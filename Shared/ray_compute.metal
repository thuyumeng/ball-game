//
//  ray_compute.metal
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/17.
//

#include <metal_stdlib>
using namespace metal;
struct Vec3{
    float x, y, z;
};

struct Sphere {
    Vec3 center;
    float radius;
};

kernel void
compute_ray(device const Sphere* spheres,
                device const Vec3* eye_positions,
                texture2d<half, access::write> outTexture [[texture(0)]],
                uint2                          gid        [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture
    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height()))
    {
        // Return early if the pixel is out of bounds
        return;
    }
    
    half x_red = half(gid.x) / half(outTexture.get_width());
    half y_blue = half(gid.y) / half(outTexture.get_height());
    outTexture.write(half4(x_red, 0.0, y_blue, 1.0), gid);
}


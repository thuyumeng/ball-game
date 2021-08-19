//
//  ray_compute.metal
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/17.
//

#include <metal_stdlib>
using namespace metal;

//Vec3 相关函数
struct Vec3{
    float x, y, z;
//    Vec3(){
//        x = 0.0;
//        y = 0.0;
//        z = 0.0;
//    }
    Vec3(float x, float y, float z){
        x = x;
        y = y;
        z = z;
    }
};

kernel void
compute_ray(device const Sphere* spheres,
            device const Vec3* eye_positions,
            texture2d<half, access::write> outTexture [[texture(0)]],
            uint2                          gid        [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture
//    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height()))
//    {
//        // Return early if the pixel is out of bounds
//        return;
//    }
    // 设置camera常数
    Vec3 color = Vec3(0.5, 0.7, 1.0);
    outTexture.write(half4(color.x, color.y, color.z, 1.0), gid);
}

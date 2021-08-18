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
    Vec3(){
        x = 0.0;
        y = 0.0;
        z = 0.0;
    }
    Vec3(float x, float y, float z){
        this->x = x;
        this->y = y;
        this->z = z;
    }
};

Vec3 operator+(const Vec3 u, const Vec3 v){
    return Vec3(u.x + v.x,
                u.y + v.y,
                u.z + v.z);
}

Vec3 operator-(const Vec3 u, const Vec3 v){
    return Vec3(u.x - v.x,
                u.y - v.y,
                u.z - v.z);
}

Vec3 operator*(float t, const Vec3 v) {
    return Vec3(t * v.x,
                t * v.y,
                t * v.z);
}

Vec3 operator*(const Vec3 v, float t) {
    return t * v;
}


struct Sphere {
    Vec3 center;
    float radius;
};

struct Ray {
    Vec3 origin;
    Vec3 direction;

    Ray(Vec3 origin, Vec3 direction)
    {
        this->origin = origin;
        this->direction = direction;
    }
};

// 归一化Vec3
Vec3 unit_vector(const Vec3 direction)
{
    float vec_len = length(float3(direction.x,
                      direction.y,
                      direction.z));
    float rcp_len = 1.0 / vec_len;
    Vec3 ret(direction.x * rcp_len,
             direction.y * rcp_len,
             direction.z * rcp_len);
    return ret;
}

// 测试ray color 函数
Vec3 ray_color(const Ray ray)
{
    Vec3 unit_direction = unit_vector(ray.direction);
    float t = 0.5 * (unit_direction.y + 1.0);
    return (1.0 - t) * Vec3(1.0, 1.0, 1.0) + t * Vec3(0.5, 0.7, 1.0);
}

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
    const float aspect_ratio = 16.0 / 9.0;
    const float viewport_height = 2.0;
    const float viewport_width = aspect_ratio * viewport_height;
    const float focal_length = 1.0;
    
    const Vec3 origin = Vec3(0.0, 0.0, 0.0);
    const Vec3 horizontal = Vec3(viewport_width, 0.0, 0.0);
    const Vec3 vertical = Vec3(0.0, viewport_height, 0.0);
    const Vec3 lower_left_corner = origin - 0.5*horizontal - 0.5*vertical - Vec3(0, 0, focal_length);
    
    float u = float(gid.x) / float(outTexture.get_width() - 1);
    float v = float(gid.y) / float(outTexture.get_height() - 1);
    Ray r = Ray(origin, lower_left_corner + u*horizontal + v*vertical - origin);
    Vec3 color = ray_color(r);
    outTexture.write(half4(color.x, color.y, color.z, 1.0), gid);
}


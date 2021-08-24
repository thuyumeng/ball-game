//
//  ray_compute.metal
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/17.
//

#include <metal_stdlib>
#include "random/random_header.metal"
using namespace metal;

// 下面的函数有些用到了引用：https://stackoverflow.com/questions/54665905/how-to-define-functions-with-a-referenced-parameter-in-metal-shader-language-exc
//  以上这片文章很好的解释了如何应用reference和地址空间

#define SAMPLES_PER_PIXEL 100
#define MAX_DEPTH 50
#define PI 3.1415926


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
    
    float length_squared(){
        return x*x + y*y + z*z;
    }
    
    void random(thread TRng& rng, float x_min, float x_max){
        x = rng.rand() * (x_max - x_min) + x_min;
        y = rng.rand() * (x_max - x_min) + x_min;
        z = rng.rand() * (x_max - x_min) + x_min;
    }
};

Vec3 operator+(thread const Vec3& u, thread const Vec3& v){
    return Vec3(u.x + v.x,
                u.y + v.y,
                u.z + v.z);
}

Vec3 operator-(thread const Vec3& u, thread const Vec3& v){
    return Vec3(u.x - v.x,
                u.y - v.y,
                u.z - v.z);
}

Vec3 operator*(float t, thread const Vec3& v) {
    return Vec3(t * v.x,
                t * v.y,
                t * v.z);
}

Vec3 operator*(thread const Vec3& v, float t) {
    return t * v;
}

// 公共函数
float dot(thread const Vec3& u, thread const Vec3& v)
{
    return u.x*v.x + u.y*v.y + u.z*v.z;
}
// 归一化Vec3
Vec3 unit_vector(thread const Vec3& direction)
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

// 产生unit sphere 中的vector
Vec3 random_in_unit_sphere(thread TRng& rng)
{
    float phi = 2.0 * PI * rng.rand();
    float cosTheta = 2.0 * rng.rand() - 1.0;
    float u = rng.rand();

    float theta = acos(cosTheta);
    float r = pow(u, 1.0 / 3.0);

    float x = r * sin(theta) * cos(phi);
    float y = r * sin(theta) * sin(phi);
    float z = r * cos(theta);

    return Vec3(x, y, z);
}


// Ray光线数据结构，就是射线啦。。
struct Ray {
    Vec3 origin;
    Vec3 direction;

    Ray(thread const Vec3& origin, thread const Vec3& direction)
    {
        this->origin = origin;
        this->direction = direction;
    }
    
    Vec3 point_at_parameter(float t) const{
        return origin + t*direction;
    }
};

// 实现两个模块
// 1、hitrecord：记录每次ray intersect的信息
// 2、用于检测和光线相交的Sphere。
// 3、用于光线相交检测的hittable list
struct HitRecord{
    Vec3 p;
    Vec3 normal;
    float t;
    
    HitRecord(){
        p = Vec3();
        normal = Vec3();
        t = 0.0;
    }
    
    void set_face_normal(thread const Ray& ray, thread const Vec3& outward_normal){
        bool front_face = (dot(ray.direction, outward_normal) < 0);
        
        if (front_face)
        {
            normal = outward_normal;
        }
        else{
            normal = -1.0 * outward_normal;
        }
    }
};

struct Sphere {
    Vec3 center;
    float radius;
    
    Sphere(thread const Vec3& center, float radius){
        this->center = center;
        this->radius = radius;
    }
    
    Sphere(device const Vec3& center, float radius){
        this->center = center;
        this->radius = radius;
    }
    
    bool hit(thread const Ray& ray, float t_min, float t_max, thread HitRecord& hit_record) const
    {
        Vec3 oc = ray.origin - center;
        float a = dot(ray.direction, ray.direction);
        float half_b = dot(oc, ray.direction);
        float c = oc.length_squared() - radius*radius;
        
        float discriminant = half_b*half_b - a*c;
        if (discriminant < 0){
            return false;
        }
        
        float sqrtd = sqrt(discriminant);
        float root = (-half_b - sqrtd) / a;
        if (root < t_min || t_max < root){
            root = (-half_b + sqrtd) / a;
            if (root < t_min || t_max < root){
                return false;
            }
        }
        
        hit_record.t = root;
        hit_record.p = ray.point_at_parameter(root);
        hit_record.normal = 1.0 / radius * (hit_record.p - center);
        return true;
    }
};

struct HittableList{
    device const Sphere* spheres;
    int sphere_cnts;
    
    HittableList(device const Sphere* spheres, int sphere_cnts){
        this->spheres = spheres;
        this->sphere_cnts = sphere_cnts;
    }
    
    bool hit(thread const Ray& ray, float t_min, float t_max, thread HitRecord& hit_record) const{
        float hit_anything = false;
        float closet_so_far = t_max;
        HitRecord temp_rec = HitRecord();
        
        for (int i=0; i<sphere_cnts; i++){
            Sphere sphere = Sphere(spheres[i].center, spheres[i].radius);
            if (sphere.hit(ray, t_min, closet_so_far, temp_rec)){
                hit_anything = true;
                closet_so_far = temp_rec.t;
                hit_record = temp_rec;
            }
        }
        return hit_anything;
    }
};


// ray_color 是反射天光的漫反射，每次反射回衰减
Vec3 ray_color(thread const Ray& ray, thread const HittableList& world, thread TRng& rng)
{
    Ray cur_ray = ray;
    float cur_attenuation = 1.0;
    for (int i = 0; i<MAX_DEPTH; i++)
    {
        HitRecord rec;
        if(world.hit(cur_ray, 0.0, INFINITY, rec)){
            Vec3 random_vec;
            Vec3 target = rec.p + rec.normal + random_in_unit_sphere(rng);
            cur_attenuation *= 0.5;
            cur_ray = Ray(rec.p, target-rec.p);
        }
        else{
            Vec3 unit_direction = unit_vector(cur_ray.direction);
            float t = 0.5*(unit_direction.y + 1.0);
            Vec3 c = (1.0 - t)*Vec3(1.0, 1.0, 1.0) + t*Vec3(0.5, 0.7, 1.0);
            return cur_attenuation * c;
            
        }
    }
    return Vec3(0.0, 0.0, 0.0);
}

kernel void
compute_ray(device const Sphere* spheres,
            device const int* sphere_cnts,
            texture2d<half, access::write> outTexture [[texture(0)]],
            uint2                          gid        [[thread_position_in_grid]])
{
    // 设置camera常数
    const float aspect_ratio = 16.0 / 9.0;
    const float viewport_height = 2.0;
    const float viewport_width = aspect_ratio * viewport_height;
    const float focal_length = 1.0;
     
    // 设置渲染ndc坐标，和ray
    const Vec3 origin = Vec3(0.0, 0.0, 0.0);
    const Vec3 horizontal = Vec3(viewport_width, 0.0, 0.0);
    const Vec3 vertical = Vec3(0.0, -1.0*viewport_height, 0.0);
    const Vec3 lower_left_corner = origin - 0.5*horizontal - 0.5*vertical - Vec3(0, 0, focal_length);
    
    // 多采样
    pcg32_random_t rng;
    uint64_t gidx = gid.x;
    uint64_t gidy = gid.y;
    pcg32_srandom_r(&rng, uint64_t(gidx *gidy), uint64_t(gidy));
    
    Vec3 color = Vec3();
    float2 ratio = float2(float(gidx), float(gidy)) /float2(float(outTexture.get_width()), float(outTexture.get_height()));
    TRng trng = TRng(ratio.x, ratio.y);
    for(int i=0; i<SAMPLES_PER_PIXEL; i++)
    {
        float u = (float(gid.x) + trng.rand()) / float(outTexture.get_width() - 1);
        float v = (float(gid.y) + trng.rand()) / float(outTexture.get_height() - 1);
        Ray r = Ray(origin, lower_left_corner + u*horizontal + v*vertical - origin);
        // 设置hittable list
        int cnt = sphere_cnts[0];
        HittableList world = HittableList(spheres, cnt);
        color = color + ray_color(r, world, trng);
    }
    float rcp = 1.0 / float(SAMPLES_PER_PIXEL);
    color = rcp * color;
    float3 final_color = sqrt(float3(color.x,
                                     color.y,
                                     color.z));
//    float3 final_color = float3(
//                                trng.rand(),
//                                trng.rand(),
//                                trng.rand());
//    float3 final_color = float3(randomF(&rng),
//                 randomF(&rng),
//                 randomF(&rng));
    outTexture.write(half4(final_color.x, final_color.y, final_color.z, 1.0), gid);
    
}


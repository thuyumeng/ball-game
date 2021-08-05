//
//  sphere.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/24.
//

import Foundation

class Sphere: Hittable {
    
    var center: Vec3
    var radius: Float
    
    init(center: Vec3, radius: Float)
    {
        self.center = center
        self.radius = radius
    }
    
    func hit(_ ray: Ray, _ t_min: Float, _ t_max: Float, _ hit_record: inout HitRecord) -> Bool {
        let oc = ray.origin - center
        let a = oc.length_squared()
        let half_b = dot(oc, ray.direction)
        let c = oc.length_squared() - radius*radius
        
        let discriminant = half_b*half_b - a*c
        if (discriminant < 0){
            return false
        }
        
        let sqrtd = Float(sqrt(Double(discriminant)))
        var root = (-half_b - sqrtd) / a
        if (root < t_min || t_max < root){
            root = (-half_b + sqrtd) / a
            if (root < t_min || t_max < root){
                return false
            }
        }
        hit_record.t = root
        hit_record.p = ray.point_at_parameter(t:hit_record.t)
        hit_record.normal = 1.0 / radius * (hit_record.p - center)
        return true
    }
}

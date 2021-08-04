//
//  hittable.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/23.
//

import Foundation

struct HitRecord {
    var p: Vec3
    var normal: Vec3
    var t: Float
    init(){
        p = Vec3(x:0.0, y:0.0, z:0.0)
        normal = Vec3(x:0.0, y:0.0, z:0.0)
        t = 0.0
    }
    mutating func set_face_normal(_ ray: Ray, _ outward_normal: Vec3)
    {
        let front_face = (dot(left: ray.direction, outward_normal) < 0)
        if (front_face)
        {
            self.normal = outward_normal
        }
        else{
            self.normal = -1.0 * outward_normal
        }
    }
}

protocol Hittable {
    func hit(_ ray: Ray, _ t_min: Float, _ t_max: Float, _ hit_record: inout HitRecord) -> Bool
}

// hittable_list
// 存储场景中的Hittable Objects的列表
// 通过ray tmin tmax来判断是否可以追踪到Hittable Objects
class HittableList: Hittable{
    var hittable_list: [Hittable]
    
    init(){
        hittable_list = [Hittable]()
    }
    
    // TODO raytracing的hit
    func hit(_ ray: Ray, _ t_min: Float, _ t_max: Float, _ hit_record: inout HitRecord) -> Bool {
        var hit_anything: Bool = false
        var closet_so_far: Float = t_max
        var temp_rec:HitRecord = HitRecord()
        
        for object in hittable_list{
            if object.hit(ray, t_min, closet_so_far, &temp_rec){
                hit_anything = true
                closet_so_far = temp_rec.t
                hit_record = temp_rec
            }
        }
        return hit_anything
    }
    
    // 将新的hittable object加入列表管理
    func add(_ hittable_object: Hittable){
        hittable_list.append(hittable_object)
    }
    
    func clear() {
        hittable_list.removeAll()
    }
}

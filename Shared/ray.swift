//
//  ray.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/22.
//

import Foundation

struct Ray {
    var origin: Vec3
    var direction: Vec3
    
    init(_ origin: Vec3, _ direction: Vec3){
        self.origin = origin
        self.direction = unit_vector(direction)
    }
    
    func point_at_parameter(t: Float) -> Vec3 {
        return origin + t * direction
    }
}

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
    func point_at_parameter(t: Float) -> Vec3 {
        return origin + t * direction
    }
}

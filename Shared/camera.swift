//
//  camera.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/9.
//

import Foundation


class Camera {
    let aspect_ratio: Float = 16.0 / 9.0
    let viewport_height: Float = 2.0
    let focal_length: Float = 1.0
    let viewport_width: Float?
    
    let origin: Vec3 = Vec3(x:0.0, y:0.0, z:0.0)
    let horizontal: Vec3?
    let vertical: Vec3?
    let lower_left_corner: Vec3?
    
    init() {
        viewport_width = aspect_ratio * viewport_height
        horizontal = Vec3(x:viewport_width!, y:0.0, z:0.0)
        // Apple的屏幕坐标是下面的较小所以*-1.0
        vertical = Vec3(x:0.0, y:-1.0*viewport_height, z:0.0)
        lower_left_corner = origin - 0.5*horizontal! - 0.5*vertical! - Vec3(x:0, y:0, z:focal_length)
    }
    
    func get_ray(_ u: Float, _ v: Float) -> Ray {
        let dir = unit_vector(
            lower_left_corner! + u*horizontal! + v*vertical! - origin)
        return Ray(origin,
                   dir)
    }
}


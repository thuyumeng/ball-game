//
//  vec3.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/13.
//

import Foundation

public struct Vec3 {
    var x: Float
    var y: Float
    var z: Float
    init(x: Float, y: Float, z:Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func length_squared() -> Float {
        return x*x + y*y + z*z
    }
}
 
func * (left: Float, right: Vec3) -> Vec3 {
    return Vec3(x: Float(left * right.x), y: left * right.y, z: left * right.z)
}
 
func + (left: Vec3, right: Vec3) -> Vec3 {
    return Vec3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}
 
func - (left: Vec3, right: Vec3) -> Vec3 {
    return Vec3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}
 
func dot (_ left: Vec3, _ right: Vec3) -> Float {
    return Float(left.x * right.x + left.y * right.y + left.z * right.z)
}
 
func unit_vector(_ v: Vec3) -> Vec3 {
    let length : Float = Float(sqrt(dot(v, v)))
    return Vec3(x: v.x/length, y: v.y/length, z: v.z/length)
}


//
//  pixel.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/13.
//

import Foundation
import CoreImage

public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

func ray_color(_ r: Ray, _ hittable_list: HittableList) -> Vec3{
    var hit_rec: HitRecord = HitRecord()
    if hittable_list.hit(r, 0.0, Float.infinity, &hit_rec){
        return 0.5*(hit_rec.normal + Vec3(x:1.0, y:1.0, z:1.0))
    }
    let unit_direction: Vec3 = unit_vector(r.direction)
    let t = 0.5*(unit_direction.y + 1.0)
    return (1.0 - t)*Vec3(x:1.0, y:1.0, z:1.0) + t*Vec3(x:0.5, y:0.7, z:1.0)
}

public func makePixelSet(width: Int, _ height: Int) -> ([Pixel], Int, Int) {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width*height)
    
    // hittable lists
    let hittable_list: HittableList = HittableList()
    let sphere1: Sphere = Sphere(center: Vec3(x:0,y:0,z:-1), radius:0.5)
    let sphere2: Sphere = Sphere(center: Vec3(x:0,y:-100.5,z:-1), radius: 100.0)
    hittable_list.add(sphere1)
    hittable_list.add(sphere2)
    
    // camera
    let lower_left_corner = Vec3(x: -2.0, y: 1.0, z: -1.0)
    let horizontal = Vec3(x: 4.0, y: 0, z: 0)
    let vertical = Vec3(x: 0, y: -2.0, z: 0)
    let origin = Vec3(x:0, y:0, z:0)
    for i in 0..<width {
        for j in 0..<height {
            let u = Float(i) / Float(width)
            let v = Float(j) / Float(height)
            let r = Ray(origin: origin, direction: unit_vector(lower_left_corner + u * horizontal + v * vertical))
            let col = ray_color(r, hittable_list)
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixels[i + j * width] = pixel
        }
    }
    return (pixels, width, height)
}

public func imageFromPixels(pixels: ([Pixel], width: Int, height: Int)) -> CGImage {
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let sizePixel = MemoryLayout<Pixel>.size
    
    let providerRef = CGDataProvider(data:NSData(bytes: pixels.0, length: pixels.0.count * sizePixel))
    let image = CGImage(width:pixels.1, height:pixels.2, bitsPerComponent:bitsPerComponent,
                        bitsPerPixel:bitsPerPixel, bytesPerRow:pixels.1 * sizePixel, space:rgbColorSpace,
                        bitmapInfo:bitmapInfo, provider:providerRef!, decode:nil, shouldInterpolate:true,
                        intent:CGColorRenderingIntent.defaultIntent)
    return image!
}


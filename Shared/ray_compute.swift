//
//  ray_compute.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/16.
//

import Foundation
import Metal
import CoreImage

public struct Vec3 {
    // 生成uniform分布的单位向量,用rejection method采样生成
    static func random_in_unit_sphere() ->Vec3{
        while(true){
            let v = Vec3(x: Float.random(in: -1.0..<1.0),
                         y: Float.random(in: -1.0..<1.0),
                         z: Float.random(in: -1.0..<1.0))
            if (v.length_squared() >= 1) {
                continue
            }
            return v
        }
    }
    
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

struct Material {
    var material_type: UInt32
    var material_color: Vec3
    var fuzz: Float
    var ir: Float
}

struct metal_sphere {
    var center: Vec3
    var radius: Float
    var mtl: Material
}

struct metal_ray {
    var origin: Vec3
    var direction: Vec3
}

struct metal_camera {
    var lookfrom: Vec3
    var lookat: Vec3
    var vup: Vec3
    
    var vfov: Float
    var aspect_ratio: Float
    var aperture: Float
    var focus_dist: Float
}

// 设置materialType
let Diffuse: UInt32 = 0
let Metal: UInt32 = 1
let Dielectric: UInt32 = 2

func random_scene(_ spheres: inout [metal_sphere]) {
    let mtl_ground = Material(material_type:Diffuse,
                              material_color:Vec3(x: 0.8,
                                                  y: 0.3,
                                                  z: 0.3),
                              fuzz:1.0,
                              ir:1.0)
    // 地板
    spheres.append(
        metal_sphere(center: Vec3(x: 0.0,
                                  y: -1000.0,
                                  z: 0.0),
                     radius: 1000.0,
                     mtl:mtl_ground)
    )
    // 随机生成球
    for i in -11...11 {
        for j in -11...11 {
            let choose_mat = Float.random(in: 0.0..<1.0)
            let center = Vec3(x: Float(i) + 0.9*Float.random(in: 0.0..<1.0),
                              y: 0.2,
                              z: Float(j) + 0.9*Float.random(in: 0.0..<1.0))
            let offset = center - Vec3(x:4.0, y:0.2, z:0.0)
            let dist = sqrt(Float(offset.length_squared()))
            if (dist > 0.9)
            {
                if(choose_mat < 0.8){
                    let color = Vec3(x: Float.random(in: 0.0..<1.0),
                                     y: Float.random(in: 0.0..<1.0),
                                     z: Float.random(in: 0.0..<1.0))
                    let sphere_mtl = Material(material_type: Diffuse,
                                              material_color: color,
                                              fuzz: 1.0,
                                              ir: 1.0)
                    spheres.append(
                        metal_sphere(center: center,
                                     radius: 0.2,
                                     mtl: sphere_mtl)
                    )
                } else if(choose_mat < 0.95) {
                    let color = Vec3(x: Float.random(in: 0.5..<1.0),
                                     y: Float.random(in: 0.5..<1.0),
                                     z: Float.random(in: 0.5..<1.0))
                    let fuzz = Float.random(in: 0.0..<0.5)
                    let sphere_mtl = Material(material_type: Metal,
                                              material_color: color,
                                              fuzz: fuzz,
                                              ir: 1.0)
                    spheres.append(
                        metal_sphere(center: center,
                                     radius: 0.2,
                                     mtl: sphere_mtl)
                    )
                } else {
                    let color = Vec3(x: Float.random(in: 0.7..<1.0),
                                     y: Float.random(in: 0.7..<1.0),
                                     z: Float.random(in: 0.7..<1.0))
    
                    let sphere_mtl = Material(material_type: Dielectric,
                                              material_color: color,
                                              fuzz: 1.0,
                                              ir: 1.5)
                    spheres.append(
                        metal_sphere(center: center,
                                     radius: 0.2,
                                     mtl: sphere_mtl)
                    )
                }
            }
        }
    }
    // 生成中间三个球
    let mtl_left = Material(material_type: Diffuse,
                            material_color: Vec3(x: 0.4,
                                                 y: 0.2,
                                                 z: 0.1),
                            fuzz:1.0,
                            ir:1.0)
    spheres.append(
        metal_sphere(center: Vec3(x: -4.0, y: 1.0, z: 0.0),
                     radius: 1.0,
                     mtl: mtl_left))
    
    let mtl_center = Material(material_type: Dielectric,
                              material_color: Vec3(x: 1.0,
                                                   y: 1.0,
                                                   z: 1.0),
                              fuzz:1.0,
                              ir:1.5)
    spheres.append(
        metal_sphere(center: Vec3(x: 0.0, y: 1.0, z: 0.0),
                     radius: 1.0,
                     mtl: mtl_center))
    
    let mtl_right = Material(material_type: Metal,
                             material_color: Vec3(x: 1.0,
                                                  y: 1.0,
                                                  z: 1.0),
                             fuzz:0.0,
                             ir:1.5)
    spheres.append(
        metal_sphere(center: Vec3(x: 4.0, y: 1.0, z: 0.0),
                     radius: 1.0,
                     mtl: mtl_right))
}

func ComputeTexture(_ win_width: Int, _ win_height: Int) -> CGImage{
    var image: CGImage?
    do{
        let device = MTLCreateSystemDefaultDevice()
        let metal_lib = device?.makeDefaultLibrary()
        let metal_func = metal_lib?.makeFunction(name: "compute_ray")
        let func_pso = try device?.makeComputePipelineState(function: metal_func!)
        
        // 设置command queue，command_buffer，compute_encoder
        let cmd_queue = device?.makeCommandQueue()
        let cmd_buff = cmd_queue?.makeCommandBuffer()
        let compute_encoder = cmd_buff?.makeComputeCommandEncoder()
        // 设置compute encoder的pipeline state和输入buffer，或者texture
        // 即将compute shader和输入的数据绑定（笔者的理解)
        compute_encoder?.setComputePipelineState(func_pso!)
        
        // 先创建metal输出的texture
        let texture_descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: Int(win_width), height: Int(win_height),
            mipmapped: false)
        texture_descriptor.usage = MTLTextureUsage.shaderWrite
        texture_descriptor.textureType = MTLTextureType.type2D
        #if os(OSX)
        texture_descriptor.storageMode = MTLStorageMode.managed
        #endif
        let texture = device?.makeTexture(descriptor: texture_descriptor)
        compute_encoder?.setTexture(texture, index: 0)
        
        // 设置hitlist
        var spheres = [metal_sphere]()
        random_scene(&spheres)
        
        let array_size = MemoryLayout<metal_sphere>.size * spheres.count
        let sphere_buffer = device?.makeBuffer(
            bytes: spheres,
            length: array_size,
            options: MTLResourceOptions.storageModeShared)
        compute_encoder?.setBuffer(sphere_buffer, offset: 0, index: 0)
        
        var sphere_cnts = [Int]()
        sphere_cnts.append(spheres.count)
        
        let cnts_buffer = device?.makeBuffer(
            bytes: sphere_cnts,
            length: MemoryLayout<Int>.size,
            options: MTLResourceOptions.storageModeShared)
        compute_encoder?.setBuffer(cnts_buffer, offset:0, index:1)
        
        // Camera参数
        var camera_data = [metal_camera]()
        let from = Vec3(x:13,
                        y:2,
                        z:3)
        let to = Vec3(x: 0,
                      y: 0,
                      z: 0)
        
        let aperture = 0.1
        let focus_dist = 10.0
        
        camera_data.append(
            metal_camera(lookfrom: from,
                         lookat: to,
                         vup: Vec3(x:0,
                                   y:1,
                                   z:0),
                         vfov: 30.0,
                         aspect_ratio: 16.0 / 9.0,
                         aperture: Float(aperture),
                         focus_dist: Float(focus_dist))
        )
        let buf_size = MemoryLayout<metal_camera>.size * camera_data.count
        
        let cam_buffer = device?.makeBuffer(
            bytes: camera_data,
            length: buf_size,
            options: MTLResourceOptions.storageModeShared)
        compute_encoder?.setBuffer(cam_buffer,
                                   offset: 0,
                                   index: 2)
        
        // 设置thread组织形式
        let grid_size = MTLSizeMake(win_width, win_height, 1)
        // metal 这个thread_group_size 应该怎样设置？
        // 参照 https://developer.apple.com/documentation/metal/calculating_threadgroup_and_grid_sizes
        // 这片文章：https://developer.apple.com/documentation/metal/creating_threads_and_threadgroups
        /*  介绍了 grid, threadgroup, simd_group三个层次的thread组织形式，对上面的文章是必不可少的说明补充*/
        let w = func_pso?.threadExecutionWidth
        let h = (func_pso?.maxTotalThreadsPerThreadgroup)! / w!
        let thread_group_size = MTLSizeMake(w!, h, 1)
        compute_encoder?.dispatchThreads(grid_size, threadsPerThreadgroup: thread_group_size)
        //  compute pass encoding结束
        compute_encoder?.endEncoding()
        
        // 同步encoder
        let blit_encoder = cmd_buff?.makeBlitCommandEncoder()
        #if os(OSX)
        blit_encoder?.synchronize(texture: texture!, slice: 0, level: 0)
        #endif
        blit_encoder?.endEncoding()

        // 执行command buffer
        cmd_buff?.commit()
        cmd_buff?.waitUntilCompleted()
 
        var imageBytes = [UInt8](
            repeating: 0,
            count: Int(win_width * win_height * 4))
        
        let region = MTLRegionMake2D(0, 0, win_width, win_height)
        texture!.getBytes(
            UnsafeMutableRawPointer(&imageBytes),
            bytesPerRow: win_width * 4,
            from: region,
            mipmapLevel: 0)
        // 返回texture信息
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let providerRef = CGDataProvider(
            data:NSData(
                bytes: imageBytes,
                length: imageBytes.count))
        image = CGImage(
            width:win_width,
            height:win_height,
            bitsPerComponent:bitsPerComponent,
            bitsPerPixel:bitsPerPixel,
            bytesPerRow:win_width * 4,
            space:rgbColorSpace,
            bitmapInfo:bitmapInfo,
            provider:providerRef!,
            decode:nil,
            shouldInterpolate:true,
            intent:CGColorRenderingIntent.defaultIntent)
    }
    catch {
        print("create function pipeline state failed")
    }
    return image!
}



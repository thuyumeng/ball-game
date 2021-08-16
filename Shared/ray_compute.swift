//
//  ray_compute.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/16.
//

import Foundation
import Metal

func SetUpCompute(){
    do{
        let device = MTLCreateSystemDefaultDevice()
        let metal_lib = device?.makeDefaultLibrary()
        let metal_func = metal_lib?.makeFunction(name: "add_arrays")
        let func_pso = try device?.makeComputePipelineState(function: metal_func!)
        
        // TODO 这里缺少初始化输GPU buffer的代码
        
        // 设置command queue，command_buffer，compute_encoder
        let cmd_queue = device?.makeCommandQueue()
        let cmd_buff = cmd_queue?.makeCommandBuffer()
        let compute_encoder = cmd_buff?.makeComputeCommandEncoder()
        // 设置compute encoder的pipeline state和输入buffer，或者texture
        // 即将compute shader和输入的数据绑定（笔者的理解)
        compute_encoder?.setComputePipelineState(func_pso!)
        // TODO 设置输入输出buffer或者texture
        
        // 设置thread组织形式
        let win_width = 800
        let win_height = 800 / 16 * 9
        let grid_size = MTLSizeMake(win_width, win_height, 1)
        // metal 这个thread_group_size 应该怎样设置？
        let thread_group_size = MTLSizeMake(16, 16, 1)
        compute_encoder?.dispatchThreads(grid_size, threadsPerThreadgroup: thread_group_size)
        //  compute pass encoding结束
        compute_encoder?.endEncoding()
        
        // 执行command buffer
        cmd_buff?.commit()
        
        // 等待command buffer执行完成,一般可以GPU和CPU可以并行协作，这里现等待GPU完成工作
        cmd_buff?.waitUntilCompleted()
        
    }
    catch {
        print("create function pipeline state failed")
    }
    
}



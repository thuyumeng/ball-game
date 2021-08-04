//
//  raytracing_view.swift
//  fractal-raytracing
//
//  Created by yumeng on 2021/7/13.
//

import SwiftUI

struct raytracing_view: View {
    var body: some View {
        // 创建绘制Image
        let width = 800
        let height = 600
        let pixelSet = makePixelSet(width: width, height)
        let image = imageFromPixels(pixels: pixelSet)
        Image(image, scale: 1.0, label:Text("tb"))
    }
}

struct raytracing_view_Previews: PreviewProvider {
    static var previews: some View {
        raytracing_view()
    }
}

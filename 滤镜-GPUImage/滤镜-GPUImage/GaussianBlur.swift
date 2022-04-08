//
//  GaussianBlur.swift
//  滤镜-GPUImage
//
//  Created by GongsiWang on 2022/4/8.
//

import UIKit
import GPUImage

class GaussianBlur {
    
    static func generateBlurImage(_ sourceImage : UIImage) -> UIImage {
            // 1.创建用于处理单张图片(类似于美图秀秀中打开相册中的图片进行处理)
            let processView = GPUImagePicture(image: sourceImage)

            // 2.创建滤镜
            let blurFilter = GPUImageGaussianBlurFilter()
            // 纹理大小
            blurFilter.texelSpacingMultiplier = 2.0
            blurFilter.blurRadiusInPixels = 5.0
            processView?.addTarget(blurFilter)

            // 3.处理图像
            blurFilter.useNextFrameForImageCapture()
            processView?.processImage()

            // 4.获取最新的图像
            return blurFilter.imageFromCurrentFramebuffer()
        }

}

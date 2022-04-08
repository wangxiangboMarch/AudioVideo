//
//  ViewController.swift
//  滤镜-GPUImage
//
//  Created by GongsiWang on 2022/4/8.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate lazy var image = UIImage(named: "1")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageView.image = GaussianBlur.generateBlurImage(image)
        
        sleep(2)
        
        let v = SkinCareCameraViewController()
        self.navigationController?.pushViewController(v, animated: true)
        
    }
    
    @IBAction func grayBlur(_ sender: UIButton) {
        
        let fliter = GPUImageSepiaFilter()
        imageView.image = processImage(fliter: fliter)
    }
    
    @IBAction func katong(_ sender: UIButton) {
        let fliter = GPUImageToonFilter()
        imageView.image = processImage(fliter: fliter)
    }
    
    @IBAction func 素描(_ sender: UIButton) {
        let fliter = GPUImageSketchFilter()
        imageView.image = processImage(fliter: fliter)
    }
    
    @IBAction func 浮雕(_ sender: UIButton) {
        let fliter = GPUImageEmbossFilter()
        imageView.image = processImage(fliter: fliter)
    }
    
    
    fileprivate func processImage(fliter: GPUImageFilter) -> UIImage {
        
        // 1.创建用于处理单张图片(类似于美图秀秀中打开相册中的图片进行处理)
        let processView = GPUImagePicture(image: image)

        processView?.addTarget(fliter)
        // 3.处理图像
        fliter.useNextFrameForImageCapture()
        processView?.processImage()

        // 4.获取最新的图像
        return fliter.imageFromCurrentFramebuffer()
        
    }
}


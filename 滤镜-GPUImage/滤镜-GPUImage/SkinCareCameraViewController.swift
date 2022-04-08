//
//  SkinCareCameraViewController.swift
//  滤镜-GPUImage
//
//  Created by GongsiWang on 2022/4/8.
//

import UIKit
import GPUImage
/// 美颜相机

class SkinCareCameraViewController: UIViewController {

    let imageView: UIImageView = UIImageView()
    
    var camera: GPUImageStillCamera?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        
        
        imageView.frame = view.bounds

        view.addSubview(imageView)
        
        camera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
        camera?.outputImageOrientation = .portrait
        
        let fliter = GPUImageBrightnessFilter()

        fliter.brightness = 0.5

        camera?.addTarget(fliter)

        let showView = GPUImageView(frame: view.bounds)

        view.insertSubview(showView, at: 0)

        fliter.addTarget(showView)

        camera?.startCapture()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let fliter = GPUImageBrightnessFilter()
        
        fliter.brightness = 0.5
        
        camera?.capturePhotoAsImageProcessedUp(toFilter: fliter, withCompletionHandler: { image, error in
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            self.imageView.image = image
            self.camera?.startCapture()
        })
    }
}

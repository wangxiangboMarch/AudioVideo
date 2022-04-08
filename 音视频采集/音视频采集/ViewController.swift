//
//  ViewController.swift
//  音视频采集
//
//  Created by GongsiWang on 2022/3/30.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    /// 创建一个绘画
    fileprivate lazy var session = AVCaptureSession()
    fileprivate var videoOutPut: AVCaptureVideoDataOutput?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    
    fileprivate var vedioInput: AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化视频的输入和输出
        setupVideoSource()
        // 初始化音频的输入和输出
        setupAudioSource()
        // 初始化一个预览图层
        setupPreviewLayer()
    }
    
    
}

extension ViewController {
    
    @IBAction func startCauturing(_ sender: UIButton) {
        // 开始采集
        session.startRunning()
        guard let layer = self.previewLayer else {
            return
        }
        view.layer.insertSublayer(layer, at: 0)
    }
    
    @IBAction func stopCapturing(_ sender: UIButton) {
        // 停止采集
        session.stopRunning()
        previewLayer?.removeFromSuperlayer()
    }
    /// 切换摄像头
    @IBAction func rotateCamera(_ sender: UIButton) {
        
        guard let vedioInput = vedioInput else {
            return
        }
        
        let position: AVCaptureDevice.Position = vedioInput.device.position == .front ? .back : .front
        // 获取对象的输入对象
        guard let device = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first else { return }
        
        // 1.3.通过前置摄像头创建输入设备
        guard let newVideoInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.vedioInput = newVideoInput
        // 移除之前的  添加新的
        session.beginConfiguration()
        session.removeInput(vedioInput )
        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
        }
        session.commitConfiguration()
    }
    
}

extension ViewController {
    
    // 给会话设置视频源（输入源&输出源）
    fileprivate func setupVideoSource() {
        // 1.创建输入
        // 1.1.获取所有的设备（包括前置&后置摄像头）builtInTelephotoCamera,builtInDualCamera,builtInTrueDepthCamera
        guard let device = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first else { return }
        
        // 1.3.通过前置摄像头创建输入设备
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.vedioInput = videoInput
        // 2.创建输出源
        // 2.1.创建视频输出源
        let videoOutput = AVCaptureVideoDataOutput()
        
        // 2.2.设置代理,以及代理方法的执行队列（在代理方法中拿到采集到的数据）
        let queue = DispatchQueue.global()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        self.videoOutPut = videoOutput
        
        // 3.将输入&输出添加到会话中
        addToSession(videoInput, videoOutput)
    }
    
    // 给会话设置音频源（输入源&输出源）
    fileprivate func setupAudioSource() {
        // 1.创建输入
        guard let device = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first else { return }
        guard let audioInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        // 2.创建输出源
        let audioOutput = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        
        addToSession(audioInput, audioOutput)
    }
    
    // 添加预览图层
    fileprivate func setupPreviewLayer() {
        // 1.创建预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        // 2.设置图层的属性
        previewLayer.frame = view.bounds
        
        // 3.将图层添加到view中
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
    
    // 添加到session
    fileprivate func addToSession(_ input: AVCaptureInput,_ output: AVCaptureOutput) {
        // 3.将输入&输出添加到会话中
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
    
    fileprivate func setupMovieOutputFile() {
        
        let fileOutput = AVCaptureMovieFileOutput()
        
        // 开始写入文件
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/app.mp4"
        
        
    }
}


extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if videoOutPut?.connection(with: .video) == connection {
            print("采集到视频数据")
        }else{
            print("采集音频数据")
        }
    }
    
}


/**
 
 <key>NSCameraUsageDescription</key>
 <string>使用相机</string>
 
 @available(iOS 7.0, *)
 open class func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void)
 
 @available(iOS 7.0, *)
 open class func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
 public enum AVAuthorizationStatus : Int {
 //用户尚未授予或拒绝该权限，
 case notDetermined = 0
 //不允许用户访问媒体捕获设备。这个状态通常是看不到的：用于发现设备的`AVCaptureDevice`类方法不会返回用户被限制访问的设备。
 case restricted = 1
 //用户已经明确拒绝了应用访问捕获设备
 case denied = 2
 //用户授予应用访问捕获设备的权限
 case authorized = 3
 }
 
 
 */

//
//  ViewController.swift
//  音视频采集
//
//  Created by GongsiWang on 2022/3/30.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    /// 创建一个会话
    fileprivate lazy var session = AVCaptureSession()
    /// 视频数据输出口
    fileprivate var videoOutPut: AVCaptureVideoDataOutput?
    /// 视频预览层
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    /// 视频的设备（前置摄像头还是后置或者其他）
    fileprivate var vedioInput: AVCaptureDeviceInput?
    /// 音视频的导出
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput?
    
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
        // 如果存在预览层 就直接添加上
        view.layer.insertSublayer(layer, at: 0)
    }
    /// 停止采集
    @IBAction func stopCapturing(_ sender: UIButton) {
        // 停止记录到文件
        movieFileOutput?.stopRecording()
        // 停止采集
        session.stopRunning()
        // 移除预览层
        previewLayer?.removeFromSuperlayer()
    }
    /// 切换摄像头
    @IBAction func rotateCamera(_ sender: UIButton) {
        
        // 0.执行动画
        let rotaionAnim = CATransition()
        rotaionAnim.type =  .fade
        rotaionAnim.subtype = .fromLeft
        rotaionAnim.duration = 0.5
        view.layer.add(rotaionAnim, forKey: nil)
        
        
        // 拿到之前的设备
        guard let vedioInput = vedioInput else {
            return
        }
        // 计算现在要切换的设备（如果之前是前置现在就是后置）
        let position: AVCaptureDevice.Position = vedioInput.device.position == .front ? .back : .front
        // 获取对象的输入对象
        guard let device = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first else { return }
        
        // 通过设备创建输入设备
        guard let newVideoInput = try? AVCaptureDeviceInput(device: device) else { return }
        // 记录当前的设备
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
    /// 存储音视频到文件
    fileprivate func setupMovieOutputFile() {
        // 获取文件的输出对象
        let fileOutput = AVCaptureMovieFileOutput()
        self.movieFileOutput = fileOutput
        // 创建文件路径
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/app.mp4"
        
        let fileUrl = URL(fileURLWithPath: filePath)
        // 获取视频的连接
        let connection = fileOutput.connection(with: .video)
        // 设置视频的稳定模式
        connection?.automaticallyAdjustsVideoMirroring = true
        
        session.beginConfiguration()
        if session.canAddOutput(fileOutput) {
            session.addOutput(fileOutput)
        }
        session.commitConfiguration()
        
        fileOutput.startRecording(to: fileUrl, recordingDelegate: self)
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

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("写入文件完成")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始写入文件")
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

//
//  PKCCamera.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit
import AVFoundation

// MARK: - CameraDirection
enum CameraDirection{
    case front, back
}

class PKCCameraViewController: UIViewController{
    // MARK: - IBOutlet
    @IBOutlet var mainView: UIView!
    @IBOutlet var captureView: UIView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var noneCaptureView: UIView!
    @IBOutlet var light: UIButton!
    
    @IBOutlet var captureBtn1: UIButton!
    @IBOutlet var captureBtn2: UIButton!
    @IBOutlet var captureBtn3: UIButton!
    
    lazy var touchView : UIView = {
        var tv = UIView()
        tv.frame.size = CGSize(width: 120, height: 120)
        tv.layer.cornerRadius = 60
        tv.layer.borderWidth = 2
        tv.layer.borderColor = UIColor.white.cgColor
        tv.backgroundColor = UIColor.clear
        tv.isHidden = true
        return tv
    }()
    
    // MARK: - properties
    var delegate: PKCCropPictureDelegate?
    fileprivate var cameraFilters: [Filter]!
    fileprivate var filterIdx = 0
    
    fileprivate var captureSession = AVCaptureSession()
    fileprivate var captureDeviceInput : AVCaptureDeviceInput?
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var captureDevice : AVCaptureDevice?
    fileprivate let stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var cameraDirection : CameraDirection = .front
    
    
    // MARK: - init
    init() {
        super.init(nibName: "PKCCameraViewController", bundle: Bundle(for: PKCCrop.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
        self.noneCaptureView.addSubview(self.touchView)
        
        self.cameraFilters = PKCCropManager.shared.cameraFilters
        if self.cameraFilters == nil{
            self.cameraFilters = [Filter(name: "Normal", filter: CIFilter(name: "CIColorControls")!)]
        }
        
        //self.captureBtn1.color
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.cameraSelected()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - actions
    @IBAction func leftGestureAction(_ sender: Any){
        if self.filterIdx == 0{
            self.filterIdx = self.cameraFilters.count-1
        }else{
            self.filterIdx -= 1
        }
    }
    
    @IBAction func rightGestureAction(_ sender: Any){
        if self.filterIdx == self.cameraFilters.count-1{
            self.filterIdx = 0
        }else{
            self.filterIdx += 1
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func lightAction(_ sender: Any) {
        if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = !device.isTorchActive
                try device.setTorchModeOnWithLevel(1.0)
                if torchOn{
                    self.light.setImage(UIImage(named: "pkc_crop_light_on.png", in: Bundle(for: PKCCrop.self), compatibleWith: UITraitCollection(displayScale: 1)), for: .normal)
                }else{
                    self.light.setImage(UIImage(named: "pkc_crop_light_off.png", in: Bundle(for: PKCCrop.self), compatibleWith: UITraitCollection(displayScale: 1)), for: .normal)
                }
                device.torchMode = torchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    @IBAction func reverseAction(_ sender: Any) {
        switch self.cameraDirection {
        case .back:
            self.cameraDirection = .front
            break
        default:
            self.cameraDirection = .back
        }
        self.cameraSelected()
    }
    
    @IBAction func captureAction(_ sender: Any) {
        self.saveToCamera()
        self.captureBtn1.backgroundColor = UIColor.white
        self.captureBtn2.backgroundColor = UIColor.lightGray
        self.captureBtn3.backgroundColor = UIColor.white
    }
    @IBAction func captureTouchUp(_ sender: Any) {
        self.captureBtn1.backgroundColor = UIColor.white
        self.captureBtn2.backgroundColor = UIColor.lightGray
        self.captureBtn3.backgroundColor = UIColor.white
    }
    @IBAction func captureTouchDown(_ sender: Any) {
        self.captureBtn1.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        self.captureBtn2.backgroundColor = UIColor.darkGray
        self.captureBtn3.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    @IBAction func imageTouchAction(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        if let device = self.captureDevice {
            do{
                self.touchView.frame.origin = CGPoint(x: point.x-60, y: point.y-60)
                self.touchView.isHidden = false
                UIView.animate(withDuration: TimeInterval(0.3), animations: {
                    self.touchView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                }, completion: { (_) in
                    self.touchView.isHidden = true
                    self.touchView.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
                if self.cameraDirection == .back{
                    let touchPercent = point.x / UIScreen.main.bounds.width
                    try device.lockForConfiguration()
                    device.setFocusModeLockedWithLensPosition(Float(touchPercent), completionHandler: { (time) in
                    })
                    device.unlockForConfiguration()
                }
            }catch{
                print("Touch could not be used")
            }
        }
    }
}


// MARK: - API
extension PKCCameraViewController{
    dynamic fileprivate func cameraSelected(){
        let devices = AVCaptureDevice.devices()
        for device in devices! {
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                if self.cameraDirection == .front{
                    self.light.isHidden = true
                    if((device as AnyObject).position == AVCaptureDevicePosition.front) {
                        self.captureDevice = device as? AVCaptureDevice
                        self.setCaptureCamera()
                        break
                    }
                }else{
                    self.light.isHidden = false
                    self.light.setImage(UIImage(named: "pkc_check_light_off.png", in: Bundle(for: PKCCrop.self), compatibleWith: UITraitCollection(displayScale: 1)), for: .normal)
                    if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                        self.captureDevice = device as? AVCaptureDevice
                        self.setCaptureCamera()
                        break
                    }
                }
            }
        }
    }
    
    dynamic fileprivate func setCaptureCamera(){
        if self.cameraDirection == .back{
            if let device = self.captureDevice {
                do{
                    try device.lockForConfiguration()
                    device.focusMode = .locked
                    device.unlockForConfiguration()
                }catch {
                    print("locaForConfiguration error")
                }
            }
        }
        do{
            if self.captureDeviceInput != nil{
                self.captureSession.removeInput(captureDeviceInput)
            }
            if self.captureSession.isRunning{
                self.captureSession.stopRunning()
            }
            try self.captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice)
            self.captureSession.addInput(captureDeviceInput)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if captureSession.canAddOutput(videoOutput){
                captureSession.addOutput(videoOutput)
            }
            
            self.stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.captureSession.startRunning()
            self.previewLayer?.removeFromSuperlayer()
            self.cameraView.layer.addSublayer(self.previewLayer!)
        }catch{
            print("error")
        }
    }
    
    
    func saveToCamera() {
        let captureSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let captureRect = self.view.bounds
        UIGraphicsBeginImageContextWithOptions(captureSize, false, 0.0)
        self.captureView.drawHierarchy(in: captureRect, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let pkcCropViewController = PKCCropViewController()
        pkcCropViewController.delegate = self
        pkcCropViewController.image = image
        pkcCropViewController.cropType = CropType.camera
        self.present(pkcCropViewController, animated: false, completion: nil)
        
        if self.cameraDirection == .back{
            if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo), device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    try device.setTorchModeOnWithLevel(1.0)
                    self.light.setImage(UIImage(named: "pkc_crop_light_off.png", in: Bundle(for: PKCCrop.self), compatibleWith: UITraitCollection(displayScale: 1)), for: .normal)
                    device.torchMode = .off
                    device.unlockForConfiguration()
                } catch {
                    print("error")
                }
            }
        }
    }
}



// MARK: - extension AVCaptureVideoDataOutputSampleBufferDelegate
extension PKCCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        let filtersValue = self.cameraFilters[self.filterIdx].filter
        filtersValue.setValue(cameraImage, forKey: kCIInputImageKey)
        let image = UIImage(ciImage: filtersValue.value(forKey: kCIOutputImageKey) as! CIImage!)
        let cgImage = convertCIImageToCGImage(inputImage: filtersValue.value(forKey: kCIOutputImageKey) as! CIImage!)
        var transform = CGAffineTransform.identity
        if self.cameraDirection == .front{
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }else{
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        }
        let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: (cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (cgImage?.colorSpace!)!, bitmapInfo: (cgImage?.bitmapInfo.rawValue)!)
        
        context?.concatenate(transform)
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        guard let CGImage = context?.makeImage() else {
            return
        }
        let degreeImage = UIImage(cgImage: CGImage)
        DispatchQueue.main.async{
            self.imageView.image = degreeImage
            self.imageView.transform = CGAffineTransform.identity
        }
    }
}


// MARK: - extension PKCCropPictureDelegate
extension PKCCameraViewController: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropPicture(image)
        self.dismiss(animated: true, completion: nil)
    }
}

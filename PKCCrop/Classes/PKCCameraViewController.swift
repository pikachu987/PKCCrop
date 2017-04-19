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
import MediaPlayer

// MARK: - CameraDirection(카메라 앞, 뒤쪽)
fileprivate enum CameraDirection{
    case front, back
}

class PKCCameraViewController: UIViewController{
    // MARK: - IBOutlet
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var captureView: UIView!
    
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var noneCaptureView: UIView!
    
    @IBOutlet var light: UIButton!
    
    @IBOutlet var captureBtn1: UIButton!
    @IBOutlet var captureBtn2: UIButton!
    @IBOutlet var captureBtn3: UIButton!
    
    // MARK: - properties
    weak var delegate: PKCCropPictureDelegate?
    fileprivate var isLoading = true
    
    //Variables related to camera operation
    //카메라 작동에 관련된 변수들
    fileprivate var captureSession = AVCaptureSession()
    fileprivate var captureDeviceInput : AVCaptureDeviceInput?
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var captureDevice : AVCaptureDevice?
    fileprivate let stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var cameraDirection : CameraDirection = .front
    
    //A UIView to which the scale is applied when the user touches it
    //사용자가 터치했을때 Scale이 적용되는 UIView
    fileprivate lazy var touchView : UIView = {
        var tv = UIView()
        tv.frame.size = CGSize(width: 120, height: 120)
        tv.layer.cornerRadius = 60
        tv.layer.borderWidth = 2
        tv.layer.borderColor = UIColor.white.cgColor
        tv.backgroundColor = UIColor.clear
        tv.isHidden = true
        return tv
    }()
    
    var isView = false
    
    // MARK: - init
    //Import PKCCameraViewController xib file
    //PKCCameraViewController xib파일을 불러온다
    init() {
        super.init(nibName: "PKCCameraViewController", bundle: Bundle(for: PKCCrop.self))
    }
    deinit {
        print("deinit \(self)")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.exitButton.layer.cornerRadius = 20
        self.captureBtn1.layer.cornerRadius = 30
        self.captureBtn2.layer.cornerRadius = 25
        self.captureBtn3.layer.cornerRadius = 20
        self.captureView.layer.cornerRadius = 30
        
        
        self.mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.layoutIfNeeded()
        
        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: -100, width: 0, height: 0))
        self.view.addSubview(volumeView)
        
        self.view.setNeedsLayout()
        
        self.noneCaptureView.addSubview(self.touchView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cameraSelected()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeChanged(notification:)),
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }
    
    
    func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    self.captureAction("" as Any)
                }
            }
        }
    }
    
    //Capture Button Colored to Original State
    //캡쳐버튼 색깔 원래 상태로 변환
    func captureBtnOriginColor(){
        self.captureBtn1.backgroundColor = UIColor.white
        self.captureBtn2.backgroundColor = UIColor.lightGray
        self.captureBtn3.backgroundColor = UIColor.white
    }
    
    
    
    
    // MARK: - actions
    
    
    
    
    //Go back to previous screen
    //이전화면으로 이동
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Camera flash
    //back쪽일때 카메라 플래쉬 적용
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
    
    
    //Camera front and back conversion
    //카메라 앞면과 뒷면 변환
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
    
    //Capture
    //캡쳐하기
    @IBAction func captureAction(_ sender: Any) {
        self.saveToCamera()
        self.captureBtnOriginColor()
    }
    
    
    //Capture button touch end
    //Convert Capture Button Color to Original
    //캡쳐버튼 터치 끝
    //캡쳐버튼 색 원래대로 변환
    @IBAction func captureTouchUp(_ sender: Any) {
        self.captureBtnOriginColor()
    }
    
    //Capture button touch end
    //Capture button color conversion
    //캡쳐버튼 터치 끝
    //캡쳐버튼 색 변환
    @IBAction func captureTouchDown(_ sender: Any) {
        self.captureBtn1.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        self.captureBtn2.backgroundColor = UIColor.darkGray
        self.captureBtn3.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    
    //Touch the camera. TouchView resize
    //카메라 터치. TouchView 크기 변환
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
    //Front and rear camera settings
    //카메라 앞, 뒷면 설정
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
                    self.light.setImage(UIImage(named: "pkc_crop_light_off.png", in: Bundle(for: PKCCrop.self), compatibleWith: UITraitCollection(displayScale: 1)), for: .normal)
                    if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                        self.captureDevice = device as? AVCaptureDevice
                        self.setCaptureCamera()
                        break
                    }
                }
            }
        }
    }
    
    //Camera settings
    //카메라 설정
    dynamic fileprivate func setCaptureCamera(){
        DispatchQueue.main.async {
            do{
                if self.captureDeviceInput != nil{
                    self.captureSession.removeInput(self.captureDeviceInput)
                }
                if self.captureSession.isRunning{
                    self.captureSession.stopRunning()
                }
                try self.captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice)
                self.captureSession.addInput(self.captureDeviceInput)
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer?.frame = self.view.layer.frame
                self.captureSession.startRunning()
                self.previewLayer?.removeFromSuperlayer()
                self.cameraView.layer.addSublayer(self.previewLayer!)
                
                self.stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if self.captureSession.canAddOutput(self.stillImageOutput) {
                    self.captureSession.addOutput(self.stillImageOutput)
                }
                
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
            }catch{
                print("error")
            }
        }
    }
    
    
    
    // MARK: - saveToCamera
    //Capture the image view and move to the crop screen. If the camera is on the back and the flash is activated, it will turn off automatically
    //이미지뷰를 캡쳐를 한 다음 크롭화면으로 이동. 카메라가 뒷면이고 플래시가 작동되어 있으면 자동으로 off를 한다
    func saveToCamera() {
        if self.isLoading{
            return
        }
        self.isLoading = true
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                var image = UIImage(data: imageData!)!.resize(UIScreen.main.bounds.size)
                if self.cameraDirection == .front{
                    image = image?.imageRotatedByDegrees(0, flip: true)
                }
                
                let pkcCropViewController = PKCCropViewController()
                pkcCropViewController.delegate = self
                pkcCropViewController.image = image
                pkcCropViewController.cropType = CropType.camera
                self.show(pkcCropViewController, sender: nil)
                
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
                self.isLoading = false
                
                
            }
        }
    }
}



// MARK: - extension PKCCropPictureDelegate
//Receive the image and pass it to the delegate.
//이미지를 받아서 delegate에 연결된 곳으로 전달한다.
extension PKCCameraViewController: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropPicture(image)
    }
}


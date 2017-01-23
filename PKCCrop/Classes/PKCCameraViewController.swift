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

// MARK: - CameraDirection(카메라 앞, 뒤쪽)
fileprivate enum CameraDirection{
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
    @IBOutlet var filter: UIButton!
    @IBOutlet var filterView: UIView!
    @IBOutlet var filterRight: NSLayoutConstraint!
    @IBOutlet var filterTableView: UITableView!
    
    @IBOutlet var captureBtn1: UIButton!
    @IBOutlet var captureBtn2: UIButton!
    @IBOutlet var captureBtn3: UIButton!
    
    // MARK: - properties
    let interactor = Interactor()
    var delegate: PKCCropPictureDelegate?
    fileprivate var cameraFilters: [Filter]!
    fileprivate var filterIdx = 0
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
        self.cameraFilters = PKCCropManager.shared.cameraFilters
        if self.cameraFilters == nil{
            self.cameraFilters = [Filter(name: "Normal", filter: CIFilter(name: "CIColorControls")!, image: UIImage())]
        }
        if self.cameraFilters.count != 1{
            self.filterTableView.register(UINib(nibName: "PKCCameraFilterCell", bundle: Bundle(for: PKCCrop.self)), forCellReuseIdentifier: "PKCCameraFilterCell")
            self.filterTableView.rowHeight = UITableViewAutomaticDimension
            self.filterTableView.estimatedRowHeight = 100
            self.filterTableView.separatorStyle = .none
            self.filterTableView.delegate = self
            self.filterTableView.dataSource = self
        }else{
            self.filter.isHidden = true
        }
        
        self.noneCaptureView.addSubview(self.touchView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cameraSelected()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.imageView.isHidden = false
            Thread.sleep(forTimeInterval: 0.1)
            self.cameraView.isHidden = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isView = true
        self.filterView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isView = false
        self.filterView.isHidden = true
    }
    
    
    //Capture Button Colored to Original State
    //캡쳐버튼 색깔 원래 상태로 변환
    func captureBtnOriginColor(){
        self.captureBtn1.backgroundColor = UIColor.white
        self.captureBtn2.backgroundColor = UIColor.lightGray
        self.captureBtn3.backgroundColor = UIColor.white
    }
    
    
    
    
    // MARK: - actions
    
    
    
    
    //filter right->left gestureAction
    //Swipe 왼쪽에서 오른쪽 이동 제스쳐, 필터 변환
    @IBAction func leftGestureAction(_ sender: Any){
        self.captureBtnOriginColor()
        if self.filterIdx == 0{
            self.filterIdx = self.cameraFilters.count-1
        }else{
            self.filterIdx -= 1
        }
    }
    
    //filter left->right gestureAction
    //Swipe 오른쪽에서 왼쪽 이동 제스쳐, 필터 변환
    @IBAction func rightGestureAction(_ sender: Any){
        self.captureBtnOriginColor()
        if self.filterIdx == self.cameraFilters.count-1{
            self.filterIdx = 0
        }else{
            self.filterIdx += 1
        }
    }
    
    
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
    
    //Filter button When you touch the filter View View
    //필터버튼 터치하면 필터View 보임
    @IBAction func filterAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { 
            self.filterRight.constant = 0
            self.noneCaptureView.layoutIfNeeded()
            self.noneCaptureView.setNeedsLayout()
        }
    }
    
    //<< Touch disappears when you touch the filter
    //<< 터치하면 필터View 사라짐
    @IBAction func filterCloseAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.filterRight.constant = -100
            self.noneCaptureView.layoutIfNeeded()
            self.noneCaptureView.setNeedsLayout()
        }
    }
    
    //Filter View PanGesture
    //필터View PanGesture
    @IBAction func filterGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended{
            if self.filterRight.constant < -50{
                self.filterRight.constant = -100
                self.noneCaptureView.layoutIfNeeded()
                self.noneCaptureView.setNeedsLayout()
            }else{
                self.filterRight.constant = 0
                self.noneCaptureView.layoutIfNeeded()
                self.noneCaptureView.setNeedsLayout()
            }
        }else{
            let translation = sender.translation(in: self.filterTableView)
            let progress = MenuHelper.calculateProgress(translation, viewBounds: self.filterTableView.bounds, direction: .right)
            self.filterRight.constant = -self.filterTableView.frame.width*progress
            self.noneCaptureView.layoutIfNeeded()
            self.noneCaptureView.setNeedsLayout()
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
    
    
    
    // MARK: - saveToCamera
    //Capture the image view and move to the crop screen. If the camera is on the back and the flash is activated, it will turn off automatically
    //이미지뷰를 캡쳐를 한 다음 크롭화면으로 이동. 카메라가 뒷면이고 플래시가 작동되어 있으면 자동으로 off를 한다
    func saveToCamera() {
        if self.isLoading{
            return
        }
        self.isLoading = true
        let captureSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let captureRect = UIScreen.main.bounds
        
        UIGraphicsBeginImageContextWithOptions(captureSize, false, 0.0)
        self.imageView.drawHierarchy(in: captureRect, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
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



// MARK: - extension AVCaptureVideoDataOutputSampleBufferDelegate
extension PKCCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if self.isView{
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
}


// MARK: - extension PKCCropPictureDelegate
//Receive the image and pass it to the delegate.
//이미지를 받아서 delegate에 연결된 곳으로 전달한다.
extension PKCCameraViewController: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropPicture(image)
    }
}




extension PKCCameraViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cameraFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.cameraFilters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PKCCameraFilterCell", for: indexPath) as! PKCCameraFilterCell
        cell.img.image = row.image
        cell.txt.text = row.name
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tableCellTouch(_:))))
        return cell
    }
    func tableCellTouch(_ sender: UITapGestureRecognizer){
        if let cell = sender.view as? UITableViewCell{
            let indexPath = self.filterTableView.indexPath(for: cell)
            self.filterIdx = (indexPath?.row)!
        }
    }
}
extension PKCCameraViewController: UITableViewDelegate{
    
}

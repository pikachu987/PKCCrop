//
//  Test.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit
import AVFoundation
import Photos


// MARK: - PKCCropDelegate
public protocol PKCCropDelegate: class{
    //Called when the pkcCropAccessPermissionsChange function is set to false and the user has not granted permission.
    //pkcCropAccessPermissionsChange 함수가 false로 설정되 있을때 사용자가 권한허용을 하지 않았을 때 호출됩니다.
    func pkcCropAccessPermissionsDenied(_ type: UIImagePickerControllerSourceType)
    
    //You must put in the ViewController at this time.
    //현재 ViewController을 넣어야 합니다.
    func pkcCropController() -> UIViewController
    
    //The delegate to which the image is passed since the crop.
    //크롭이후 이미지가 전달이 되는 delegate입니다.
    func pkcCropImage(_ image: UIImage)
}

// MARK: - PKCCropPictureDelegate
//This is the delegate used by CropViewController, CameraViewController, and PhotoViewController.
//CropViewController과 CameraViewController, PhotoViewController에서 사용하는 Delegate 입니다.
protocol PKCCropPictureDelegate: class {
    func pkcCropPicture(_ image: UIImage)
}


// MARK: - PKCCrop
open class PKCCrop: NSObject {
    weak open var delegate: PKCCropDelegate?
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    
    open func cameraCrop(){
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized{
            self.openCamera()
        }else if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied{
            self.delegate?.pkcCropAccessPermissionsDenied(.camera)
        }else{
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){ (isAccess) in
                if isAccess{
                    self.openCamera()
                }else{
                    self.delegate?.pkcCropAccessPermissionsDenied(.camera)
                }
            }
        }
    }
    
    
    open func photoCrop(){
        if PHPhotoLibrary.authorizationStatus() == .authorized{
            self.openPhoto()
        }else if PHPhotoLibrary.authorizationStatus() == .denied{
            self.delegate?.pkcCropAccessPermissionsDenied(.photoLibrary)
        }else{
            PHPhotoLibrary.requestAuthorization() { (status) in
                switch status {
                case .authorized:
                    self.openPhoto()
                    break
                default:
                    self.delegate?.pkcCropAccessPermissionsDenied(.photoLibrary)
                }
            }
        }
    }
    
    
    
    open func otherCrop(_ image: UIImage){
        let vc = self.delegate?.pkcCropController()
        let pkcCropViewController = PKCCropViewController()
        pkcCropViewController.delegate = self
        pkcCropViewController.image = image
        pkcCropViewController.cropType = CropType.other
        vc?.present(pkcCropViewController, animated: true, completion: nil)
    }
    
    
    
    func openCamera(){
        let vc = self.delegate?.pkcCropController()
        let pkcCameraViewController = PKCCameraViewController()
        pkcCameraViewController.delegate = self
        let navVC = UINavigationController(rootViewController: pkcCameraViewController)
        navVC.isNavigationBarHidden = true
        navVC.isToolbarHidden = true
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                vc?.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    
    func openPhoto(){
        let vc = self.delegate?.pkcCropController()
        let pkcPhotoViewController = PKCPhotoViewController()
        pkcPhotoViewController.delegate = self
        let navVC = UINavigationController(rootViewController: pkcPhotoViewController)
        navVC.isNavigationBarHidden = true
        navVC.isToolbarHidden = true
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                vc?.present(navVC, animated: true, completion: nil)
            }
        }
    }
}



extension PKCCrop: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropImage(image)
    }
}

// MARK: - CropType
enum CropType{
    case camera, photo, other
}



public enum PKCCropType{
    //freeRate And margin possible
    //자유크롭과 공백을 허용합니다.
    case freeRateAndMargin
    
    //freeRate And margin impossible
    //자유크롭과 공백을 허용하지 않습니다.
    case freeRateAndNoneMargin
    
    //rate And margin impossible
    //비율크롭과 공백을 허용합니다.
    case rateAndMargin
    
    //rate And margin impossible
    //비율크롭과 공백을 허용하지 않습니다.
    case rateAndNoneMargin
    
    //Rate crop and rotate the image. The image is in aspectFill format and the margins disappear. In addition, the rotation function is added. If you want to disable rotation, you can set isRotate to false in PKCCropManager.
    //비율크롭과 이미지를 회전할 수 있습니다. 이미지가 aspectFill 형태로 되며 여백이 사라집니다. 또한 회전기능이 추가됩니다. 회전 기능을 빼시려면 PKCCropManager 에서 isRotate를 false로 하시면 됩니다.
    case rateAndRotate
    
    //Free crop and rotate images. The image is in aspectFill format and the margins disappear. In addition, the rotation function is added. If you want to disable rotation, you can set isRotate to false in PKCCropManager.
    //자유크롭과 이미지를 회전할 수 있습니다. 이미지가 aspectFill 형태로 되며 여백이 사라집니다. 또한 회전기능이 추가됩니다. 회전 기능을 빼시려면 PKCCropManager 에서 isRotate를 false로 하시면 됩니다.
    case freeRateAndRotate
    
    //Ratio is a circle crop that allows cropping and spacing.
    //비율크롭과 공백을 허용한 동그라미 크롭입니다.
    case rateAndMarginCircle
    
    //Ratio is a circle crop that does not allow cropping and spacing.
    //비율크롭과 공백을 허용하지 않는 동그라미 크롭입니다.
    case rateAndNoneMarginCircle
    
    //It is a circle crop which can rotate ratio and image.
    //비율크롭과 이미지를 회전할수 있는 동그라미 크롭입니다.
    case rateAndRotateCircle
}

public class PKCCropManager{
    // MARK: - singleton
    public static let shared = PKCCropManager()
        
    
    //Zoom the image before cropping.
    //크롭 이전에 줌을 합니다.
    open var isZoom : Bool = true
    
    
    
    //An arrow animation appears on the Zoom screen.
    //줌화면에서 화살표 애니메이션이 나옵니다.
    open var isZoomAnimation: Bool = true
    
    
    
    
    //Added in rateAndRotate and freeRateAndRotate and rateAndRotateCircle. If this value is set to true, the image rotation function is added.
    //rateAndRotate, rateAndRotateCircle freeRateAndRotate에서 추가된 기능입니다. 이 값을 true로 하면 이미지 회전 기능이 추가됩니다.
    open var isRotate : Bool = true
    
    
    
    //Set the crop type
    //크롭 타입을 설정합니다.
    open var cropType: PKCCropType = PKCCropType.freeRateAndMargin
    
    
    
    //Set the crop ratio.
    //크롭비율을 설정합니다.
    open func setRate(rateWidth: CGFloat, rateHeight: CGFloat) -> Bool{
        if rateWidth/rateHeight < 2 && rateHeight/rateWidth < 2{
            PKCCropManager.shared.rateWidth = rateWidth
            PKCCropManager.shared.rateHeight = rateHeight
            return true
        }else{
            //크롭 width와 height의 비율을 두배 이상 하면 적용이 되지 않습니다.
            //가능한 비율 : ex) 1:1, 2:3, 3:1, 3:2, 3:4, 3:5, 4:3, 4:5, 16:9 ........
            print("Do not make the difference between width and height more than twice")
            return false
        }
    }
    var rateWidth: CGFloat = 1
    var rateHeight: CGFloat = 1
}

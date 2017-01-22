//
//  Test.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit
import PKCCheck


// MARK: - PKCCropDelegate
@objc public protocol PKCCropDelegate{
    //If this function is set to false, the setting window will not be displayed automatically when the user does not give permission. If it is set to true or not, the setting window will be automatically opened.
    @objc optional func pkcCropAccessPermissionsChange() -> Bool
    
    //Called when the pkcCropAccessPermissionsChange function is set to false.
    @objc optional func pkcCropAccessPermissionsDenied()
    
    //You must put in the ViewController at this time.
    func pkcCropController() -> UIViewController
    
    func pkcCropImage(_ image: UIImage)
}

// MARK: - PKCCropPictureDelegate
protocol PKCCropPictureDelegate {
    func pkcCropPicture(_ image: UIImage)
}


// MARK: - PKCCrop
open class PKCCrop: NSObject {
    weak open var delegate: PKCCropDelegate?
    
    fileprivate var pkcCheck: PKCCheck = PKCCheck()
    
    
    
    // MARK: - init
    public override init() {
        super.init()
        self.pkcCheck.delegate = self
    }
    
    
    open func cameraOpen(){
        self.pkcCheck.cameraAccessCheck()
    }
    open func photoOpen(){
        self.pkcCheck.photoAccessCheck()
    }
    open func otherOpen(_ image: UIImage){
        let vc = self.delegate?.pkcCropController()
        let pkcCropViewController = PKCCropViewController()
        pkcCropViewController.delegate = self
        pkcCropViewController.image = image
        pkcCropViewController.cropType = CropType.camera
        vc?.present(pkcCropViewController, animated: true, completion: nil)
    }
}

// MARK: - extension PKCCheckDelegate
extension PKCCrop: PKCCheckDelegate{
    public func pkcCheckCameraPermissionDenied() {
        let change = self.delegate?.pkcCropAccessPermissionsChange?()
        if change == nil || change == true{
            self.pkcCheck.permissionsChange()
        }else{
            self.delegate?.pkcCropAccessPermissionsDenied?()
        }
    }
    
    public func pkcCheckCameraPermissionGranted() {
        let vc = self.delegate?.pkcCropController()
        let pkcCameraViewController = PKCCameraViewController()
        pkcCameraViewController.delegate = self
        let navVC = UINavigationController(rootViewController: pkcCameraViewController)
        navVC.isNavigationBarHidden = true
        navVC.isToolbarHidden = true
        vc?.present(navVC, animated: true, completion: nil)
    }
    
    public func pkcCheckPhotoPermissionDenied() {
        let change = self.delegate?.pkcCropAccessPermissionsChange?()
        if change == nil || change == true{
            self.pkcCheck.permissionsChange()
        }else{
            self.delegate?.pkcCropAccessPermissionsDenied?()
        }
    }
    
    public func pkcCheckPhotoPermissionGranted() {
        let vc = self.delegate?.pkcCropController()
        let pkcPhotoViewController = PKCPhotoViewController()
        pkcPhotoViewController.delegate = self
        vc?.present(pkcPhotoViewController, animated: true, completion: nil)
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


// MARK: - Filter
public struct Filter{
    var name: String
    var filter: CIFilter
    var image: UIImage
}


public class PKCCropManager{
    // MARK: - singleton
    public static let shared = PKCCropManager()
    
    //When you insert a filter, the camera switches to the filter you selected when swiping.
    lazy open var cameraFilters : [Filter] = {
        var array = [Filter]()
        array.append(Filter(name: "Normal", filter: CIFilter(name: "CIColorControls")!, image: UIImage(named: "pkc_crop_filter_nomal.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Mono", filter: CIFilter(name: "CIPhotoEffectMono")!, image: UIImage(named: "pkc_crop_filter_mono.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Chrome", filter: CIFilter(name: "CIPhotoEffectChrome")!, image: UIImage(named: "pkc_crop_filter_chrome.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Fade", filter: CIFilter(name: "CIPhotoEffectFade")!, image: UIImage(named: "pkc_crop_filter_fade.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Instant", filter: CIFilter(name: "CIPhotoEffectInstant")!, image: UIImage(named: "pkc_crop_filter_instant.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Noir", filter: CIFilter(name: "CIPhotoEffectNoir")!, image: UIImage(named: "pkc_crop_filter_noir.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Process", filter: CIFilter(name: "CIPhotoEffectProcess")!, image: UIImage(named: "pkc_crop_filter_process.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Tonal", filter: CIFilter(name: "CIPhotoEffectTonal")!, image: UIImage(named: "pkc_crop_filter_tonal.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Transfer", filter: CIFilter(name: "CIPhotoEffectTransfer")!, image: UIImage(named: "pkc_crop_filter_transfer.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        return array
    }()
    
    open var rateWidth = 1
    open var rateHeight = 1
    
    //Zoom the image before cropping.
    open var isZoom : Bool = true
}

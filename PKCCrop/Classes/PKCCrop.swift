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
        vc?.present(pkcCameraViewController, animated: true, completion: nil)
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
}


public class PKCCropManager{
    // MARK: - singleton
    public static let shared = PKCCropManager()
    
    //When you insert a filter, the camera switches to the filter you selected when swiping.
    open var cameraFilters : [Filter] = [
        Filter(name: "Normal", filter: CIFilter(name: "CIColorControls")!),
        Filter(name: "Mono", filter: CIFilter(name: "CIPhotoEffectMono")!),
        Filter(name: "Chrome", filter: CIFilter(name: "CIPhotoEffectChrome")!),
        Filter(name: "Fade", filter: CIFilter(name: "CIPhotoEffectFade")!),
        Filter(name: "Instant", filter: CIFilter(name: "CIPhotoEffectInstant")!),
        Filter(name: "Noir", filter: CIFilter(name: "CIPhotoEffectNoir")!),
        Filter(name: "Process", filter: CIFilter(name: "CIPhotoEffectProcess")!),
        Filter(name: "Tonal", filter: CIFilter(name: "CIPhotoEffectTonal")!),
        Filter(name: "Transfer", filter: CIFilter(name: "CIPhotoEffectTransfer")!)
    ]
    
    //Zoom the image before cropping.
    open var isZoom : Bool = true
}

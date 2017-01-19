//
//  PKCPhotoViewController.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit

class PKCPhotoViewController: UIViewController{
    // MARK: - properties
    var delegate: PKCCropPictureDelegate?
    
    // MARK: - init
    init() {
        super.init(nibName: "PKCPhotoViewController", bundle: Bundle(for: PKCCrop.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

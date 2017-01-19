//
//  ViewController.swift
//  PKCCrop
//
//  Created by pikachu987 on 01/19/2017.
//  Copyright (c) 2017 pikachu987. All rights reserved.
//

import UIKit
import PKCCrop

class ViewController: UIViewController {
    let pkcCrop = PKCCrop()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pkcCrop.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraAction(_ sender: Any) {
        self.pkcCrop.cameraOpen()
    }
    @IBAction func galleryAction(_ sender: Any) {
        self.pkcCrop.photoOpen()
    }
}

extension ViewController: PKCCropDelegate{
    func pkcCropAccessPermissionsChange() -> Bool {
        
        return true
    }
    func pkcCropAccessPermissionsDenied() {
        
    }
    
    func pkcCropController() -> UIViewController {
        return self
    }
}


//
//  ViewController.swift
//  PKCCrop
//
//  Created by pikachu987 on 08/26/2017.
//  Copyright (c) 2017 pikachu987. All rights reserved.
//

import UIKit
import PKCCrop

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var widthConst: NSLayoutConstraint!
    @IBOutlet fileprivate weak var heightConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "PKCCrop"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.cropAction(_:)))
        
        PKCCropHelper.shared.degressBeforeImage = UIImage(named: "pkc_crop_rotate_left.png")
        PKCCropHelper.shared.degressAfterImage = UIImage(named: "pkc_crop_rotate_right.png")
        
        DispatchQueue.main.async {
            self.cropAction()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc private func cropAction(_ sender: UIBarButtonItem){
        self.cropAction()
    }
    
    private func cropAction(){
        let alertController = UIAlertController(title: "", message: "choice type", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Open Gallery", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Image 1", style: .default, handler: { (_) in
            PKCCropHelper.shared.isNavigationBarShow = false
            let cropVC = PKCCropViewController(UIImage(named: "image.jpeg")!)
            cropVC.delegate = self
            self.navigationController?.pushViewController(cropVC, animated: true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}



extension ViewController: PKCCropDelegate{
    //return Crop Image & Original Image
    func pkcCropImage(_ image: UIImage?, originalImage: UIImage?) {
        if let image = image{
            self.widthConst.constant = image.size.width
            self.heightConst.constant = image.size.height
        }
        self.imageView.image = image
    }
    
    //If crop is canceled
    func pkcCropCancel(_ viewController: PKCCropViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    //Successful crop
    func pkcCropComplete(_ viewController: PKCCropViewController) {
        if viewController.tag == 0{
            viewController.navigationController?.popViewController(animated: true)
        }else{
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}





extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            return
        }
        PKCCropHelper.shared.isNavigationBarShow = true
        let cropVC = PKCCropViewController(image, tag: 1)
        cropVC.delegate = self
        picker.pushViewController(cropVC, animated: true)
    }
}

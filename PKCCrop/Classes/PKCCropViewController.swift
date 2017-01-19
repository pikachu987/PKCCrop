//
//  PKCCropViewController.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit

class PKCCropViewController: UIViewController{
    var delegate: PKCCropPictureDelegate?
    var image: UIImage!
    var imageView: UIImageView!
    var cropType: CropType!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var cropStart: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var zoomHelpWidth: NSLayoutConstraint!
    @IBOutlet var zoomHelpHeight: NSLayoutConstraint!
    @IBOutlet var zoomHelpView: UIView!
    // MARK: - init
    init() {
        super.init(nibName: "PKCCropViewController", bundle: Bundle(for: PKCCrop.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
        self.imageView = UIImageView(image: self.image)
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.showsVerticalScrollIndicator = true
        self.scrollView.flashScrollIndicators()
        self.scrollView.subviews.forEach({$0.removeFromSuperview()})
        self.scrollView.addSubview(self.imageView)
        
        if !PKCCropManager.shared.isZoom{
            self.scrollView.isUserInteractionEnabled = false
            self.cropStart.isHidden = true
            self.zoomHelpView.isHidden = true
            self.crop()
        }else{
            UIView.animate(withDuration: 3, animations: {
                self.zoomHelpWidth.constant = self.view.frame.width
                self.zoomHelpHeight.constant = self.view.frame.width
                self.mainView.layoutIfNeeded()
                self.mainView.setNeedsLayout()
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.zoomHelpView.alpha = 0
                }, completion: { (_) in
                    self.zoomHelpView.isHidden = true
                })
            })
        }
    }
    
    func crop(){
    
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func backAction(_ sender: Any) {
        let animated = (self.cropType == CropType.camera) ? false : true
        if !PKCCropManager.shared.isZoom{
            self.dismiss(animated: animated, completion: nil)
        }else{
            if self.cropStart.alpha == 1{
                self.dismiss(animated: animated, completion: nil)
            }else{
                UIView.animate(withDuration: 0.5) {
                    self.cropStart.alpha = 1
                }
            }
        }
    }
    @IBAction func cropAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { 
            self.cropStart.alpha = 0
        }
    }
}

extension PKCCropViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

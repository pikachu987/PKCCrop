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
    var touchPoint: CGPoint!
    
    var cropWidthValue: CGFloat!
    var cropHeightValue: CGFloat!
    
    //PKCropViewController View
    @IBOutlet var mainView: UIView!
    
    //Crop View
    @IBOutlet var captureView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollTop: NSLayoutConstraint!
    
    @IBOutlet var cropView: UIView!
    @IBOutlet var maskRectView: UIView!
    
    @IBOutlet var cropTop: NSLayoutConstraint!
    @IBOutlet var cropLeft: NSLayoutConstraint!
    @IBOutlet var cropRight: NSLayoutConstraint!
    @IBOutlet var cropBottom: NSLayoutConstraint!
    
    @IBOutlet var maskTop: NSLayoutConstraint!
    @IBOutlet var maskLeft: NSLayoutConstraint!
    @IBOutlet var maskRight: NSLayoutConstraint!
    @IBOutlet var maskBottom: NSLayoutConstraint!
    
    @IBOutlet var zoomHelpWidth: NSLayoutConstraint!
    @IBOutlet var zoomHelpHeight: NSLayoutConstraint!
    @IBOutlet var zoomHelpView: UIView!
    
    @IBOutlet var cropTopLeft: UIImageView!
    @IBOutlet var cropTopRight: UIImageView!
    @IBOutlet var cropBottomLeft: UIImageView!
    @IBOutlet var cropBottomRight: UIImageView!
    @IBOutlet var cropTopLeftBtn: UIButton!
    @IBOutlet var cropTopRightBtn: UIButton!
    @IBOutlet var cropBottomLeftBtn: UIButton!
    @IBOutlet var cropBottomRightBtn: UIButton!
    
    //PKCCropCrop
    @IBOutlet var crop: UIButton!
    var isCurrentCrop = false
    
    // MARK: - init
    init() {
        super.init(nibName: "PKCCropViewController", bundle: Bundle(for: PKCCrop.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cropType == CropType.other{
            self.scrollTop.constant = 0
        }
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        self.mainView.layoutIfNeeded()
        self.mainView.setNeedsLayout()
        self.imageView = UIImageView(image: self.image)
        self.imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.imageView.contentMode = .scaleAspectFit
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.showsVerticalScrollIndicator = true
        self.scrollView.flashScrollIndicators()
        self.scrollView.subviews.forEach({$0.removeFromSuperview()})
        self.scrollView.addSubview(self.imageView)
        self.maskRectView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.cropTopLeft.image = UIImage(named: "pkc_crop_top_left.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.cropTopRight.image = UIImage(named: "pkc_crop_top_right.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.cropBottomLeft.image = UIImage(named: "pkc_crop_bottom_left.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.cropBottomRight.image = UIImage(named: "pkc_crop_bottom_right.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.touchImageNomal()
        
        if !PKCCropManager.shared.isZoom{
            self.scrollView.isUserInteractionEnabled = false
            self.crop.setImage(UIImage(named: "pkc_crop_check.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil), for: .normal)
            self.zoomHelpView.isHidden = true
            if self.cropType != CropType.photo{
                self.cropStart()
            }
        }else{
            self.crop.setImage(UIImage(named: "pkc_crop_crop.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil), for: .normal)
            if PKCCropManager.shared.isZoomAnimation{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.zoomAnimation()
                })
            }else{
                self.zoomHelpView.isHidden = true
            }
        }
    }
    
    func changeImage(_ image: UIImage){
        self.image = image
        self.imageView.image = self.image
        if !PKCCropManager.shared.isZoom{
            self.cropStart()
        }
    }
    
    func cropStart(){
        self.scrollView.isUserInteractionEnabled = false
        self.maskRectView.isHidden = false
        self.cropView.isHidden = false
        
        func cropCont(w: CGFloat, h: CGFloat){
            self.cropLeft.constant = (UIScreen.main.bounds.width - w)/2
            self.cropRight.constant = (UIScreen.main.bounds.width - w)/2
            self.cropTop.constant = (UIScreen.main.bounds.height - h)/2
            self.cropBottom.constant = (UIScreen.main.bounds.height - h)/2
        }
        
        if PKCCropManager.shared.cropType == .freeRateAndMargin || PKCCropManager.shared.cropType == .freeRateAndNoneMargin{
            //자율크롭
            let iframe = self.imageView.frameForImageInImageViewAspectFit()
            let isRate = iframe.width/UIScreen.main.bounds.width < iframe.height/UIScreen.main.bounds.height
            if isRate && iframe.width < 250{
                cropCont(w: iframe.width, h: iframe.width)
            }else if !isRate && iframe.height < 250{
                cropCont(w: iframe.height, h: iframe.height)
            }
        }else{
            //비율크롭
            let iframe = self.imageView.frameForImageInImageViewAspectFit()
            let widthRate = iframe.width/PKCCropManager.shared.rateWidth
            let heightRate = iframe.height/PKCCropManager.shared.rateHeight
            var heightValue = iframe.height
            var widthValue = iframe.width
            func widValue(_ val: CGFloat){
                heightValue = val
                widthValue = heightValue*PKCCropManager.shared.rateWidth/PKCCropManager.shared.rateHeight
            }
            func heiValue(_ val: CGFloat){
                widthValue = val
                heightValue = widthValue*PKCCropManager.shared.rateHeight/PKCCropManager.shared.rateWidth
            }
            if widthRate > heightRate{
                widValue(300)
            }else{
                heiValue(300)
            }
            if heightValue > 300{
                widValue(300)
            }
            if widthValue > 300{
                heiValue(300)
            }
            if heightValue < 200{
                widValue(200)
            }
            if widthValue < 200{
                heiValue(200)
            }
            cropCont(w: widthValue, h: heightValue)
        }
        
        if PKCCropManager.shared.cropType == .freeRateAndMargin || PKCCropManager.shared.cropType == .freeRateAndNoneMargin{
            //공백있게
            self.cropWidthValue = -20
            self.cropHeightValue = -20
        }else{
            //공백없게
            var iframe = self.imageView.frameForImageInImageViewAspectFit()
            let cropWidth = UIScreen.main.bounds.width - self.cropLeft.constant - self.cropRight.constant
            let cropHeight = UIScreen.main.bounds.height - self.cropTop.constant - self.cropBottom.constant

            if iframe.width < cropWidth{
                let cropHei = iframe.width*UIScreen.main.bounds.height/UIScreen.main.bounds.width
                self.image = self.image.crop(to: CGSize(width: iframe.width, height: cropHei))
                self.imageView.image = self.image
                iframe = self.imageView.frameForImageInImageViewAspectFit()
            }else if iframe.height < cropHeight{
                let cropWid = iframe.height*UIScreen.main.bounds.width/UIScreen.main.bounds.height
                self.image = self.image.crop(to: CGSize(width: cropWid, height: iframe.height))
                self.imageView.image = self.image
                iframe = self.imageView.frameForImageInImageViewAspectFit()
            }
            
            self.cropWidthValue = -20+(UIScreen.main.bounds.width-iframe.width)/2
            self.cropHeightValue = -20+(UIScreen.main.bounds.height-iframe.height)/2
        }
        
        self.resize()
    }
    
    func resize(){
        self.maskTop.constant = self.cropTop.constant+15
        self.maskLeft.constant = self.cropLeft.constant+15
        self.maskRight.constant = self.cropRight.constant+15
        self.maskBottom.constant = self.cropBottom.constant+15
        self.setMaskRect(CGRect(x: self.cropLeft.constant+20, y: self.cropTop.constant+20, width: UIScreen.main.bounds.width-self.cropLeft.constant-self.cropRight.constant-40, height: UIScreen.main.bounds.height-self.cropTop.constant-self.cropBottom.constant-40))
        self.cropView.layoutIfNeeded()
        self.cropView.setNeedsLayout()
        self.maskRectView.layoutIfNeeded()
        self.maskRectView.setNeedsLayout()
    }
    
    func setMaskRect(_ frame: CGRect, corner: CGFloat = 0){
        let path = UIBezierPath(roundedRect: frame, cornerRadius: corner)
        path.append(UIBezierPath(rect: self.maskRectView.frame))
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = path.cgPath
        self.maskRectView.layer.mask = maskLayer
    }
    
    func zoomAnimation(){
        UIView.animate(withDuration: 1, animations: {
            self.zoomHelpWidth.constant = UIScreen.main.bounds.width
            self.zoomHelpHeight.constant = UIScreen.main.bounds.width
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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func backAction(_ sender: Any) {
        if !PKCCropManager.shared.isZoom{
            if self.cropType == CropType.other{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            if self.isCurrentCrop{
                self.isCurrentCrop = false
                self.maskRectView.isHidden = true
                self.cropView.isHidden = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.crop.alpha = 0
                }, completion: { (_) in
                    self.crop.setImage(UIImage(named: "pkc_crop_crop.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil), for: .normal)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.crop.alpha = 1
                    })
                })
                self.scrollView.isUserInteractionEnabled = true
            }else{
                if self.cropType == CropType.other{
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    @IBAction func cropAction(_ sender: Any) {
        if !PKCCropManager.shared.isZoom{
            self.imageCrop()
        }else{
            if self.isCurrentCrop{
                self.imageCrop()
            }else{
                self.cropStart()
                self.isCurrentCrop = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.crop.alpha = 0
                }, completion: { (_) in
                    self.crop.setImage(UIImage(named: "pkc_crop_check.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil), for: .normal)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.crop.alpha = 1
                    })
                })
            }
        }
    }
    
    
    func imageCrop(){
        let captureSize = CGSize(width: self.cropWidth()-40, height: self.cropHeight()-40)
        let captureRect = CGRect(
            x: -self.cropLeft.constant-20,
            y: -self.cropTop.constant-20,
            width: self.captureView.frame.width,
            height: self.captureView.frame.height
        )
        
        UIGraphicsBeginImageContextWithOptions(captureSize, false, 0.0)
        self.captureView.drawHierarchy(in: captureRect, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.delegate?.pkcCropPicture(image!)
        self.dismiss(animated: true, completion: nil)
    }
}









// MARK: - CropTouchAction
extension PKCCropViewController{
    @IBAction func touchCancelAction(_ sender: UIButton, forEvent event: UIEvent) {
        self.touchPoint = nil
        self.touchImageNomal()
    }
    @IBAction func touchDownAction(_ sender: UIButton, forEvent event: UIEvent) {
        if let touch = event.touches(for: sender)?.first {
            self.touchPoint = touch.previousLocation(in: self.cropView)
            if sender == self.cropTopLeftBtn{
                self.cropTopLeft.tintColor = UIColor.gray
            }else if sender == self.cropTopRightBtn{
                self.cropTopRight.tintColor = UIColor.gray
            }else if sender == self.cropBottomLeftBtn{
                self.cropBottomLeft.tintColor = UIColor.gray
            }else if sender == self.cropBottomRightBtn{
                self.cropBottomRight.tintColor = UIColor.gray
            }
        }
    }
    
    func touchImageNomal(){
        self.cropTopLeft.tintColor = UIColor.white
        self.cropTopRight.tintColor = UIColor.white
        self.cropBottomLeft.tintColor = UIColor.white
        self.cropBottomRight.tintColor = UIColor.white
    }
    
    func touchPoint(_ sender: UIButton, forEvent event: UIEvent, dragType: DragType) -> CGSize!{
        if let touch = event.touches(for: sender)?.first {
            guard self.touchPoint != nil else {
                return nil
            }
            let point : CGPoint = touch.previousLocation(in: self.cropView)
            var addWidth = self.touchPoint.x - point.x
            var addHeight = self.touchPoint.y - point.y
            self.touchPoint = point
            if dragType != .center && (PKCCropManager.shared.cropType == .rateAndMargin || PKCCropManager.shared.cropType == .rateAndNoneMargin){
                if abs(addWidth) > abs(addHeight){
                    if dragType == .topRight || dragType == .bottomLeft{
                        addHeight = -addWidth*PKCCropManager.shared.rateHeight/PKCCropManager.shared.rateWidth
                    }else{
                        addHeight = addWidth*PKCCropManager.shared.rateHeight/PKCCropManager.shared.rateWidth
                    }
                }else{
                    if dragType == .topRight || dragType == .bottomLeft{
                        addWidth = -addHeight*PKCCropManager.shared.rateWidth/PKCCropManager.shared.rateHeight
                    }else{
                        addWidth = addHeight*PKCCropManager.shared.rateWidth/PKCCropManager.shared.rateHeight
                    }
                    
                }
            }
            return CGSize(width: addWidth, height: addHeight)
        }else{
            return nil
        }
    }
    
    func cropWidth() -> CGFloat{
        return UIScreen.main.bounds.width - (self.cropLeft.constant+self.cropRight.constant)
    }
    
    func cropHeight() -> CGFloat{
        return UIScreen.main.bounds.height - (self.cropTop.constant+self.cropBottom.constant)
    }
    
    func isCropWidth() -> Bool{
        if self.cropWidth() < 150{
            return true
        }else{
            return false
        }
    }
    func isCropHeight() -> Bool{
        if self.cropHeight() < 150{
            return true
        }else{
            return false
        }
    }
    
    
    
    @IBAction func centerDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchSize = self.touchPoint(sender, forEvent: event, dragType: .center) else {
            return
        }
        let width = touchSize.width
        let height = touchSize.height
        
        if width > 0 && self.cropLeft.constant-width < self.cropWidthValue{
            return
        }else if width < 0 && self.cropRight.constant+width < self.cropWidthValue{
            return
        }else if height > 0 && self.cropTop.constant-height < self.cropHeightValue{
            return
        }else if height < 0 && self.cropBottom.constant+height < self.cropHeightValue{
            return
        }
        
        self.cropLeft.constant = self.cropLeft.constant-width
        self.cropRight.constant = self.cropRight.constant+width
        self.cropTop.constant = self.cropTop.constant-height
        self.cropBottom.constant = self.cropBottom.constant+height
        self.resize()
    }
    @IBAction func topLeftDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .topLeft) else {
            return
        }
        if ts.width > 0 && self.cropLeft.constant-ts.width < self.cropWidthValue{
            return
        }else if ts.height > 0 && self.cropTop.constant-ts.height < self.cropHeightValue{
            return
        }else if ts.width < 0 && self.isCropWidth(){
            return
        }else if ts.height < 0 && self.isCropHeight(){
            return
        }
        
        self.cropLeft.constant = self.cropLeft.constant-ts.width
        self.cropTop.constant = self.cropTop.constant-ts.height
        self.resize()
    }
    @IBAction func topDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin || PKCCropManager.shared.cropType == .rateAndNoneMargin{
            return
        }
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .top) else {
            return
        }
        if ts.height > 0 && self.cropTop.constant-ts.height < self.cropHeightValue{
            return
        }else if ts.height < 0 && self.isCropHeight(){
            return
        }
        self.cropTop.constant = self.cropTop.constant-ts.height
        self.resize()
    }
    @IBAction func topRightDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .topRight) else {
            return
        }
        if ts.width < 0 && self.cropRight.constant+ts.width < self.cropWidthValue{
            return
        }else if ts.height > 0 && self.cropTop.constant-ts.height < self.cropHeightValue{
            return
        }else if ts.width > 0 && self.isCropWidth(){
            return
        }else if ts.height < 0 && self.isCropHeight(){
            return
        }
        self.cropRight.constant = self.cropRight.constant+ts.width
        self.cropTop.constant = self.cropTop.constant-ts.height
        self.resize()
    }
    @IBAction func leftDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin || PKCCropManager.shared.cropType == .rateAndNoneMargin{
            return
        }
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .left) else {
            return
        }
        if ts.width > 0 && self.cropLeft.constant-ts.width < self.cropWidthValue{
            return
        }else if ts.width < 0 && self.isCropWidth(){
            return
        }
        self.cropLeft.constant = self.cropLeft.constant-ts.width
        self.resize()
    }
    @IBAction func rightDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin || PKCCropManager.shared.cropType == .rateAndNoneMargin{
            return
        }
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .right) else {
            return
        }
        if ts.width < 0 && self.cropRight.constant+ts.width < self.cropWidthValue{
            return
        }else if ts.width > 0 && self.isCropWidth(){
            return
        }
        self.cropRight.constant = self.cropRight.constant+ts.width
        self.resize()
    }
    @IBAction func bottomLeftDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .bottomLeft) else {
            return
        }
        if ts.width > 0 && self.cropLeft.constant-ts.width < self.cropWidthValue{
            return
        }else if ts.height < 0 && self.cropBottom.constant+ts.height < self.cropHeightValue{
            return
        }else if ts.width < 0 && self.isCropWidth(){
            return
        }else if ts.height > 0 && self.isCropHeight(){
            return
        }
        self.cropLeft.constant = self.cropLeft.constant-ts.width
        self.cropBottom.constant = self.cropBottom.constant+ts.height
        self.resize()
    }
    @IBAction func bottomDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin || PKCCropManager.shared.cropType == .rateAndNoneMargin{
            return
        }
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .bottom) else {
            return
        }
        if ts.height < 0 && self.cropBottom.constant+ts.height < self.cropHeightValue{
            return
        }else if ts.height > 0 && self.isCropHeight(){
            return
        }
        self.cropBottom.constant = self.cropBottom.constant+ts.height
        self.resize()
    }
    @IBAction func bottomRightDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let ts = self.touchPoint(sender, forEvent: event, dragType: .bottomRight) else {
            return
        }
        if ts.width < 0 && self.cropRight.constant+ts.width < self.cropWidthValue{
            return
        }else if ts.height < 0 && self.cropBottom.constant+ts.height < self.cropHeightValue{
            return
        }else if ts.width > 0 && self.isCropWidth(){
            return
        }else if ts.height > 0 && self.isCropHeight(){
            return
        }
        self.cropRight.constant = self.cropRight.constant+ts.width
        self.cropBottom.constant = self.cropBottom.constant+ts.height
        self.resize()
    }
}


enum DragType{
    case center
    case top
    case left
    case right
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}



// MARK: - CropZoom
extension PKCCropViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}





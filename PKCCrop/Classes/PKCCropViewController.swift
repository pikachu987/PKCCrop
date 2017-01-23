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
    
    //This is a required variable when cropping. Compares the point of the current drag to that point.
    //크롭할때 필요한 변수입니다. 현재 드래그의 포인트와 해당 포인트를 비교합니다.
    var touchPoint: CGPoint!
    
    //Specify where cropping is possible. If there is a space, it is up to -20. If there is no space, it depends on the image size.
    //어디서부터 크롭이 가능한지를 지정합니다. 공백있음으로 하면 -20까지 되고 공백없음으로 하면 이미지 사이즈에 따라 달라집니다.
    var cropWidthValue: CGFloat!
    var cropHeightValue: CGFloat!
    
    //PKCropViewController View
    @IBOutlet var mainView: UIView!
    
    //Crop View
    @IBOutlet var captureView: UIView!
    
    //scrollView
    @IBOutlet var scrollView: UIScrollView!
    
    //The top constraint of the scrollView. Images imported from a camera or gallery will have their values ​​set to 0 when they are imported directly into the -20 image.
    //scrollView의 top constraint입니다. 카메라 또는 갤러리에서 가져온 이미지는 해당 값을 -20 이미지를 직접 가져오면 해당값을 0으로 합니다.
    @IBOutlet var scrollTop: NSLayoutConstraint!
    
    //cropView
    @IBOutlet var cropView: UIView!
    //maskView
    @IBOutlet var maskRectView: UIView!
    @IBOutlet var radiusImageView: UIImageView!
    
    //Constraint of Cropview
    //Cropview의 Constraint
    @IBOutlet var cropTop: NSLayoutConstraint!
    @IBOutlet var cropLeft: NSLayoutConstraint!
    @IBOutlet var cropRight: NSLayoutConstraint!
    @IBOutlet var cropBottom: NSLayoutConstraint!
    
    //Constraint of maskView
    //maskView의 Constraint
    @IBOutlet var maskTop: NSLayoutConstraint!
    @IBOutlet var maskLeft: NSLayoutConstraint!
    @IBOutlet var maskRight: NSLayoutConstraint!
    @IBOutlet var maskBottom: NSLayoutConstraint!
    
    //Zoom animation related
    //zoom 애니메이션 관련
    @IBOutlet var zoomHelpWidth: NSLayoutConstraint!
    @IBOutlet var zoomHelpHeight: NSLayoutConstraint!
    @IBOutlet var zoomHelpView: UIView!
    
    //Image of crop vertex
    //crop 꼭지점의 이미지
    @IBOutlet var cropTopLeft: UIImageView!
    @IBOutlet var cropTopRight: UIImageView!
    @IBOutlet var cropBottomLeft: UIImageView!
    @IBOutlet var cropBottomRight: UIImageView!
    
    
    //Button at the crop vertex. Button to check whether the property is touched when changing the image color
    //crop 꼭지점의 버튼. 이미지 색을 바꿀때 해당 프로퍼티를 터치했는지 확인하는 버튼
    @IBOutlet var cropTopLeftBtn: UIButton!
    @IBOutlet var cropTopRightBtn: UIButton!
    @IBOutlet var cropBottomLeftBtn: UIButton!
    @IBOutlet var cropBottomRightBtn: UIButton!
    
    //Variable related to rotation
    //회전 관련한 변수
    @IBOutlet var rotateView: UIView!
    @IBOutlet var rotateImage: UIImageView!
    @IBOutlet var rotateBottomCont: NSLayoutConstraint!
    @IBOutlet var rotateLbl: UILabel!
    @IBOutlet var rotateSlider: UISlider!
    
    //Right upper crop button
    //우측 상단 크롭 버튼
    @IBOutlet var crop: UIButton!
    
    //Make sure you are in crop or zoom status
    //현재 크롭상태인지 줌상태인지 확인
    var isCurrentCrop = false
    
    // MARK: - init
    //Import PKCCropViewController xib file
    //PKCCropViewController xib파일을 불러온다
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
        
        //Check the zoom status and execute the corresponding event.
        //줌상태를 체크해 해당 이벤트를 실행합니다.
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
                })
            }else{
                self.zoomHelpView.isHidden = true
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //After adding the image from the gallery, zoom in and crop the image.
    //갤러리에서 받아온 이미지를 추가 후 줌 상태에 때라 crop 진행합니다.
    func changeImage(_ image: UIImage){
        self.image = image
        self.imageView.image = self.image
        if !PKCCropManager.shared.isZoom{
            self.cropStart()
        }
    }
    
    //Crop initial start
    //crop 처음 시작
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
        
        if PKCCropManager.shared.cropType == .freeRateAndMargin ||
            PKCCropManager.shared.cropType == .freeRateAndNoneMargin ||
            PKCCropManager.shared.cropType == .freeRateAndRotate{
            //freeRateCrop
            //자유 비율 크롭
            let iframe = self.imageView.frameForImageInImageViewAspectFit()
            let isRate = iframe.width/UIScreen.main.bounds.width < iframe.height/UIScreen.main.bounds.height
            if isRate && iframe.width < 250{
                cropCont(w: iframe.width, h: iframe.width)
            }else if !isRate && iframe.height < 250{
                cropCont(w: iframe.height, h: iframe.height)
            }
        }else{
            if PKCCropManager.shared.cropType == .rateAndMarginCircle ||
                PKCCropManager.shared.cropType == .rateAndNoneMarginCircle ||
                PKCCropManager.shared.cropType == .rateAndRotateCircle{
                let _ = PKCCropManager.shared.setRate(rateWidth: 1, rateHeight: 1)
            }
            //rateCrop
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
        
        
        
        
        if PKCCropManager.shared.cropType == .freeRateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle{
            //margin
            //공백있게
            self.cropWidthValue = -20
            self.cropHeightValue = -20
        }else if PKCCropManager.shared.cropType == .freeRateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMarginCircle{
            //noneMargin
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
        }else{
            //rotate
            //회전
            self.imageView.contentMode = .scaleAspectFill
            if PKCCropManager.shared.isRotate{
                self.rotateView.isHidden = false
            }
            self.cropWidthValue = -20
            self.cropHeightValue = -20
        }
        
        self.resize()
    }
    
    //It will be called continuously the first time you start a crop and receive a user event. Change the contrast of the maskView, change the mask state, and then change the layout.
    //처음 크롭시작과 사용자 이벤트를 받을때 계속 호출됩니다. maskView의 contstraint를 바꾸며 mask 상태를 바꾼 후 layout를 바꿉니다.
    func resize(){
        self.maskTop.constant = self.cropTop.constant+15
        self.maskLeft.constant = self.cropLeft.constant+15
        self.maskRight.constant = self.cropRight.constant+15
        self.maskBottom.constant = self.cropBottom.constant+15
        var corner : CGFloat = 0
        if PKCCropManager.shared.cropType == .rateAndNoneMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle{
            corner = self.cropWidth()/2
        }
        self.setMaskRect(CGRect(x: self.cropLeft.constant+21, y: self.cropTop.constant+21, width: UIScreen.main.bounds.width-self.cropLeft.constant-self.cropRight.constant-40 - 2, height: UIScreen.main.bounds.height-self.cropTop.constant-self.cropBottom.constant-40 - 2), corner: corner)
        self.cropView.layoutIfNeeded()
        self.cropView.setNeedsLayout()
        self.maskRectView.layoutIfNeeded()
        self.maskRectView.setNeedsLayout()
    }
    //Replace maskView's mask with frame.
    //maskView의 mask를 frame에 따라 바꿉니다.
    func setMaskRect(_ frame: CGRect, corner: CGFloat = 0){
        let path = UIBezierPath(roundedRect: frame, cornerRadius: corner)
        path.append(UIBezierPath(rect: self.maskRectView.frame))
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = path.cgPath
        self.maskRectView.layer.mask = maskLayer
    }
    
    
    
    
    //Turns the rotation view on or off.
    //rotation view를 보이게 하거나 안보이게 합니다.
    @IBAction func rotateViewAction(_ sender: Any) {
        if self.rotateBottomCont.constant == 0{
            self.rotateHide()
        }else{
            self.rotateShow()
        }
    }
    @IBAction func rotateDownGestureAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.rotateView)
        let progress = MenuHelper.calculateProgress(translation, viewBounds: self.rotateView.bounds, direction: .down)
        if sender.state == .ended{
            if progress > 0{
                if self.rotateView.frame.origin.y > UIScreen.main.bounds.height-self.rotateView.frame.height/3*2{
                    self.rotateHide(0.2)
                }else{
                    self.rotateShow(0.2)
                }
            }
        }else{
            self.rotateBottomCont.constant = -(self.rotateView.frame.height-20)*progress
            self.mainView.layoutIfNeeded()
            self.mainView.setNeedsLayout()
            if progress == 1{
                self.rotateImage.image = UIImage(named: "pkc_crop_rotate_up.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)
            }
        }
    }
    func rotateHide(_ time: TimeInterval = 0.4){
        UIView.animate(withDuration: time, animations: {
            self.rotateBottomCont.constant = -80
            self.mainView.layoutIfNeeded()
            self.mainView.setNeedsLayout()
        }) { (_) in
            self.rotateImage.image = UIImage(named: "pkc_crop_rotate_up.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)
        }
    }
    func rotateShow(_ time: TimeInterval = 0.4){
        UIView.animate(withDuration: time, animations: {
            self.rotateBottomCont.constant = 0
            self.mainView.layoutIfNeeded()
            self.mainView.setNeedsLayout()
        }) { (_) in
            self.rotateImage.image = UIImage(named: "pkc_crop_rotate_down.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)
        }
    }
    
    
    //Rotate the image.
    //이미지를 회전합니다.
    @IBAction func rotateAction(_ sender: UISlider) {
        self.rotateLbl.text = "\(Int(self.rotateSlider.value))˚"
        //x degree = x * π / 180 radian
        //x radian = x * 180 / π degree
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.rotateSlider.value * Float(M_PI)/180))
    }
    
    //Rotate the image 90 degrees to the left.
    //이미지를 90도 왼쪽으로 회전합니다.
    @IBAction func rotateLeftAction(_ sender: Any) {
        if self.rotateSlider.value > 90{
            self.rotateSlider.value -= 90
        }else{
            self.rotateSlider.value = 0
        }
        self.rotateAction(self.rotateSlider)
    }
    
    //Rotate the image 90 degrees to the right.
    //이미지를 90도 오른쪽으로 회전합니다.
    @IBAction func rotateRightAction(_ sender: Any) {
        if self.rotateSlider.value < 270{
            self.rotateSlider.value += 90
        }else{
            self.rotateSlider.value = 360
        }
        self.rotateAction(self.rotateSlider)
    }
    
    
    
    
    //Back button action. Checks whether or not the current zoom state is present, then goes back to zoom state, and changes to zoom state if not zoom state.
    //뒤로가기 버튼 액션입니다. 현재 줌상태인지 아닌지 체크한 다음 줌상태면 뒤로가기, 줌상태가 아니면 줌상태로 변환합니다.
    @IBAction func backAction(_ sender: Any) {
        if !PKCCropManager.shared.isZoom{
            if self.cropType == CropType.other{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController!.popViewController(animated: true)
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
                    self.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
    
    //Crop action. Crops the current zoom state, and calls the image crop method if it is a cropped state.
    //크롭 액션입니다. 현재 줌상태면 크롭상태로, 크롭상태면 이미지 크롭 메서드를 호출합니다.
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
    
    //After you crop the image, call the delegate and close the page.
    //이미지를 크롭 후 delegate를 호출하고 페이지를 닫습니다.
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
        if PKCCropManager.shared.cropType == .rateAndNoneMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle{
            self.radiusImageView.frame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
            self.radiusImageView.image = image
            let path = UIBezierPath(roundedRect: self.radiusImageView.bounds, cornerRadius: self.cropWidth()/2)
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.radiusImageView.layer.mask = maskLayer
            
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 0.1)
                DispatchQueue.main.async {
                    UIGraphicsBeginImageContextWithOptions(self.radiusImageView.frame.size, false, 0.0)
                    self.radiusImageView.drawHierarchy(in: CGRect(x: 0, y: 0, width: self.self.radiusImageView.frame.width, height: self.radiusImageView.frame.height), afterScreenUpdates: false)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    self.radiusImageView.removeFromSuperview()
                    self.delegate?.pkcCropPicture(image!)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            self.delegate?.pkcCropPicture(image!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}









// MARK: - CropTouchAction
//Crop touch actions
extension PKCCropViewController{
    //touchCancel
    @IBAction func touchCancelAction(_ sender: UIButton, forEvent event: UIEvent) {
        self.touchPoint = nil
        self.touchImageNomal()
    }
    //touchStart
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
            if dragType != .center && (
                PKCCropManager.shared.cropType == .rateAndMargin ||
                    PKCCropManager.shared.cropType == .rateAndNoneMargin ||
                    PKCCropManager.shared.cropType == .rateAndRotate ||
                    PKCCropManager.shared.cropType == .rateAndMarginCircle ||
                    PKCCropManager.shared.cropType == .rateAndRotateCircle ||
                    PKCCropManager.shared.cropType == .rateAndNoneMarginCircle
                ){
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
    
    
    
    
    
    //center
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
    
    
    
    //topLeft
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
    
    
    
    //top
    @IBAction func topDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndRotate ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndNoneMarginCircle{
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
    
    
    
    //topRight
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
    
    
    
    //left
    @IBAction func leftDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndRotate ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndNoneMarginCircle{
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
    
    
    
    //right
    @IBAction func rightDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndRotate ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndNoneMarginCircle{
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
    
    
    //bottomLeft
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
    
    
    
    //bottom
    @IBAction func bottomDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropManager.shared.cropType == .rateAndMargin ||
            PKCCropManager.shared.cropType == .rateAndNoneMargin ||
            PKCCropManager.shared.cropType == .rateAndRotate ||
            PKCCropManager.shared.cropType == .rateAndMarginCircle ||
            PKCCropManager.shared.cropType == .rateAndRotateCircle ||
            PKCCropManager.shared.cropType == .rateAndNoneMarginCircle{
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
    
    
    //bottomRight
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







//Type enum used in crop drag
//crop drag에서 사용하는 type enum
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
//Image zoom related scrollView delegate
//image zoom 관련 scrollView delegate
extension PKCCropViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}





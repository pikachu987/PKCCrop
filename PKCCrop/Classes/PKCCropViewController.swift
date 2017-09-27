//Copyright (c) 2017 pikachu987 <pikachu987@naver.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

public protocol PKCCropDelegate: class {
    func pkcCropCancel(_ viewController: PKCCropViewController)
    func pkcCropImage(_ image: UIImage?, originalImage: UIImage?)
    func pkcCropComplete(_ viewController: PKCCropViewController)
}


public class PKCCropViewController: UIViewController {
    public weak var delegate: PKCCropDelegate?
    public var tag: Int = 0
    var image = UIImage()
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var scrollTopConst: NSLayoutConstraint!
    @IBOutlet fileprivate weak var scrollBottomConst: NSLayoutConstraint!
    @IBOutlet fileprivate weak var scrollLeadingConst: NSLayoutConstraint!
    @IBOutlet fileprivate weak var scrollTrailingConst: NSLayoutConstraint!
    @IBOutlet private weak var toolBar: UIToolbar!

    fileprivate var isZoomTimer = Timer()

    fileprivate let imageView = UIImageView()

    @IBOutlet fileprivate weak var cropLineView: PKCCropLineView!
    @IBOutlet fileprivate weak var maskView: UIView!
    
    private var imageRotateRate: Float = 0

    public init(_ image: UIImage, tag: Int = 0) {
        super.init(nibName: "PKCCropViewController", bundle: Bundle(for: PKCCrop.self))
        self.image = image
        self.tag = tag
    }



    override public var prefersStatusBarHidden: Bool{
        if self.navigationController == nil || !PKCCropHelper.shared.isNavigationBarShow{
            return true
        }else{
            return false
        }
    }


    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController == nil || !PKCCropHelper.shared.isNavigationBarShow{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }



    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController == nil || !PKCCropHelper.shared.isNavigationBarShow{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }



    deinit {
        //print("deinit \(self)")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.initVars()
        self.initCrop(self.image)
    }

    private func initVars(){

        //add navigation title when has navigationBar
        if self.navigationController != nil || PKCCropHelper.shared.isNavigationBarShow {
            self.title = PKCCropHelper.shared.titleText
        }

        self.view.backgroundColor = .black
        self.maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: PKCCropHelper.shared.maskAlpha)
        self.maskView.isUserInteractionEnabled = false

        if let height = self.navigationController?.navigationBar.bounds.height{
            if PKCCropHelper.shared.isNavigationBarShow{
                self.scrollTopConst.constant = 42 + height
            }
        }

        self.cropLineView.delegate = self
        
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        self.toolBar.barTintColor = PKCCropHelper.shared.barTintColor
        self.toolBar.backgroundColor = .white
        self.toolBar.items?.forEach({ (item) in
            item.tintColor = PKCCropHelper.shared.tintColor
        })
        
        var barButtonItems = [UIBarButtonItem]()
        
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction(_:))))
        if !PKCCropHelper.shared.isDegressShow{
            barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        }else{
            barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
            
            if let image = PKCCropHelper.shared.degressBeforeImage{
                barButtonItems.append(UIBarButtonItem(image: image.resize(CGSize(width: 24, height: 24)), style: .done, target: self, action: #selector(self.rotateLeftAction(_:))))
            }else{
                barButtonItems.append(UIBarButtonItem(title: "-90 Degress", style: .done, target: self, action: #selector(self.rotateLeftAction(_:))))
            }
            
            barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
            
            if let image = PKCCropHelper.shared.degressAfterImage{
                barButtonItems.append(UIBarButtonItem(image: image.resize(CGSize(width: 24, height: 24)), style: .done, target: self, action: #selector(self.rotateRightAction(_:))))
            }else{
                barButtonItems.append(UIBarButtonItem(title: "90 Degress", style: .done, target: self, action: #selector(self.rotateRightAction(_:))))
            }
            
            barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        }
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction(_:))))
        self.toolBar.setItems(barButtonItems, animated: true)
    }


    private func initCrop(_ image: UIImage){
        self.scrollView.alpha = 0
        self.cropLineView.alpha = 0

        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 4
        self.scrollView.zoomScale = 1
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() })

        self.scrollView.addSubview(self.imageView)
        self.imageView.image = image
        let width = UIScreen.main.bounds.width - self.scrollLeadingConst.constant - self.scrollTrailingConst.constant
        let height = UIScreen.main.bounds.height - self.scrollTopConst.constant - self.scrollBottomConst.constant
        self.imageView.frame = CGRect(x: (width - image.size.width)/2, y: (height - image.size.height)/2, width: image.size.width, height: image.size.height)
        self.imageView.contentMode = .scaleAspectFill

        DispatchQueue.main.async {
            let minimumXScale = PKCCropHelper.shared.minSize / self.image.size.width
            let minimumYScale = PKCCropHelper.shared.minSize / self.image.size.height

            let deviceMinSize = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
            let currentXScale = (deviceMinSize-40) / self.image.size.width
            let currentYScale = (deviceMinSize-40) / self.image.size.height

            self.scrollView.minimumZoomScale = minimumXScale < minimumYScale ? minimumYScale : minimumXScale
            self.scrollView.zoomScale = currentXScale < currentYScale ? currentYScale : currentXScale

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.cropLineView.initLineFrame()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                UIView.animate(withDuration: 0.2){
                    self.scrollView.alpha = 1
                    self.cropLineView.alpha = 1

                }
            }
        }
    }




    @objc private func cancelAction(_ sender: UIBarButtonItem) {
        self.delegate?.pkcCropCancel(self)
    }

    @objc private func doneAction(_ sender: UIBarButtonItem) {
        let cropSize = self.cropLineView.cropSize()
        let captureRect = CGRect(
            x: -cropSize.origin.x+2,
            y: -cropSize.origin.y+2,
            width: self.scrollView.frame.width,
            height: self.scrollView.frame.height
        )
        UIGraphicsBeginImageContextWithOptions(cropSize.size, false, 0.0)
        self.scrollView.drawHierarchy(in: captureRect, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        DispatchQueue.main.async {
            self.delegate?.pkcCropImage(image, originalImage: self.image)
        }

        self.delegate?.pkcCropComplete(self)
    }


    @objc private func rotateLeftAction(_ sender: UIBarButtonItem) {
        guard let image = self.imageView.image?.imageRotatedByDegrees(-90, flip: false) else {
            return
        }
        self.initCrop(image)
    }

    
    @objc private func rotateRightAction(_ sender: UIBarButtonItem) {
        guard let image = self.imageView.image?.imageRotatedByDegrees(90, flip: false) else {
            return
        }
        self.initCrop(image)
    }
}


extension PKCCropViewController: UIScrollViewDelegate{
    @objc fileprivate func scrollDidZoomCenter(){
        let width = UIScreen.main.bounds.width - self.scrollLeadingConst.constant - self.scrollTrailingConst.constant
        let height = UIScreen.main.bounds.height - self.scrollTopConst.constant - self.scrollBottomConst.constant
        let widthValue = (width - self.imageView.frame.width)/2
        let heightValue = (height - self.imageView.frame.height)/2
        self.imageView.frame.origin = CGPoint(x: widthValue, y: heightValue)
        self.scrollView.contentInset = UIEdgeInsetsMake(heightValue < 0 ? -heightValue : 0, widthValue < 0 ? -widthValue : 0, heightValue < 0 ? heightValue : 0, widthValue < 0 ? widthValue : 0)
        self.cropLineView.imageViewSize(self.imageView.frame)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.isZoomTimer.invalidate()
        self.isZoomTimer = Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(self.scrollDidZoomCenter),
            userInfo: nil,
            repeats: false
        )
    }
}


extension PKCCropViewController: PKCCropLineDelegate{
    func pkcCropLineMask(_ frame: CGRect){
        var frameValue = frame
        frameValue.origin.y += self.scrollTopConst.constant - 2
        frameValue.origin.x += self.scrollLeadingConst.constant - 2
        let path = UIBezierPath(roundedRect: frameValue, cornerRadius: PKCCropHelper.shared.isCircle ? frame.width/2 : 0)
        path.append(UIBezierPath(rect: self.maskView.frame))
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = path.cgPath
        self.maskView.layer.mask = maskLayer
        self.view.layoutIfNeeded()
    }
}

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


protocol PKCCropLineDelegate: class {
    func pkcCropLineMask(_ frame: CGRect)
}

class PKCCropLineView: UIView {
    weak var delegate: PKCCropLineDelegate?

    private var containerView: UIView!

    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var subLineView: UIView!

    @IBOutlet private weak var leftTopButton: PKCButton!
    @IBOutlet private weak var leftBottomButton: PKCButton!
    @IBOutlet private weak var rightTopButton: PKCButton!
    @IBOutlet private weak var rightBottomButton: PKCButton!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var bottomTopButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var centerButton: UIButton!


    @IBOutlet private weak var topConst: NSLayoutConstraint!
    @IBOutlet private weak var leftConst: NSLayoutConstraint!
    @IBOutlet private weak var rightConst: NSLayoutConstraint!
    @IBOutlet private weak var bottomConst: NSLayoutConstraint!

    private var touchPoint: CGPoint? = nil
    

    @IBOutlet private weak var ratioConst: NSLayoutConstraint!
    @IBOutlet private weak var limitTopConst: NSLayoutConstraint!
    @IBOutlet private weak var limitLeftConst: NSLayoutConstraint!
    @IBOutlet private weak var limitRightConst: NSLayoutConstraint!
    @IBOutlet private weak var limitBottomConst: NSLayoutConstraint!
    
    @IBOutlet private weak var minHeightConst: NSLayoutConstraint!
    @IBOutlet private weak var minWidthConst: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitialization()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialization()
    }

    private func commonInitialization(){
        self.containerView = Bundle.init(for: PKCCrop.self).loadNibNamed("PKCCropLineView", owner: self, options: nil)?.first as! UIView
        self.containerView.frame = self.bounds
        self.containerView.addFullConstraints(self)
        self.initVars()
    }

    private func initVars(){
        self.backgroundColor = .clear
        self.containerView.backgroundColor = .clear
        self.lineView.backgroundColor = .clear
        self.subLineView.backgroundColor = .clear
        
        self.subLineView.alpha = PKCCropHelper.shared.lineType == .show ? 1 : 0
        
        if !PKCCropHelper.shared.isCropRate && !PKCCropHelper.shared.isCircle{
            self.ratioConst.isActive = false
        }

        self.minHeightConst.constant = PKCCropHelper.shared.minSize
        self.minWidthConst.constant = PKCCropHelper.shared.minSize
        
        DispatchQueue.main.async{
            self.leftTopButton.leftTop()
            self.rightTopButton.rightTop()
            self.leftBottomButton.leftBottom()
            self.rightBottomButton.rightBottom()
        }
    }


    private func makeMask(){
        self.layoutIfNeeded()
        guard let frame = self.superview?.convert(self.lineView.frame, to: nil) else {
            return
        }
        self.delegate?.pkcCropLineMask(CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height))
    }

    func cropSize() -> CGRect{
        return self.lineView.frame
    }

    func initLineFrame(){
        let paddingX = (self.frame.width - PKCCropHelper.shared.minSize - 80 - 2)/2
        let paddingY = (self.frame.height - PKCCropHelper.shared.minSize - 80 - 2)/2
        self.leftConst.constant = paddingX
        self.rightConst.constant = paddingX
        self.topConst.constant = paddingY
        self.bottomConst.constant = paddingY
    }

    func imageViewSize(_ frame: CGRect){
        let limitX = frame.origin.x + 2
        let limitY = frame.origin.y + 2
        
        self.limitLeftConst.constant = limitX > 0 ? limitX : 2
        self.limitRightConst.constant = limitX > 0 ? limitX : 2
        self.limitTopConst.constant = limitY > 0 ? limitY : 2
        self.limitBottomConst.constant = limitY > 0 ? limitY : 2
        
        if self.leftConst.constant < self.limitLeftConst.constant - 2{
            self.leftConst.constant = self.limitLeftConst.constant - 2
        }
        if self.rightConst.constant < self.limitRightConst.constant - 2{
            self.rightConst.constant = self.limitRightConst.constant - 2
        }
        if self.topConst.constant < self.limitTopConst.constant - 2{
            self.topConst.constant = self.limitTopConst.constant - 2
        }
        if self.bottomConst.constant < self.limitBottomConst.constant - 2{
            self.bottomConst.constant = self.limitBottomConst.constant - 2
        }
        
        self.makeMask()
    }






    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.leftTopButton.frame.contains(point){
            return true
        }else if self.leftBottomButton.frame.contains(point){
            return true
        }else if self.rightTopButton.frame.contains(point){
            return true
        }else if self.rightBottomButton.frame.contains(point){
            return true
        }else if self.topButton.frame.contains(point){
            return true
        }else if self.bottomTopButton.frame.contains(point){
            return true
        }else if self.leftButton.frame.contains(point){
            return true
        }else if self.rightButton.frame.contains(point){
            return true
        }else if self.centerButton.frame.contains(point){
            return true
        }else{
            return false
        }
    }














    // - MARK Drag Action




    @IBAction private func touchUpAction(_ sender: UIButton, forEvent event: UIEvent){
        self.touchPoint = nil
        if PKCCropHelper.shared.lineType == .default{
            self.subLineView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.subLineView.alpha = 0
            })
        }
    }

    @IBAction private func touchDownAction(_ sender: UIButton, forEvent event: UIEvent){
        if let touch = event.touches(for: sender)?.first {
            self.touchPoint = touch.previousLocation(in: self)
            if PKCCropHelper.shared.lineType == .default{
                self.subLineView.alpha = 0
                UIView.animate(withDuration: 0.3, animations: { 
                    self.subLineView.alpha = 1
                })
            }
        }
    }





    @IBAction private func centerDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)

            let minusYPoint = currentPoint.y - touchPoint.y
            let minusXPoint = currentPoint.x - touchPoint.x

            let topConst = self.topConst.constant + minusYPoint
            let bottomConst = self.bottomConst.constant - minusYPoint
            let leftConst = self.leftConst.constant + minusXPoint
            let rightConst = self.rightConst.constant - minusXPoint

            if topConst >= self.limitTopConst.constant - 2 && bottomConst >= self.limitBottomConst.constant - 2{
                self.topConst.constant = topConst
                self.bottomConst.constant = bottomConst
            }
            if leftConst >= self.limitLeftConst.constant - 2 && rightConst >= self.limitRightConst.constant - 2{
                self.leftConst.constant = leftConst
                self.rightConst.constant = rightConst
            }


//            if topConst >= self.limitTopConst.constant - 2{
//                self.topConst.constant = topConst
//                self.bottomConst.constant = bottomConst
//            }else if bottomConst >= self.limitBottomConst.constant - 2{
//                self.topConst.constant = topConst
//                self.bottomConst.constant = bottomConst
//            }
//            if rightConst >= self.limitRightConst.constant - 2{
//                self.leftConst.constant = leftConst
//                self.rightConst.constant = rightConst
//            }else if leftConst >= self.limitLeftConst.constant - 2{
//                self.leftConst.constant = leftConst
//                self.rightConst.constant = rightConst
//            }

            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func topDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropHelper.shared.isCircle || PKCCropHelper.shared.isCropRate{
            return
        }
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let topConst = self.topConst.constant + minusYPoint
            let limitYConst = (self.bounds.height - (self.bottomConst.constant + topConst +  PKCCropHelper.shared.minSize))

            if topConst >= 0 && minusYPoint > 0 && limitYConst > 0{
                self.topConst.constant = topConst
            }else if topConst >= 0 && minusYPoint <= 0 && self.limitTopConst.constant <= topConst{
                self.topConst.constant = topConst
            }
            
            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func bottomDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropHelper.shared.isCircle || PKCCropHelper.shared.isCropRate{
            return
        }
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let bottomConst = self.bottomConst.constant - minusYPoint
            let limitYConst = (self.bounds.height - (self.topConst.constant + bottomConst +  PKCCropHelper.shared.minSize))

            if bottomConst >= 0 && minusYPoint < 0 && limitYConst > 0{
                self.bottomConst.constant = bottomConst
            }else if bottomConst >= 0 && minusYPoint >= 0 && self.limitBottomConst.constant <= bottomConst{
                self.bottomConst.constant = bottomConst
            }
            
            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func leftDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropHelper.shared.isCircle || PKCCropHelper.shared.isCropRate{
            return
        }
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusXPoint = currentPoint.x - touchPoint.x
            let leftConst = self.leftConst.constant + minusXPoint
            let limitXConst = (self.bounds.width - (self.rightConst.constant + leftConst +  PKCCropHelper.shared.minSize))
            
            if leftConst >= 0 && minusXPoint > 0 && limitXConst > 0{
                self.leftConst.constant = leftConst
            }else if leftConst >= 0 && minusXPoint <= 0 && self.limitLeftConst.constant <= leftConst{
                self.leftConst.constant = leftConst
            }
            
            self.touchPoint = currentPoint
            self.makeMask()
        }
    }



    @IBAction private func rightDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        if PKCCropHelper.shared.isCircle || PKCCropHelper.shared.isCropRate{
            return
        }
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusXPoint = currentPoint.x - touchPoint.x
            let rightConst = self.rightConst.constant - minusXPoint
            let limitXConst = (self.bounds.width - (self.leftConst.constant + rightConst +  PKCCropHelper.shared.minSize))
            
            if rightConst >= 0 && minusXPoint < 0 && limitXConst > 0{
                self.rightConst.constant = rightConst
            }else if rightConst >= 0 && minusXPoint >= 0 && self.limitRightConst.constant <= rightConst{
                self.rightConst.constant = rightConst
            }
            
            self.touchPoint = currentPoint
            self.makeMask()
        }
    }


    @IBAction private func leftTopDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let minusXPoint = currentPoint.x - touchPoint.x
            let topConst = self.topConst.constant + minusYPoint
            let leftConst = self.leftConst.constant + minusXPoint
            let limitYConst = (self.bounds.height - (self.bottomConst.constant + topConst +  PKCCropHelper.shared.minSize))
            let limitXConst = (self.bounds.width - (self.rightConst.constant + leftConst +  PKCCropHelper.shared.minSize))

            if topConst >= 0 && minusYPoint > 0 && limitYConst > 0{
                self.topConst.constant = topConst
            }else if topConst >= 0 && minusYPoint <= 0 && self.limitTopConst.constant <= topConst{
                self.topConst.constant = topConst
            }

            if leftConst >= 0 && minusXPoint > 0 && limitXConst > 0{
                self.leftConst.constant = leftConst
            }else if leftConst >= 0 && minusXPoint <= 0 && self.limitLeftConst.constant <= leftConst{
                self.leftConst.constant = leftConst
            }
            
            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func rightTopDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let minusXPoint = currentPoint.x - touchPoint.x
            let rightConst = self.rightConst.constant - minusXPoint
            let topConst = self.topConst.constant + minusYPoint
            let limitYConst = (self.bounds.height - (self.bottomConst.constant + topConst +  PKCCropHelper.shared.minSize))
            let limitXConst = (self.bounds.width - (self.leftConst.constant + rightConst +  PKCCropHelper.shared.minSize))
            
            if topConst >= 0 && minusYPoint > 0 && limitYConst > 0{
                self.topConst.constant = topConst
            }else if topConst >= 0 && minusYPoint <= 0 && self.limitTopConst.constant <= topConst{
                self.topConst.constant = topConst
            }

            if rightConst >= 0 && minusXPoint < 0 && limitXConst > 0{
                self.rightConst.constant = rightConst
            }else if rightConst >= 0 && minusXPoint >= 0 && self.limitRightConst.constant <= rightConst{
                self.rightConst.constant = rightConst
            }

            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func leftBottomDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let minusXPoint = currentPoint.x - touchPoint.x
            let leftConst = self.leftConst.constant + minusXPoint
            let bottomConst = self.bottomConst.constant - minusYPoint
            let limitYConst = (self.bounds.height - (self.topConst.constant + bottomConst +  PKCCropHelper.shared.minSize))
            let limitXConst = (self.bounds.width - (self.rightConst.constant + leftConst +  PKCCropHelper.shared.minSize))

            if bottomConst >= 0 && minusYPoint < 0 && limitYConst > 0{
                self.bottomConst.constant = bottomConst
            }else if bottomConst >= 0 && minusYPoint >= 0 && self.limitBottomConst.constant <= bottomConst{
                self.bottomConst.constant = bottomConst
            }

            if leftConst >= 0 && minusXPoint > 0 && limitXConst > 0{
                self.leftConst.constant = leftConst
            }else if leftConst >= 0 && minusXPoint <= 0 && self.limitLeftConst.constant <= leftConst{
                self.leftConst.constant = leftConst
            }

            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

    @IBAction private func rightBottomDragAction(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touchPoint = self.touchPoint else {
            return
        }
        if let touch = event.touches(for: sender)?.first {
            let currentPoint = touch.previousLocation(in: self)
            
            let minusYPoint = currentPoint.y - touchPoint.y
            let minusXPoint = currentPoint.x - touchPoint.x
            let rightConst = self.rightConst.constant - minusXPoint
            let bottomConst = self.bottomConst.constant - minusYPoint
            let limitYConst = (self.bounds.height - (self.topConst.constant + bottomConst +  PKCCropHelper.shared.minSize))
            let limitXConst = (self.bounds.width - (self.leftConst.constant + rightConst +  PKCCropHelper.shared.minSize))

            if bottomConst >= 0 && minusYPoint < 0 && limitYConst > 0{
                self.bottomConst.constant = bottomConst
            }else if bottomConst >= 0 && minusYPoint >= 0 && self.limitBottomConst.constant <= bottomConst{
                self.bottomConst.constant = bottomConst
            }

            if rightConst >= 0 && minusXPoint < 0 && limitXConst > 0{
                self.rightConst.constant = rightConst
            }else if rightConst >= 0 && minusXPoint >= 0 && self.limitRightConst.constant <= rightConst{
                self.rightConst.constant = rightConst
            }

            self.touchPoint = currentPoint
            self.makeMask()
        }
    }

}

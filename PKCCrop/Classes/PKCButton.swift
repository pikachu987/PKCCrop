//
//  PKCButton.swift
//  Pods
//
//  Created by Kim Guanho on 2017. 8. 26..
//
//

import UIKit

class PKCButton: UIButton {
    var xView: UIView?
    var yView: UIView?
    
    private let maxSize: CGFloat = 36
    private let minSize: CGFloat = 2
    override func awakeFromNib() {
        super.awakeFromNib()
        let xView = UIView(frame: .zero)
        xView.backgroundColor = .white
        xView.isUserInteractionEnabled = false
        xView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(xView)
        xView.widthConst(self.maxSize)
        xView.heightConst(self.minSize)
        self.xView = xView
        
        let yView = UIView(frame: .zero)
        yView.backgroundColor = .white
        yView.isUserInteractionEnabled = false
        yView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(yView)
        yView.widthConst(self.minSize)
        yView.heightConst(self.maxSize)
        self.yView = yView
    }
    
    private func attributed(_ view: UIView, attr1: NSLayoutAttribute, attr2: NSLayoutAttribute){
        self.addConstraint(NSLayoutConstraint(item: self, attribute: attr1, relatedBy: .equal, toItem: view, attribute: attr2, multiplier: 1, constant: 0))
    }
    
    
    func leftTop(){
        guard let xView = self.xView, let yView = self.yView else {
            return
        }
        self.attributed(xView, attr1: .top, attr2: .top)
        self.attributed(xView, attr1: .leading, attr2: .leading)
        self.attributed(yView, attr1: .top, attr2: .top)
        self.attributed(yView, attr1: .leading, attr2: .leading)
    }
    
    func rightTop(){
        guard let xView = self.xView, let yView = self.yView else {
            return
        }
        self.attributed(xView, attr1: .top, attr2: .top)
        self.attributed(xView, attr1: .trailing, attr2: .trailing)
        self.attributed(yView, attr1: .top, attr2: .top)
        self.attributed(yView, attr1: .trailing, attr2: .trailing)
    }
    
    func leftBottom(){
        guard let xView = self.xView, let yView = self.yView else {
            return
        }
        self.attributed(xView, attr1: .bottom, attr2: .bottom)
        self.attributed(xView, attr1: .leading, attr2: .leading)
        self.attributed(yView, attr1: .bottom, attr2: .bottom)
        self.attributed(yView, attr1: .leading, attr2: .leading)
    }
    
    func rightBottom(){
        guard let xView = self.xView, let yView = self.yView else {
            return
        }
        self.attributed(xView, attr1: .bottom, attr2: .bottom)
        self.attributed(xView, attr1: .trailing, attr2: .trailing)
        self.attributed(yView, attr1: .bottom, attr2: .bottom)
        self.attributed(yView, attr1: .trailing, attr2: .trailing)
    }
}

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


public enum PKCCropLineType{
    case show, hide, `default`
}


public class PKCCropHelper{
    public static let shared = PKCCropHelper()

    public var isNavigationBarShow = false
    public var lineType: PKCCropLineType = .default
    public var maskAlpha: CGFloat = 0.4
    public var barTintColor: UIColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
    public var tintColor: UIColor = UIColor(red: 0, green: 0.4, blue: 1, alpha: 1)
    
    public var isDegressShow = true
    public var degressBeforeImage: UIImage? = nil
    public var degressAfterImage: UIImage? = nil
    
    var isCropRate = false
    var isCircle = false

    let minSize: CGFloat = 120

    private init() { }
}

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
        
        self.pkcCrop.delegate = self
        
        
        let _ = PKCCropManager.shared.setRate(rateWidth: 16, rateHeight: 9)
        PKCCropManager.shared.cropType = .rateAndRotate
        PKCCropManager.shared.isZoomAnimation = false
        PKCCropManager.shared.isZoom = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraAction(_ sender: Any) {
        self.pkcCrop.cameraCrop()
        self.imageView.image = nil
    }
    @IBAction func galleryAction(_ sender: Any) {
        self.pkcCrop.photoCrop()
        self.imageView.image = nil
    }
    @IBAction func otherAction(_ sender: Any) {
        self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
        self.imageView.image = nil
    }
    
    
    
    
    //Test
    //test입니다.
    @IBOutlet var detailTestTableView: UITableView!
    @IBOutlet var imageView: UIImageView!
    var testArray : [[String]] = [
        [
            "free rate And margin Camera(자율크롭과 공백있게 카메라)",
            "free rate And margin Photo(자율크롭과 공백있게 사진)",
            "free rate And margin Other1(자율크롭과 공백있게 기타1)",
            "free rate And margin Other2(자율크롭과 공백있게 기타2)"
        ],[
            "free rate And none margin Camera(자율크롭과 공백없게 카메라)",
            "free rate And none margin Photo(자율크롭과 공백없게 사진)",
            "free rate And none margin Other1(자율크롭과 공백없게 기타1)",
            "free rate And none margin Other2(자율크롭과 공백없게 기타2)",
            ],[
                "free rate And rotate Camera(자율크롭과 회전 카메라)",
                "free rate And rotate Photo(자율크롭과 회전 사진)",
                "free rate And rotate Other1(자율크롭과 회전 기타1)",
                "free rate And rotate Other2(자율크롭과 회전 기타2)"
        ],[
            "rate And margin Camera(비율크롭과 공백있게 카메라)",
            "rate And margin Photo(비율크롭과 공백있게 사진)",
            "rate And margin Other1(비율크롭과 공백있게 기타1)",
            "rate And margin Other2(비율크롭과 공백있게 기타2)",
            ],[
                "rate And none margin Camera(비율크롭과 공백없게 카메라)",
                "rate And none margin Photo(비율크롭과 공백없게 사진)",
                "rate And none margin Other1(비율크롭과 공백없게 기타1)",
                "rate And none margin Other2(비율크롭과 공백없게 기타2)",
                ],[
                    "rate And rotate Camera(비율크롭과 회전 카메라)",
                    "rate And rotate Photo(비율크롭과 회전 사진)",
                    "rate And rotate Other1(비율크롭과 회전 기타1)",
                    "rate And rotate Other2(비율크롭과 회전 기타2)"
        ],[
            "rate And margin circle Camera(비율크롭과 공백있는 동그라미 크롭 카메라)",
            "rate And margin circle Photo(비율크롭과 공백있는 동그라미 크롭 사진)",
            "rate And margin circle Other1(비율크롭과 공백있는 동그라미 크롭 기타1)",
            "rate And margin circle Other2(비율크롭과 공백있는 동그라미 크롭 기타2)",
            ],[
                "rate And none margin circle Camera(비율크롭과 공백없는 동그라미 크롭 카메라)",
                "rate And none margin circle Photo(비율크롭과 공백없는 동그라미 크롭 사진)",
                "rate And none margin circle Other1(비율크롭과 공백없는 동그라미 크롭 기타1)",
                "rate And none margin circle Other2(비율크롭과 공백없는 동그라미 크롭 기타2)",
                ],[
                    "rate And rotate circle Camera(비율크롭과 회전 동그라미 크롭 카메라)",
                    "rate And rotate circle Photo(비율크롭과 회전 동그라미 크롭 사진)",
                    "rate And rotate circle Other1(비율크롭과 회전 동그라미 크롭 기타1)",
                    "rate And rotate circle Other2(비율크롭과 회전 동그라미 크롭 기타2)"
        ]
    ]
}



//The delegate to receive after crop.
//crop 이후 받아오는 delegate입니다.
extension ViewController: PKCCropDelegate{
    func pkcCropAccessPermissionsDenied(_ type: UIImagePickerControllerSourceType) {
        print("denied \(type)")
    }
    
    func pkcCropController() -> UIViewController {
        return self
    }
    
    
    func pkcCropImage(_ image: UIImage) {
        self.imageView.image = image
    }
}





//detail test
extension ViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testArray[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "free rate And margin(자유비율크롭 공백있게)"
        }else if section == 1{
            return "free rate And none margin(자유비율크롭 공백없게)"
        }else if section == 2{
            return "free rate And rotate margin(자유비율크롭 회전)"
        }else if section == 3{
            return "rate And margin(비율크롭 공백있게)"
        }else if section == 4{
            return "rate And none margin(비율크롭 공백없게)"
        }else if section == 5{
            return "rate And rotate margin(비율크롭 회전)"
        }else if section == 6{
            return "rate And margin circle(비율크롭 공백있게 원)"
        }else if section == 7{
            return "free rate And none margin circle(비율크롭 공백없게 원)"
        }else{
            return "free rate And rotate circle(비율크롭 회전 원)"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.testArray[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.textLabel?.text = row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.imageView.image = nil
        _ = PKCCropManager.shared.setRate(rateWidth: 1, rateHeight: 1)
        PKCCropManager.shared.isZoom = false
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .freeRateAndMargin
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .freeRateAndMargin
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .freeRateAndMargin
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .freeRateAndMargin
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .freeRateAndNoneMargin
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .freeRateAndNoneMargin
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .freeRateAndNoneMargin
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .freeRateAndNoneMargin
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 2{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .freeRateAndRotate
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .freeRateAndRotate
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .freeRateAndRotate
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .freeRateAndRotate
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 3{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndMargin
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndMargin
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndMargin
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndMargin
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 4{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndNoneMargin
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndNoneMargin
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndNoneMargin
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndNoneMargin
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 5{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndRotate
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndRotate
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndRotate
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndRotate
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 6{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndMarginCircle
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndMarginCircle
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndMarginCircle
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndMarginCircle
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 7{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndNoneMarginCircle
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndNoneMarginCircle
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndNoneMarginCircle
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndNoneMarginCircle
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }else if indexPath.section == 8{
            if indexPath.row == 0{
                PKCCropManager.shared.cropType = .rateAndRotateCircle
                self.pkcCrop.cameraCrop()
            }else if indexPath.row == 1{
                PKCCropManager.shared.cropType = .rateAndRotateCircle
                self.pkcCrop.photoCrop()
            }else if indexPath.row == 2{
                PKCCropManager.shared.cropType = .rateAndRotateCircle
                self.pkcCrop.otherCrop(UIImage(named: "test1.png")!)
            }else if indexPath.row == 3{
                PKCCropManager.shared.cropType = .rateAndRotateCircle
                self.pkcCrop.otherCrop(UIImage(named: "test2.png")!)
            }
        }
    }
}
extension ViewController: UITableViewDelegate{
}



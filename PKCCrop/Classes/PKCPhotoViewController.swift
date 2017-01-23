//
//  PKCPhotoViewController.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit
import Photos

class PKCPhotoViewController: UIViewController{
    @IBOutlet var collectionView: UICollectionView!
    
    
    // MARK: - properties
    var delegate: PKCCropPictureDelegate?
    var assetsFetchResults: PHFetchResult<PHAsset>!
    var imageManger: PHCachingImageManager!
    
    // MARK: - init
    //Import PKCPhotoViewController xib file
    //PKCPhotoViewController xib파일을 불러온다
    init() {
        super.init(nibName: "PKCPhotoViewController", bundle: Bundle(for: PKCCrop.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: "PKCPhotoCell", bundle: Bundle(for: PKCCrop.self)), forCellWithReuseIdentifier: "PKCPhotoCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flow.itemSize = CGSize(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.width/2.5)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                self.gallerySelected()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //Import photos from users' photo albums
    //사용자 사진첩에 있는 사진을 가져온다
    func gallerySelected(){
        self.imageManger = PHCachingImageManager()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assetsFetchResults = PHAsset.fetchAssets(with: options)
        self.collectionView.reloadData()
    }
    
    //Go back to previous screen
    //이전화면으로 이동
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



extension PKCPhotoViewController: UICollectionViewDelegate{
}
extension PKCPhotoViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.assetsFetchResults != nil{
            return self.assetsFetchResults.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PKCPhotoCell", for: indexPath) as! PKCPhotoCell
        let asset: PHAsset = self.assetsFetchResults[indexPath.item]
        self.imageManger.requestImage(for: asset, targetSize: cell.frame.size, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (result:UIImage?, info: [AnyHashable:Any]?) in cell.img.image = result})
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.assetsFetchResults[indexPath.item]
        let pkcCropViewController = PKCCropViewController()
        pkcCropViewController.delegate = self
        pkcCropViewController.cropType = CropType.photo
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            let _ = PHImageManager.default().requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFit, options: nil, resultHandler: {(result: UIImage?, info: [AnyHashable: Any]?) in
                DispatchQueue.global().async {
                    var isRepeat = true
                    while(isRepeat){
                        if let vc = self.navigationController?.visibleViewController as? PKCCropViewController{
                            if vc.isViewLoaded{
                                isRepeat = false
                            }
                        }
                    }
                    Thread.sleep(forTimeInterval: 0.1)
                    DispatchQueue.main.async {
                        pkcCropViewController.changeImage(result!)
                    }
                }
            })
        }
        self.show(pkcCropViewController, sender: nil)
        CATransaction.commit()
    }
}

// MARK: - extension PKCCropPictureDelegate
//Receive the image and pass it to the delegate.
//이미지를 받아서 delegate에 연결된 곳으로 전달한다.
extension PKCPhotoViewController: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropPicture(image)
    }
}

//
//  PhotoViewController.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/3/29.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

typealias sendDicBlock = (Dictionary<String, Any>)->()

class PhotoViewController: UIViewController {
    
    var photosG = NSMutableArray()
    let SCREEN_SIZE = UIScreen.main.bounds
    var getImageDic: sendDicBlock?
    var maxC : String?
    var isOriginal : String?
    var oldDic = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isHavePhoto()
    }
    
    class func getAlbumPhotos(control : UIViewController,maxCount : String,isHaveOriginal : String,oldImageDic : Dictionary<String, Any>,completed:@escaping (_ resultDic : Dictionary<String, Any>) -> ()){
        let photoVC = PhotoViewController()
        photoVC.maxC = maxCount
        photoVC.isOriginal = isHaveOriginal
        photoVC.oldDic = oldImageDic
        photoVC.getImageDic = completed
        let navi = UINavigationController.init(rootViewController: photoVC)
        control.present(navi, animated: true, completion: nil)
        photoVC.createView()
    }
    
    func createView() {
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        photosG = NSMutableArray.init()
        self.addTitle()
        
        //判断权限
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus) in
                if status == PHAuthorizationStatus.authorized{
                    DispatchQueue.main.async {
                        self.createSubView()
                    }
                }else{
                    print("没有开权限")
                    //授权路径
                    UIApplication.shared.open(NSURL.init(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
                }
            })
        }else if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            UIApplication.shared.open(NSURL.init(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }else{
            self.createSubView()
        }
    }
    
    //头视图
    func addTitle() {
        self.title = "相册"
        
        let rightBtn = UIButton.init(type: UIButtonType.custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.isExclusiveTouch = true
        rightBtn.addTarget(self, action: #selector(clickBack), for: UIControlEvents.touchUpInside)
        
        let rightLbl = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: 44, height: 44))
        rightLbl.text = "取消"
        rightLbl.font = UIFont.systemFont(ofSize: 16.0)
        rightLbl.textColor = UIColor.black
        
        rightBtn.addSubview(rightLbl)
        
        let rightItem = UIBarButtonItem.init(customView: rightBtn)
        
        let SystemVersion = UIDevice.current.systemVersion as NSString
        let version = SystemVersion.floatValue
        
        if version >= 7.0  {
            let spaceItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            spaceItem.width = -10
            self.navigationItem.rightBarButtonItems = [spaceItem,rightItem]
        }else{
            self.navigationItem.rightBarButtonItem = rightItem
        }
        
    }

    func createSubView() {
        let backScroll = UIScrollView.init(frame: CGRect.init(x: 0, y: 64, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height - 64))
        backScroll.tag = 1000;
        self.view.addSubview(backScroll)
        
        let smartAlbums : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        
        for i in 0..<smartAlbums.count {
            //获取一个相册的PHAssetCollection
            let collection = smartAlbums[i] as PHCollection
            
            if collection.isKind(of: PHAssetCollection.self) {
                let assetCollection = collection as! PHAssetCollection
                
                if assetCollection.localizedTitle == "相机交卷" || assetCollection.localizedTitle == "所有照片"{
                    photosG.insert(assetCollection, at: 0)
                }else{
                    photosG.add(assetCollection)
                }
            }else{
                print("Fetch collection not PHCollection:\(collection)")
            }
        }
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        for j in 0..<topLevelUserCollections.count {
            let collection = topLevelUserCollections[j]
            
            if collection.isKind(of: PHAssetCollection.self) {
                let assetCollection = collection as! PHAssetCollection
                // 从一个相册中获取的PHFetchResult中包含的才是PHAsset
                photosG.add(assetCollection)
            }else{
                print("Fetch collection not PHCollection:\(collection)")
            }
        }
        
        for k in 0..<photosG.count {
            let albumBtn = UIButton.init(type: UIButtonType.custom)
            albumBtn.frame = CGRect.init(x: 0, y: 60 * k, width: Int(SCREEN_SIZE.width), height: 60)
            albumBtn.addTarget(self, action: #selector(pressPhoto), for: UIControlEvents.touchUpInside)
            albumBtn.tag = 1500 + k
            backScroll.addSubview(albumBtn)
            
            let lineLbl = UILabel.init(frame: CGRect.init(x: 0, y: 59.5, width: SCREEN_SIZE.width, height: 0.5))
            lineLbl.backgroundColor = UIColor.lightGray
            albumBtn.addSubview(lineLbl)
            
            let assetCollection = photosG[k] as! PHAssetCollection
            let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            
            let titleLbl = UILabel.init(frame: CGRect.init(x: 70, y: 0, width: SCREEN_SIZE.width - 70, height: 60))
            let titleStr = assetCollection.localizedTitle!
            titleLbl.text = "\(titleStr) (\(fetchResult.count))"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.sizeToFit()
            titleLbl.frame = CGRect.init(x: 70, y: 0, width: titleLbl.frame.size.width, height: 60)
            albumBtn.addSubview(titleLbl)
            
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 60.0, height: 60.0))
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            albumBtn.addSubview(imageView)
            
            let countLabel = UILabel.init(frame: CGRect.init(x: titleLbl.frame.maxX + 5, y: (albumBtn.frame.size.height - 20) / 2, width: 20.0, height: 20.0))
            countLabel.backgroundColor = UIColor.init(red: 32.0 / 255.0, green: 172.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
            countLabel.layer.cornerRadius = 10.0
            countLabel.clipsToBounds = true
            countLabel.textColor = UIColor.white
            countLabel.font = UIFont.systemFont(ofSize: 12.0)
            countLabel.tag = 10000 + k
            countLabel.textAlignment = NSTextAlignment.center
            countLabel.isHidden = true
            albumBtn.addSubview(countLabel)
            
            self.isHavePhoto()
            
            var asset = PHAsset.init()
            
            let fetchCount : Int = fetchResult.count
            
            if fetchCount != 0 {
                asset = fetchResult[fetchResult.count - 1]
            }else{
                imageView.image = UIImage.init(named: "noimage")
            }
            
            // 使用PHImageManager从PHAsset中请求图片
            let ImageManager = PHImageManager.init()
            ImageManager.requestImage(for: asset, targetSize: CGSize.init(width: 60.0, height: 60.0), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (resultImage, info) in
                imageView.image = resultImage
            })
        }
        
        backScroll.contentSize = CGSize.init(width: 0, height: photosG.count * 60)
    }
    
    func isHavePhoto() {
        let backScroll = self.view.viewWithTag(1000)
        
        if oldDic.count > 0 {
            let photoArray = oldDic["photoArray"] as! NSArray
            
            for i in 0..<photosG.count {
                let albumBtn = backScroll?.viewWithTag(1500 + i) as! UIButton
                let countLbl = albumBtn.viewWithTag(10000 + i) as! UILabel
                
                var sum = 0
                
                let assetCollection = photosG[i] as! PHAssetCollection
                
                if photoArray.count > 0 {
                    for k in 0..<photoArray.count {
                        if assetCollection.localIdentifier == (photoArray[k] as! NSDictionary)["albumIdentifier"] as! String{
                            sum += 1
                        }
                        
                        if sum > 0 {
                            countLbl.text = "\(sum)"
                            countLbl.isHidden = false
                        }else{
                            countLbl.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    //点击返回
    func clickBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //点击相册
    func pressPhoto(albumBtn:UIButton) {
        let albumArray = NSMutableArray.init()
        let fetchResult = PHAsset.fetchAssets(in: photosG[albumBtn.tag - 1500] as! PHAssetCollection, options: nil)
        
        for i in 0..<fetchResult.count {
            let asset = fetchResult[i] as PHAsset
            albumArray.add(asset)
        }
        
        let assetColleciton = photosG.object(at: albumBtn.tag - 1500) as! PHAssetCollection
        
        let photoListVc = PhotoListViewController()
        photoListVc.PHFetchR = fetchResult as? PHFetchResult<AnyObject>
        photoListVc.albumIdentifier = assetColleciton.localIdentifier
        photoListVc.maxC = maxC
        photoListVc.isOriginal = isOriginal
        photoListVc.oldDic = oldDic
        
        photoListVc.sendToLast = {dic,isBack in
            self.oldDic = dic
            if isBack == true {
                self.getImageDic!(self.oldDic)
            }else{
                self.isHavePhoto()
            }
        }
        
        self.navigationController?.pushViewController(photoListVc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  ViewController.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/3/29.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    let SCREEN_SIZE = UIScreen.main.bounds
    var photoScroll : UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createViews()
    }
    
    //创建点击按钮，进入相册或相机
    func createViews() {
        self.title = "photokit"
        
        let clickBtn = UIButton.init()
        clickBtn.frame = CGRect.init(x: 0, y: 64, width: SCREEN_SIZE.width, height: 40)
        clickBtn.setTitle("点击", for: UIControlState.normal)
        clickBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        clickBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        clickBtn.backgroundColor = UIColor.purple
        clickBtn.addTarget(self, action: #selector(choiceAlbumOrCamera), for: UIControlEvents.touchUpInside)
        self.view.addSubview(clickBtn)
        
        let contentLbl = UILabel.init(frame: CGRect.init(x: 0, y: clickBtn.frame.maxY, width: SCREEN_SIZE.width, height: 20.0))
        contentLbl.font = UIFont.systemFont(ofSize: 12.0)
        contentLbl.textColor = UIColor.black
        contentLbl.textAlignment = NSTextAlignment.center
        contentLbl.text = "选择图片点击完成后下方左右滑动查看图片"
        self.view.addSubview(contentLbl)
        
        photoScroll = UIScrollView.init(frame: CGRect.init(x: 0, y: clickBtn.frame.maxY + 20, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height - clickBtn.frame.maxY - 20))
        photoScroll?.showsVerticalScrollIndicator = false
        photoScroll?.showsHorizontalScrollIndicator = false
        photoScroll?.backgroundColor = UIColor.white
        photoScroll?.isPagingEnabled = true
        self.view.addSubview(photoScroll!)
    }
    
    //按钮事件
    func choiceAlbumOrCamera(sender:UIButton) {
        var alert : UIAlertController!
        alert = UIAlertController.init(title: "提示", message: "添加照片", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            
        }
        let cameraAction = UIAlertAction.init(title: "拍照", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            
        }
        let albumAction = UIAlertAction.init(title: "相册", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
//            let photoVC = PhotoViewController()
            
            let dic = Dictionary<String, Any>()
            
            PhotoViewController.getAlbumPhotos(control: self, maxCount: "9", isHaveOriginal: "1", oldImageDic: dic, completed: { (resultDic) in
                if resultDic.count > 0{
                    print(resultDic)
                    self.updateScroll(photoDic: resultDic)
                }
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateScroll(photoDic : [String : Any]) {
        let photoArray = photoDic["photoArray"] as! NSArray
        for i in 0..<photoArray.count {
            let asset = (photoArray[i] as! NSDictionary)["photoAsset"] as! PHAsset
            
            let photoImageView = UIImageView.init(frame: CGRect.init(x: CGFloat(i) * SCREEN_SIZE.width + 20.0, y: 20.0, width: SCREEN_SIZE.width - 40, height: (photoScroll?.frame.size.height)! - 40))
            photoImageView.contentMode = UIViewContentMode.scaleAspectFit
            photoImageView.clipsToBounds = true
            photoScroll?.addSubview(photoImageView)
            
            photoScroll?.contentSize = CGSize.init(width: CGFloat(photoArray.count) * SCREEN_SIZE.width, height: 0)
            
            let reques = PHImageRequestOptions.init()
            reques.isSynchronous = false
            reques.isNetworkAccessAllowed = false
            reques.resizeMode = PHImageRequestOptionsResizeMode.exact
            reques.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
            
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: reques) { (resultImage, Info) in
                photoImageView.image = resultImage
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


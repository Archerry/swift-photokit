//
//  PhotoBigImgViewController.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/3/31.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

typealias sendToList = ([String : Any],_ isBack:Bool) ->()

class PhotoBigImgViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate {

    var PHFetchR : PHFetchResult<AnyObject>?
    var whichOne : String?
    var _bigImgCollect : UICollectionView?
    var _currentScroll : UIScrollView?
    var _currentimageView : UIImageView?
    var _backBlackView : UIView?
    var currentX : CGFloat?
    var maxC : String?
    var isOriginal : String?
    var oldDic = [String : Any]()
    var albumIdentifier : String?
    var sendList : sendToList?
    let SCREEN_SIZE = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func createView() {
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = true
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: SCREEN_SIZE.width, height: SCREEN_SIZE.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        _bigImgCollect = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height), collectionViewLayout: layout)
        _bigImgCollect?.delegate = self as UICollectionViewDelegate
        _bigImgCollect?.dataSource = self as UICollectionViewDataSource
        _bigImgCollect?.backgroundColor = UIColor.black
        _bigImgCollect?.isPagingEnabled = true
        _bigImgCollect?.showsVerticalScrollIndicator = false
        _bigImgCollect?.showsHorizontalScrollIndicator = false
        _bigImgCollect?.register(PhotoBigImgCollectionViewCell.self, forCellWithReuseIdentifier: "bigCell")
        self.view.addSubview(_bigImgCollect!)
        
        let which = Int(whichOne!)
        currentX = SCREEN_SIZE.width * CGFloat(which!)
        
        _bigImgCollect?.setContentOffset(CGPoint.init(x: SCREEN_SIZE.width * CGFloat(which!), y: 0.0), animated: false)
        
        _backBlackView = UIView.init(frame: CGRect.init(x: SCREEN_SIZE.width * CGFloat(which!), y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height))
        _backBlackView?.backgroundColor = UIColor.black
        _bigImgCollect?.addSubview(_backBlackView!)
        
        _currentScroll = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height))
        _currentScroll?.showsVerticalScrollIndicator = false
        _currentScroll?.showsHorizontalScrollIndicator = false
        _currentScroll?.isPagingEnabled = false
        _currentScroll?.delegate = self
        //图片的放大倍数
        _currentScroll?.maximumZoomScale = 3.0
        //图片的最小倍数
        _currentScroll?.minimumZoomScale = 1.0
        
        _currentimageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height))
        _currentimageView?.contentMode = UIViewContentMode.scaleAspectFit
        _currentimageView?.clipsToBounds = true
        _currentScroll?.addSubview(_currentimageView!)
        _backBlackView?.addSubview(_currentScroll!)
        
        let reques = PHImageRequestOptions.init()
        reques.isSynchronous = false
        reques.isNetworkAccessAllowed = false
        reques.resizeMode = PHImageRequestOptionsResizeMode.fast
        reques.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        
        PHImageManager.default().requestImage(for: (PHFetchR?.object(at: which!))! as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: reques, resultHandler: { (resultImage, info) in
            self._currentimageView?.image = resultImage
        })

        
        //透明按钮
        let clearButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height))
        clearButton.backgroundColor = UIColor.clear
        clearButton.addTarget(self, action: #selector(pressClearBtn), for: UIControlEvents.touchUpInside)
        _currentScroll?.addSubview(clearButton)
        
        //上方视图
        let upView = UIView.init(frame:CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: 64.0))
        upView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
        upView.tag = 5000;
        self.view.addSubview(upView)
        
        let backButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 64.0, height: 64.0))
        backButton.addTarget(self, action: #selector(pressBack), for: UIControlEvents.touchUpInside)
        upView.addSubview(backButton)
        
        let backImageView = UIImageView.init(frame: CGRect.init(x: backButton.center.x - 10.0, y: backButton.center.y - 10.0, width: 20.0, height: 20.0))
        backImageView.image = UIImage.init(named: "photoBack")
        backButton.addSubview(backImageView)
        
        let selectButton = UIButton.init(frame: CGRect.init(x: SCREEN_SIZE.width - 64.0, y: 0, width: 64.0, height: 64.0))
        selectButton.addTarget(self, action: #selector(pressSelect), for: UIControlEvents.touchUpInside)
        selectButton.tag = 15000;
        selectButton.isSelected = false
        upView.addSubview(selectButton)
        
        let selectImageView = UIImageView.init(frame: CGRect.init(x: (selectButton.frame.size.width - 30.0) / 2, y: (selectButton.frame.size.width - 30.0) / 2, width: 30.0, height: 30.0))
        selectImageView.tag = 15001
        selectImageView.image = UIImage.init(named: "ico_check_nomal")
        selectButton.addSubview(selectImageView)
        
        
        //下方视图
        let downView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_SIZE.height - 44.0, width: SCREEN_SIZE.width, height: 44.0))
        downView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
        downView.tag = 10000
        self.view.addSubview(downView)
        
        if isOriginal == "1" {
            let originalButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44.0, height: 44.0))
            originalButton.tag = 8000
            originalButton.addTarget(self, action: #selector(pressOriginal), for: UIControlEvents.touchUpInside)
            downView.addSubview(originalButton)
            
            let originalImageView = UIImageView.init(frame: CGRect.init(x: originalButton.center.x - 10.0, y: originalButton.center.y - 10.0, width: 20.0, height: 20.0))
            originalImageView.image = UIImage.init(named: "selectDot")
            originalImageView.tag = 8001
            originalButton.addSubview(originalImageView)
            
            let originalLabel = UILabel.init(frame: CGRect.init(x: originalButton.frame.maxX + 5.0, y: (downView.frame.size.height - 20.0) / 2, width: 100.0, height: 20.0))
            originalLabel.font = UIFont.systemFont(ofSize: 12.0)
            originalLabel.textColor = UIColor.white
            originalLabel.text = "原图"
            originalLabel.tag = 8002
            downView.addSubview(originalLabel)
        }
        
        let completeButton = UIButton.init(frame: CGRect.init(x: SCREEN_SIZE.width - 80.0, y: 5.0, width: 80.0, height: 40.0))
        completeButton.tag = 20000
        completeButton.addTarget(self, action: #selector(pressComplete), for: UIControlEvents.touchUpInside)
        downView.addSubview(completeButton)
        
        let completeLabel = UILabel.init(frame: CGRect.init(x: 0, y: (downView.frame.size.height - 30.0) / 2, width: 20.0, height: 20.0))
        completeLabel.textColor = UIColor.white
        completeLabel.backgroundColor = UIColor.init(red: 32.0 / 255.0, green: 172.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
        completeLabel.font = UIFont.systemFont(ofSize: 12.0)
        completeLabel.layer.cornerRadius = 10.0
        completeLabel.clipsToBounds = true
        completeLabel.textAlignment = NSTextAlignment.center
        completeLabel.tag = 20001
        completeLabel.isHidden = true
        completeButton.addSubview(completeLabel)
        
        let completeStrLbl = UILabel.init(frame: CGRect.init(x: completeLabel.frame.maxX, y: (downView.frame.size.height - 30.0) / 2 - 6.0, width: 60.0, height: 30.0))
        completeStrLbl.text = "完成"
        completeStrLbl.textColor = UIColor.white
        completeStrLbl.textAlignment = NSTextAlignment.center
        completeButton.addSubview(completeStrLbl)
        
        let asset = PHFetchR?[which!] as! PHAsset
        
        if oldDic.count > 0 {
            let photoArray = oldDic["photoArray"] as! NSArray
            
            if photoArray.count > 0 {
                for i in 0..<photoArray.count {
                    if asset.localIdentifier == (photoArray[i] as! NSDictionary)["photoIdentifier"] as! String {
                        selectImageView.image = UIImage.init(named: "ico_check_select")
                        selectButton.isSelected = true
                    }
                }
                
                completeLabel.text = "\(photoArray.count)"
                completeLabel.isHidden = false
            }else{
                completeLabel.isHidden = true
            }
        }
    }
    
    func pressClearBtn() {
        let upView = self.view.viewWithTag(5000)
        let downView = self.view.viewWithTag(10000)
        
        if upView?.isHidden == true {
            upView?.isHidden = false
            downView?.isHidden = false
        }else{
            upView?.isHidden = true
            downView?.isHidden = true
        }
    }
    
    func pressBack() {
        self.sendList!(oldDic,false)
        self.navigationController?.popViewController(animated: true)
    }
    
    func pressSelect(selectBtn : UIButton) {
        let selectImgV = selectBtn.viewWithTag(15001) as! UIImageView
        let curr = (_backBlackView?.frame.origin.x)! / SCREEN_SIZE.width
        var photoArr = NSMutableArray()
        let asset = PHFetchR?[Int(curr)] as! PHAsset
        let downView = self.view.viewWithTag(10000)
        let completeLbl = downView?.viewWithTag(20001) as! UILabel
        
        if oldDic.count > 0 {
            photoArr = oldDic["photoArray"] as! NSMutableArray
        }
        
        if selectBtn.isSelected == true {
            for i in 0..<photoArr.count {
                if asset.localIdentifier == (photoArr[i] as! NSDictionary)["photoIdentifier"] as! String{
                    photoArr.removeObject(at: i)
                    break
                }
            }
            oldDic.updateValue(photoArr, forKey: "photoArray")
            selectBtn.isSelected = false
            selectImgV.image = UIImage.init(named: "ico_check_nomal")
        }else{
            if photoArr.count >= Int(maxC!)! {
                selectBtn.isSelected = false
            }else{
                selectImgV.image = UIImage.init(named: "ico_check_select")
                var dic = [String : Any]()
                dic.updateValue(asset.localIdentifier , forKey: "photoIdentifier")
                dic.updateValue(albumIdentifier!, forKey: "albumIdentifier")
                dic.updateValue(PHFetchR?[selectBtn.tag - 15000] as! PHAsset, forKey: "photoAsset")
                dic.updateValue(Int(curr), forKey: "currentItem")
                dic.updateValue(true, forKey: "isSelected")
                photoArr.add(dic)
                
                oldDic.updateValue(photoArr, forKey: "photoArray")
                selectBtn.isSelected = true
            }
        }
        
        if photoArr.count > 0 {
            completeLbl.text = "\(photoArr.count)"
            completeLbl.isHidden = false
        }else{
            completeLbl.isHidden = true
        }
        
        if isOriginal == "0" {
            oldDic.updateValue("0", forKey: "isOriginal")
        }else{
            oldDic.updateValue("1", forKey: "isOriginal")
        }
    }
    
    func pressOriginal(originalBtn : UIButton) {
        let oriLbl = self.view.viewWithTag(8002) as! UILabel
        let oriImg = originalBtn.viewWithTag(8001) as! UIImageView
        
        if originalBtn.isSelected == true {
            originalBtn.isSelected = false
            oriImg.image = UIImage.init(named: "selectDot")
            oriLbl.text = "原图"
        }else{
            originalBtn.isSelected = true
            oriImg.image = UIImage.init(named: "selectedDot")
            oriLbl.text = String.init(format: "原图%.2fM", self.computesTheSizes(currentImage: (_currentimageView?.image)!))
        }
    }
    
    func pressComplete(completeBtn : UIButton) {
        self.sendList!(oldDic,true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func computesTheSizes(currentImage : UIImage) -> Float {
        let imageData = UIImageJPEGRepresentation(currentImage, 1.0) as! NSMutableData
        let imageSize = Float(imageData.length) / (1024.00 * 1024.00)
        return imageSize
    }
    
    //MARK: - UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (PHFetchR?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bigCell", for: indexPath) as! PhotoBigImgCollectionViewCell
        cell.getBigImage(asset: PHFetchR?[indexPath.item] as! PHAsset)
        return cell
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView .isEqual(_bigImgCollect) {
//        let oriLbl = self.view.viewWithTag(8002) as! UILabel
            let selectButton = self.view.viewWithTag(15000) as! UIButton
            let selectImageV = selectButton.viewWithTag(15001) as! UIImageView

            currentX = scrollView.contentOffset.x
            
            _backBlackView?.frame = CGRect.init(x: currentX!, y: (_currentScroll?.frame.minY)!, width: (_currentScroll?.frame.size.width)!, height: (_currentScroll?.frame.size.height)!)
            
            _currentScroll?.zoomScale = 1.0
            
            let reques = PHImageRequestOptions.init()
            reques.isSynchronous = false
            reques.isNetworkAccessAllowed = false
            reques.resizeMode = PHImageRequestOptionsResizeMode.fast
            reques.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
            
            PHImageManager.default().requestImage(for: PHFetchR?.object(at: Int(scrollView.contentOffset.x / SCREEN_SIZE.width)) as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: reques, resultHandler: { (resultImage, info) in
                self._currentimageView?.image = resultImage
                if self.isOriginal == "1" {
                    let oriLbl = self.view.viewWithTag(8002) as! UILabel
                    oriLbl.text = String.init(format: "原图%.2fM", self.computesTheSizes(currentImage: (self._currentimageView?.image)!))
                }
                self._bigImgCollect?.bringSubview(toFront: self._backBlackView!)
                self._backBlackView?.isHidden = false
            })
            
            let curr = scrollView.contentOffset.x / SCREEN_SIZE.width
            let asset = PHFetchR?[Int(curr)] as! PHAsset
            if oldDic.count > 0 {
                let photoArray = oldDic["photoArray"] as! NSArray
                
                for i in 0..<photoArray.count {
                    if asset.localIdentifier == (photoArray[i] as! NSDictionary)["photoIdentifier"] as! String{
                        selectButton.isSelected = true
                        selectImageV.image = UIImage.init(named: "ico_check_select")
                        break
                    }else{
                        selectButton.isSelected = false
                        selectImageV.image = UIImage.init(named: "ico_check_nomal")
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView .isEqual(_bigImgCollect) {
            let currentXed = abs(scrollView.contentOffset.x - currentX!)
            if currentXed > SCREEN_SIZE.width / 2 {
                _currentimageView?.image = UIImage.init()
                _backBlackView?.isHidden = true
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _currentimageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView != _bigImgCollect {
            var imgPoint = CGPoint.init()
            
            if scrollView.contentSize.width > scrollView.frame.size.width {
                imgPoint.x = scrollView.contentSize.width / 2
            }else{
                imgPoint.x = scrollView.frame.size.width / 2
            }
            
            if scrollView.contentSize.height > scrollView.frame.size.height {
                imgPoint.y = scrollView.contentSize.height / 2
            }else{
                imgPoint.y = scrollView.frame.size.height / 2
            }
            
            _currentimageView?.center = imgPoint
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

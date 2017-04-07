//
//  PhotoListViewController.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/3/30.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

typealias sendPhotoDic = ([String : Any],_ isBack:Bool)->()

class PhotoListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PhotoListDelegate {
    
    var PHFetchR : PHFetchResult<AnyObject>!
    var albumIdentifier : String?
    var _collectView : UICollectionView?
    var maxC : String?
    var isOriginal : String?
    var oldDic = [String : Any]()
    var isBackTo : Bool?
    var sendToLast : sendPhotoDic?
    let SCREEN_SIZE = UIScreen.main.bounds
    let dataSource = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationSetting()
        if (PHFetchR?.count)! > 0 {
            isBackTo = false
            self.createdDatasource()
            self.createView()
        }
    }
    
    func createdDatasource() {
        for i in 0..<PHFetchR.count {
            var dataDic = [String : Any]()
            
            let assetCollection = PHFetchR?[i] as? PHAsset
            
            if oldDic.count > 0 {
                let photoArray = oldDic["photoArray"] as! NSArray
                if photoArray.count > 0 {
                    for j in 0..<photoArray.count {
                        if (photoArray[j] as! NSDictionary)["photoIdentifier"] as? String == assetCollection?.localIdentifier {
                            dataDic.updateValue(PHFetchR[i], forKey: "photoAsset")
                            dataDic.updateValue(true, forKey: "isSelected")
                            dataDic.updateValue(i, forKey: "currentItem")
                            dataDic.updateValue(assetCollection!.localIdentifier, forKey: "photoIdentifier")
                            break
                        }else{
                            dataDic.updateValue(PHFetchR[i], forKey: "photoAsset")
                            dataDic.updateValue(false, forKey: "isSelected")
                            dataDic.updateValue(i, forKey: "currentItem")
                            dataDic.updateValue(assetCollection!.localIdentifier, forKey: "photoIdentifier")
                        }
                    }
                }
            }else{
                dataDic.updateValue(PHFetchR[i], forKey: "photoAsset")
                dataDic.updateValue(false, forKey: "isSelected")
                dataDic.updateValue(i, forKey: "currentItem")
                dataDic.updateValue(assetCollection!.localIdentifier, forKey: "photoIdentifier")
            }
            
            dataSource.add(dataDic)
        }
    }

    func createView() {
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        if oldDic.count > 0 {
            let photoArr = oldDic["photoArray"] as! NSArray
            let count = String(photoArr.count)
            self.title = "\(count) / \(maxC!)"
        }else{
            self.title = "0 / \(maxC!)"
        }
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: (SCREEN_SIZE.width - 25) / 4, height: (SCREEN_SIZE.width - 25) / 4)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        
        _collectView = UICollectionView.init(frame: CGRect.init(x: 0, y: 64.0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height - 64.0 - 50.0), collectionViewLayout: layout)
        _collectView?.register(PhotoListCollectionViewCell.self, forCellWithReuseIdentifier: "photoListCell")
        _collectView?.delegate = self
        _collectView?.dataSource = self
        _collectView?.backgroundColor = UIColor.white
        _collectView?.showsVerticalScrollIndicator = false
        _collectView?.showsHorizontalScrollIndicator = false
        self.view.addSubview(_collectView!)
        
        let downView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_SIZE.height - 50.0, width: SCREEN_SIZE.width, height: 50.0))
        downView.backgroundColor = UIColor.white
        self.view.addSubview(downView)
        
        let completeButton = UIButton.init(frame: CGRect.init(x: SCREEN_SIZE.width - 80.0, y: 5.0, width: 80.0, height: 40.0))
        completeButton.tag = 1000
        completeButton.addTarget(self, action: #selector(pressComplete), for: UIControlEvents.touchUpInside)
        downView.addSubview(completeButton)
        
        let completeLabel = UILabel.init(frame: CGRect.init(x: 0, y: (completeButton.frame.size.height - 20) / 2, width: 20, height: 20))
        completeLabel.textColor = UIColor.white
        completeLabel.backgroundColor = UIColor.init(red: 32.0 / 255.0, green: 172.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
        completeLabel.font = UIFont.systemFont(ofSize: 12.0)
        completeLabel.layer.cornerRadius = 10
        completeLabel.clipsToBounds = true
        completeLabel.textAlignment = NSTextAlignment.center
        completeLabel.tag = 1500
        completeButton.addSubview(completeLabel)
        
        if oldDic.count > 0 {
            let photoArray = oldDic["photoArray"] as! NSArray
            if photoArray.count > 0 {
                completeLabel.text = "\(photoArray.count)"
            }else{
                completeLabel.isHidden = true
            }
        }else{
            completeLabel.isHidden = true
        }
        
        let compLabel = UILabel.init(frame: CGRect.init(x: completeLabel.frame.maxX, y: (completeButton.frame.size.height - 30) / 2, width: 60.0, height: 30.0))
        compLabel.text = "完成"
        compLabel.textAlignment = NSTextAlignment.center
        completeButton.addSubview(compLabel)
    }
    
    func navigationSetting() {
        //左边返回按钮
        let leftButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        leftButton.addTarget(self, action: #selector(pressBack), for: UIControlEvents.touchUpInside)
        
        let leftImage = UIImageView.init(frame: CGRect.init(x: (44 - 20) / 2, y: (44 - 20) / 2, width: 20, height: 20))
        leftImage.image = UIImage.init(named: "news_back")
        leftButton.addSubview(leftImage)
        
        let leftItem = UIBarButtonItem.init(customView: leftButton)
        
        let SystemVersion = UIDevice.current.systemVersion as NSString
        let version = SystemVersion.floatValue
        
        if version >= 7.0  {
            let spaceItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            spaceItem.width = -10
            self.navigationItem.leftBarButtonItems = [leftItem,spaceItem]
        }else{
            self.navigationItem.leftBarButtonItem = leftItem
        }
        
        //右边取消按钮
        let rightButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 65, height: 44))
        rightButton.addTarget(self, action: #selector(cancel), for: UIControlEvents.touchUpInside)
        
        let rightLabel = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: 45, height: 44))
        rightLabel.text = "取消"
        rightLabel.font = UIFont.systemFont(ofSize: 16.0)
        rightLabel.textColor = UIColor.black
        rightButton.addSubview(rightLabel)
        
        let rightItem = UIBarButtonItem.init(customView: rightButton)

        if version >= 7.0  {
            let spaceItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            spaceItem.width = -10
            self.navigationItem.rightBarButtonItems = [spaceItem,rightItem]
        }else{
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    //左边返回按钮
    func pressBack() {
        self.sendToLast!(oldDic,isBackTo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    //右边取消按钮
    func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func pressComplete() {
        oldDic.updateValue(isOriginal!, forKey: "isOriginal")
        self.sendToLast!(oldDic,true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - collectionView代理
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoListCell", for: indexPath) as! PhotoListCollectionViewCell
        let asset = (dataSource[indexPath.item] as! NSDictionary)["photoAsset"]  as! PHAsset
        let selected = (dataSource[indexPath.item] as! NSDictionary)["isSelected"] as! Bool
        
        cell.delegate = self
        
        cell.getPhoto(myAsset: asset, whichOne: 5000 + indexPath.item, isSelected: selected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bigImageVC = PhotoBigImgViewController()
        
        bigImageVC.PHFetchR = PHFetchR
        let whichOne = String(indexPath.item)
        bigImageVC.whichOne = whichOne
        bigImageVC.maxC = maxC
        bigImageVC.isOriginal = isOriginal
        bigImageVC.oldDic = oldDic
        bigImageVC.albumIdentifier = albumIdentifier
        
        bigImageVC.sendList = {dic,isBack in
            self.isBackTo = isBack
            if isBack == true {
                self.sendToLast!(dic,true)
            }else{
                if dic.count > 0 {
                    self.oldDic = dic
                    
                    let photoArr = dic["photoArray"] as! NSArray
                    
                    for j in 0..<self.dataSource.count {
                        var otherDic = self.dataSource[j] as! [String : Any]
                        otherDic.updateValue(false, forKey: "isSelected")
                        self.dataSource.replaceObject(at: j, with: otherDic)
                        for i in 0..<photoArr.count {
                            let curr = (photoArr[i] as! NSDictionary)["currentItem"] as! Int
                            let photoId = (photoArr[i] as! NSDictionary)["photoIdentifier"] as! String
                            
                            if photoId == otherDic["photoIdentifier"] as! String {
                                self.dataSource.replaceObject(at: curr, with: photoArr[i])
                            }
                        }
                    }
                    self._collectView?.reloadData()
                }
            }
        }
        self.navigationController?.pushViewController(bigImageVC, animated: true)
    }
    
    //MARK: - cell选择按钮代理
    func selectBtn(selectButton: UIButton) {
        let completeLbl = self.view.viewWithTag(1500) as! UILabel
        let button = self.view.viewWithTag(selectButton.tag) as! UIButton
        var photoArray = NSMutableArray()
        let assetCollection = PHFetchR?[selectButton.tag - 5000] as! PHAsset
        
        if oldDic.count > 0 {
            photoArray = oldDic["photoArray"] as! NSMutableArray
        }
        
        if button.isSelected == true {
            for i in 0..<photoArray.count {
                if (photoArray[i] as! NSDictionary)["photoIdentifier"] as? String == assetCollection.localIdentifier{
                    photoArray.removeObject(at: i)
                    selectButton.isSelected = false
                    break
                }
            }
            oldDic.updateValue(photoArray, forKey: "photoArray")
        }else{
            if photoArray.count < Int(maxC!)! {
                var dic = [String : Any]()
                dic.updateValue(assetCollection.localIdentifier , forKey: "photoIdentifier")
                dic.updateValue(albumIdentifier!, forKey: "albumIdentifier")
                dic.updateValue(PHFetchR?[selectButton.tag - 5000] as! PHAsset, forKey: "photoAsset")
                dic.updateValue(selectButton.tag - 5000, forKey: "currentItem")
                dic.updateValue(true, forKey: "isSelected")
                photoArray.add(dic)
                
                selectButton.isSelected = true
                
                oldDic.updateValue(photoArray, forKey: "photoArray")
            }else{
                print("不能选了")
            }
        }
        
        completeLbl.text = "\(photoArray.count)"
        self.title = "\(photoArray.count) / \(maxC!)"
        if photoArray.count == 0 {
            completeLbl.isHidden = true
        }else{
            completeLbl.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

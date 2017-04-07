//
//  PhotoListCollectionViewCell.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/3/31.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

protocol PhotoListDelegate {
    func selectBtn(selectButton:UIButton)
}

class PhotoListCollectionViewCell: UICollectionViewCell {
    var selectBtn : UIButton?
    var which : Int?
    var imageView : UIImageView?
    var delegate : PhotoListDelegate?
    let SCREEN_SIZE = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createCell()
    }
    
    func createCell() {
        imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: (SCREEN_SIZE.width - 25.0) / 4, height: (SCREEN_SIZE.width - 25.0) / 4))
        self.contentView.addSubview(imageView!)
        
        selectBtn = UIButton.init(frame: CGRect.init(x: (imageView?.frame.size.width)! - 25.0, y: 0, width: 25.0, height: 25.0))
        selectBtn?.setBackgroundImage(UIImage.init(named: "ico_check_nomal"), for: UIControlState.normal)
        selectBtn?.setBackgroundImage(UIImage.init(named: "ico_check_select"), for: UIControlState.selected)
        selectBtn?.addTarget(self, action: #selector(pressSelect), for: UIControlEvents.touchUpInside)
        imageView?.addSubview(selectBtn!)
    }
    
    func getPhoto(myAsset:PHAsset,whichOne:Int,isSelected:Bool) {
        which = whichOne
        selectBtn?.tag = which!
        
        if isSelected == true {
            self.selectBtn?.isSelected = true
        }else{
            self.selectBtn?.isSelected = false
        }
        
        let reques = PHImageRequestOptions.init()
        reques.isSynchronous = false
        reques.isNetworkAccessAllowed = false
        reques.resizeMode = PHImageRequestOptionsResizeMode.exact
        reques.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        
        let PhManager = PHImageManager.default()
        PhManager.requestImage(for: myAsset, targetSize: CGSize.init(width: SCREEN_SIZE.width / 4, height: SCREEN_SIZE.width / 4), contentMode: PHImageContentMode.aspectFill, options: reques) { (resultImage, info) in
            self.imageView?.image = resultImage
            self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.imageView?.clipsToBounds = true
            self.imageView?.isUserInteractionEnabled = true
        }
    }
    
    func pressSelect(sender:UIButton) {
        self.delegate?.selectBtn(selectButton: sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

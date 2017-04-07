//
//  PhotoBigImgCollectionViewCell.swift
//  WMHAlbumSwift
//
//  Created by Archer on 2017/4/1.
//  Copyright © 2017年 jiuji. All rights reserved.
//

import UIKit
import Photos

class PhotoBigImgCollectionViewCell: UICollectionViewCell {
    var bigImageView : UIImageView?
    let SCREEN_SIZE = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createBigImage()
    }
    
    func createBigImage() {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        bigImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_SIZE.width, height: SCREEN_SIZE.height))
        bigImageView?.contentMode = UIViewContentMode.scaleAspectFit
        bigImageView?.clipsToBounds = true
        bigImageView?.isUserInteractionEnabled = true
        self.contentView.addSubview(bigImageView!)
    }
    
    func getBigImage(asset : PHAsset) {
        let reques = PHImageRequestOptions.init()
        reques.isSynchronous = false
        reques.isNetworkAccessAllowed = false
        reques.resizeMode = PHImageRequestOptionsResizeMode.exact
        reques.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: SCREEN_SIZE.width / 4, height: SCREEN_SIZE.height / 4), contentMode: PHImageContentMode.aspectFit, options: reques) { (resultImage, Info) in
            self.bigImageView?.image = resultImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  EIImageViewerViewController.swift
//  evInfra
//
//  Created by Michael Lee on 2021/09/10.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import AlamofireImage
import SwiftyGif
import SDWebImage
import SnapKit
import UIKit

internal final class EIImageViewerViewController : BaseViewController, UIScrollViewDelegate{
    
    
    let TAG = "EIImageViewerViewController"
    
    @IBOutlet weak var mImageViewer: UIImageView!
    @IBOutlet weak var mScrollView: UIScrollView!
    @IBOutlet var imageSaveButton: UIButton!
    
    var mImageURL : URL?
    var isProfileImageMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "이미지 상세보기 화면"
        guard let mImageURL = mImageURL else {
            mImageViewer.image = UIImage(named: "ic_person_base36")
            return
        }
        prepareActionBar(with: "")
        
        imageSaveButton.layer.cornerRadius = 6
        imageSaveButton.isHidden = isProfileImageMode
        
        mScrollView.minimumZoomScale = 1.0
        mScrollView.maximumZoomScale = 10.0
        mScrollView.delegate = self
        
        if isProfileImageMode {
            mImageViewer.clipsToBounds = true
            mImageViewer.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(mImageViewer.snp.width)
                $0.width.equalTo(mImageViewer.snp.height).multipliedBy(1.0 / 1.0)
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            mImageViewer.layer.cornerRadius = mImageViewer.frame.width / 2
            
            let urlToString = mImageURL.absoluteString
            
            if !urlToString.hasSuffix(".png") &&
                !urlToString.hasSuffix(".jpeg") &&
                !urlToString.hasSuffix(".jpg") {
                mImageViewer.image = UIImage(named: "ic_person_base36")
                return
            }
        } else {
            mImageViewer.contentMode = .scaleAspectFit
        }
        
        let imageURLFromParse = mImageURL
        let imageData = NSData(contentsOf: imageURLFromParse as URL)
        
        var isGif : Bool = false
        if (imageData != nil && imageData?.imageFormat != nil){
            if (imageData?.imageFormat == ImageFormat.GIF){
                isGif = true
            }
        }
        
        if (isGif){
            self.mImageViewer.setGifFromURL(mImageURL)
        }else{
            self.mImageViewer.sd_setImage(with: mImageURL, completed: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mImageViewer
    }
    
    @IBAction func onSaveToPhoto(_ sender: Any) {
        if (mImageViewer != nil && mImageViewer.image != nil){
            UIImageWriteToSavedPhotosAlbum(mImageViewer.image!, self, #selector(saveimage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
    @objc func saveimage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {            
            printLog(out: "\(error.localizedDescription)")
            Snackbar().show(message: "저장에 실패하였습니다.")
        } else {
            Snackbar().show(message: "갤러리에 저장 되었습니다.")
        }
    }

    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
}

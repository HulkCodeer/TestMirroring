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

class EIImageViewerViewController : UIViewController, UIScrollViewDelegate{
    
    
    let TAG = "EIImageViewerViewController"
    
    @IBOutlet weak var mImageViewer: UIImageView!
    
    @IBOutlet weak var mScrollView: UIScrollView!
    
    var mImageURL : URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mScrollView.minimumZoomScale = 1.0
        mScrollView.maximumZoomScale = 10.0
        mScrollView.delegate = self
        
        mImageViewer.image = UIImage(named: "img_default")
        
        if (mImageURL == nil){
            return
        }
        
        let imageURLFromParse = mImageURL
        let imageData = NSData(contentsOf: imageURLFromParse! as URL)
        
        var isGif : Bool = false
        if (imageData != nil && imageData?.imageFormat != nil){
            if (imageData?.imageFormat == ImageFormat.GIF){
                isGif = true
            }
        }
        
        if (isGif){
            self.mImageViewer.setGifFromURL(mImageURL!)
        }else{
            self.mImageViewer.sd_setImage(with: mImageURL, completed: nil)
        }
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
            Log.d(tag: TAG, msg: error.localizedDescription)
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

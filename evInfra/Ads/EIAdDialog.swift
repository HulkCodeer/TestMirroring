//
//  EIAdDialog.swift
//  evInfra
//
//  Created by Shin Park on 24/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class EIAdDialog: UIView {
    
    @IBOutlet weak var imageAd: UIImageView!
    
    private var adType = EIAdManager.AD_TYPE_COMMON
    
    private var adInfo = Ad()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getAdInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        getAdInfo()
    }
    
    private func getAdInfo() {
        EIAdManager.sharedInstance.getPageAd() { (info) in
            self.adInfo = info
            if self.adInfo.ad_id != nil {
                self.commonInit()
            } else {
                self.removeFromSuperview()
            }
        }
    }
    
    private func commonInit() {
        guard let imgUrl = self.adInfo.ad_image else {
            self.removeFromSuperview()
            return
        }
        
        let view = Bundle.main.loadNibNamed("EIAdDialog", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        imageAd.sd_setImage(with: URL(string: "\(Const.EI_IMG_SERVER)\(imgUrl)"), placeholderImage: UIImage(named: "placeholder.png"))
        imageAd.isUserInteractionEnabled = true
        imageAd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAdImage(sender:))))
    }
    
    @objc func onClickAdImage(sender: UITapGestureRecognizer) {
        if let urlString = self.adInfo.ad_url {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:])
                
                // 광고 click event 전송
                EIAdManager.sharedInstance.increase(adId: self.adInfo.ad_id!, action: EIAdManager.ACTION_CLICK)
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    @IBAction func onClickNegative(_ sender: Any) {
        UserDefault().saveString(key: UserDefault.Key.AD_KEEP_DATE_FOR_A_WEEK, value: Date().toString())
        self.removeFromSuperview()
    }
    
    @IBAction func onClickPositive(_ sender: Any) {
        self.removeFromSuperview()
    }
}

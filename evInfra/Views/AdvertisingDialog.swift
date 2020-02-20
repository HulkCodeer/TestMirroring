//
//  AdvertisingDialog.swift
//  evInfra
//
//  Created by Shin Park on 24/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class AdvertisingDialog: UIView {
    
    public let AD_TYPE_COMMON = 0
    public let AD_TYPE_START = 1
    
    private var advertiseId = -1
    private var advertiseUrl: String?
    private var imageUrl: String?
    
    @IBOutlet weak var imageAd: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getAdInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        getAdInfo()
    }
    
    private func getAdInfo() {
        Server.getAdLargeInfo(type: AD_TYPE_START) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                switch(code) {
                    case "1000":
                        self.advertiseId = json["ad_id"].intValue
                        self.advertiseUrl = json["ad_url"].stringValue
                        self.imageUrl = json["ad_img"].stringValue
                        
                        // node.js 서버 이미지 위치: /images/ad/
                        // moana 서버 이미지 위치: /ad/
                        if let imgUrl = self.imageUrl {
                            if imgUrl.hasPrefix(Const.IMG_PREFIX) {
                                self.imageUrl = imgUrl.substring(from: Const.IMG_PREFIX.count)
                            }
                        }

                        self.commonInit()
                        break;

                    default:
                        self.removeFromSuperview()
                        break;
                }
            }
        }
    }
    
    private func commonInit() {
        guard let imgUrl = imageUrl else {
            self.removeFromSuperview()
            return
        }
        
        let view = Bundle.main.loadNibNamed("AdvertisingDialog", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        imageAd.sd_setImage(with: URL(string: "\(Const.EV_IMG_SERVER)\(imgUrl)"), placeholderImage: UIImage(named: "placeholder.png"))
        imageAd.isUserInteractionEnabled = true
        imageAd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAdImage(sender:))))
    }
    
    @objc func onClickAdImage(sender: UITapGestureRecognizer) {
        if let urlString = advertiseUrl {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:])
                
                // 광고 click event 전송
                Server.addCountForAd(adId: advertiseId)
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

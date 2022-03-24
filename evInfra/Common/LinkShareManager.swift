//
//  LinkShareManager.swift
//  evInfra
//
//  Created by PKH on 2022/03/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit

class LinkShareManager {
    static let shared = LinkShareManager()
    private let templateId = "10575"
    private var shareList = [String: String]()
    private var shareImage: UIImage?
    
    private init() {
        self.configure()
    }
    
    private func configure() {
        let size = CGSize(width: 480.0, height: 290.0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        shareImage = UIImage(named: "menu_top_bg.jpg")
        shareList["width"] = "480"
        shareList["height"] = "290"
        
        if let shareImage = shareImage {
            shareImage.draw(in: rect)
            
            KLKImageStorage.shared().upload(with: shareImage) { [weak self] imageInfo in
                print("\(imageInfo.url)")
                self?.shareList["imageUrl"] = "\(imageInfo.url)"
            } failure: { [weak self] error in
                print("\(Const.urlShareImage)")
                self?.shareList["imageUrl"] = Const.urlShareImage
            }
        }
    }
    
    func sendToKakaoWithBoard(with document: Document) {
        shareList["title"] = document.title ?? ""
        shareList["appstore"] = "https://itunes.apple.com/kr/app/ev-infra/id1206679515?mt=8";
        shareList["market"] = "https://play.google.com/store/apps/details?id=com.client.ev.activities"
        
        
        KLKTalkLinkCenter.shared().sendCustom(withTemplateId: templateId, templateArgs: shareList) { warningMessage, argumentMessage in
            print("warning message: \(String(describing: warningMessage?.description))")
            print("argument message: \(String(describing: argumentMessage?.description))")
        } failure: { error in
            print("error \(error)")
        }
    }
    
    func sendToKakao(with charger: ChargerStationInfo?) {
        guard let charger = charger else { return }
        
        shareList["title"] = "충전소 상세 정보"
        shareList["stationName"] = charger.mStationInfoDto?.mSnm ?? "충전소"
        shareList["scheme"] = "charger_id=\(charger.mChargerId ?? "")"
        shareList["ischeme"] = "charger_id=\(charger.mChargerId ?? "")"
        shareList["appstore"] = "https://itunes.apple.com/kr/app/ev-infra/id1206679515?mt=8";
        shareList["market"] = "https://play.google.com/store/apps/details?id=com.client.ev.activities"
        
        KLKTalkLinkCenter.shared().sendCustom(withTemplateId: templateId, templateArgs: shareList) { warningMessage, argumentMessage in
            print("warning message: \(String(describing: warningMessage?.description))")
            print("argument message: \(String(describing: argumentMessage?.description))")
        } failure: { error in
            print("error \(error)")
        }
    }
}

//
//  SummaryViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/10~! :)
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {
    
    // summary
    @IBOutlet weak var companyImg: UIImageView!         // 운영기관(이미지)
    @IBOutlet weak var callOutTitle: UILabel!           // 충전소 이름
    @IBOutlet var callOutFavorite: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!    // 충전소 주소
    @IBOutlet var copyBtn: UIButton!
    // 경로찾기 버튼
    @IBOutlet var startPointBtn: UIButton!              // 경로찾기(출발)
    @IBOutlet var endPointBtn: UIButton!                // 경로찾기(도착)
    @IBOutlet var addPointBtn: UIButton!
    
    @IBOutlet var naviBtn: UIButton!                    // 경로찾기(길안내)
    
    var charger: ChargerStationInfo?
    var mainViewDelegate: MainViewDelegate?
    var shareUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        getSummaryInfo()
    }
    
    @IBAction func onClickBookmark(_ sender: Any) {
        self.bookmark()
    }

    @IBAction func onClickStartPoint(_ sender: Any) {
        self.mainViewDelegate?.setStartPoint()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickEndPoint(_ sender: Any) {
        self.mainViewDelegate?.setEndPoint()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickAddPoint(_ sender: Any) {
        self.mainViewDelegate?.setStartPath()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickNavi(_ sender: UIButton) {
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                let snm = callOutTitle.text ?? ""
                let lng = stationDto.mLongitude ?? 0.0
                let lat = stationDto.mLatitude ?? 0.0
                UtilNavigation().showNavigation(vc: self, snm: snm, lat: lat, lng: lng)
            }
        }
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        self.shareForKakao()
    }
    
    
    func getSummaryInfo() {
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                // 이름
                callOutTitle.text = stationDto.mSnm
                // 주소
                self.setAddr(stationDto: stationDto)
            }
            // 운영기관 이미지
            setCompanyIcon(chargerData: chargerData)
            
            self.setCallOutFavoriteIcon(charger: chargerData)
        }
    }
    
    func setAddr(stationDto: StationInfoDto) {
        if let addr = stationDto.mAddress{
            if let addrDetail = stationDto.mAddressDetail{
                self.addressLabel.text = addr+"\n"+addrDetail
            }else{
                self.addressLabel.text = addr
            }
        }else{
            self.addressLabel.text = "신규 충전소로, 주소 업데이트 중입니다."
        }
    }
    
    func setCompanyIcon(chargerData: ChargerStationInfo) {
        if chargerData.getCompanyIcon() != nil{
            self.companyImg.image = chargerData.getCompanyIcon()
        }else {
            self.companyImg.image = UIImage(named: "icon_building_sm")
        }
    }
    
    func bookmark() {
        if MemberManager().isLogin() {
            ChargerManager.sharedInstance.setFavoriteCharger(charger: self.charger!) { (charger) in
                self.setCallOutFavoriteIcon(charger: charger)
                if charger.mFavorite {
                    Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
                } else {
                    Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
                }
            }
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
        if charger.mFavorite {
            self.callOutFavorite.setImage(UIImage(named: "bookmark_on"), for: .normal)
        } else {
            self.callOutFavorite.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    func shareForKakao() {
        let shareImage: UIImage!
        let size = CGSize(width: 480.0, height: 290.0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIImage(named: "menu_top_bg.jpg")?.draw(in: rect)
        shareImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

//        let sharedStorage = KLKImageStorage.init()

        KLKImageStorage.shared().upload(with: shareImage, success: { (imageInfo) in
            self.shareUrl = "\(imageInfo.url)"
            self.sendToKakaoTalk()
        }) { (error) in
            self.shareUrl = Const.urlShareImage
            self.sendToKakaoTalk()
            print("makeImage Error \(error)")
        }
    }
    
    func sendToKakaoTalk() {
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                let templateId = "10575"
                var shareList = [String: String]()
                shareList["width"] = "480"
                shareList["height"] = "290"
                shareList["imageUrl"] = shareUrl
                shareList["title"] = "충전소 상세 정보";
                if let stationName = stationDto.mSnm {
                    shareList["stationName"] = stationName;
                } else {
                    shareList["stationName"] = "";
                }
                if let stationId = chargerData.mChargerId {
                    shareList["scheme"] = "charger_id=\(stationId)"
                    shareList["ischeme"] = "charger_id=\(stationId)"
                }

                shareList["appstore"] = "https://itunes.apple.com/kr/app/ev-infra/id1206679515?mt=8";
                shareList["market"] = "https://play.google.com/store/apps/details?id=com.client.ev.activities";

        //        let shareCenter = KLKTalkLinkCenter.init()

                KLKTalkLinkCenter.shared().sendCustom(withTemplateId: templateId, templateArgs: shareList, success: { (warnimgMsg, argMsg) in
                    print("warning message: \(String(describing: warnimgMsg?.description))")
                    print("argument message: \(String(describing: argMsg?.description))")
                }) { (error) in
                    print("error \(error)")
                }
            }
        }
    }
}

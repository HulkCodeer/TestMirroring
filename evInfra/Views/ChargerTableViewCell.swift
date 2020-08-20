//
//  ChargerTableViewCell.swift
//  evInfra
//
//  Created by Shin Park on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChargerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var chargerStatus: UILabel!
    @IBOutlet weak var chargerType: UILabel!
    
    @IBOutlet weak var chargerDistance: UILabel!
    
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnAlarm: UIButton!
    
    private var charger: ChargerStationInfo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnFavorite.addTarget(self, action: #selector(onClickFavorite(_:)), for: .touchUpInside)
        btnAlarm.addTarget(self, action: #selector(onClickAlarm(_:)), for: .touchUpInside)
    }
    
    func setCharger(item: ChargerStationInfo) {
        charger = item
        
        stationName.text = charger.mStationInfoDto?.mSnm
        address.text = charger.mStationInfoDto?.mAddress
        chargerStatus.text = charger.mTotalStatusName
        
        var status = Const.CHARGER_STATE_UNKNOWN
        if (charger.mTotalStatus != nil){
            status = (charger.mTotalStatus)!
        }
        chargerStatus.textColor = charger.cidInfo.getCstColor(cst: status)
        chargerType.text = charger.getTotalChargerType()
        
        if let currentPosition = MainViewController.currentLocation{
            chargerDistance.text = StringUtils.convertDistanceString(distance: currentPosition.getDistanceWith(item.getTMapPoint()))
        }
        
        updateFavoriteImage()
        setAddrModeUI(isAddrMode: false)
    }
    
    func setAddrMode(item: EIPOIItem) {
        
        stationName.text = item.getPOIName()
        address.text = item.getPOIAddress()
        if let currentPosition = MainViewController.currentLocation{
            chargerDistance.text = StringUtils.convertDistanceString(distance: currentPosition.getDistanceWith(item.getPOIPoint()))
        }
        setAddrModeUI(isAddrMode: true)
    }
    
    func setAddrModeUI(isAddrMode:Bool) {
        if isAddrMode {
            chargerStatus.gone()
            chargerType.gone()
            btnFavorite.gone()
            btnAlarm.gone()
        } else {
            chargerStatus.visible()
            chargerType.visible()
            btnFavorite.visible()
            btnAlarm.visible()
        }
    }
    
    @objc func onClickFavorite(_ sender: UIButton) {
        Server.setFavorite(chargerId: charger.mChargerId!, mode: !charger.mFavorite) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    self.charger.mFavorite = json["mode"].boolValue
                    self.charger.mFavoriteNoti = true
                    self.updateFavoriteImage()
//                    if (charger.mFavorite) {
//                        showSnackbar(view, "즐겨찾기에 추가하였습니다.");
//                        charger.mFavoriteNoti = true;
//                    } else {
//                        showSnackbar(view, "즐겨찾기에서 제거하였습니다.");
//                    }
                } else {
//                    showSnackbar(view, "즐겨찾기 업데이트를 실패했습니다.\n다시 시도해 주세요.");
                }
            }
        }
    }
    
    @objc func onClickAlarm(_ sender: UIButton) {
        Server.setFavoriteAlarm(chargerId: charger.mChargerId!, state: !charger.mFavoriteNoti) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    self.charger.mFavoriteNoti = json["noti"].boolValue
                    self.updateFavoriteImage()
                } else {
//                    showSnackbar(view, "즐겨찾기 알림 업데이트를 실패했습니다.\n다시 시도해 주세요.");
                }
            }
        }
    }
    
    func updateFavoriteImage() {
        if charger.mFavorite {
            btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
            btnAlarm.isHidden = false
            if charger.mFavoriteNoti {
                btnAlarm.setImage(UIImage(named: "ic_notifications_active"), for: .normal)
            } else {
                btnAlarm.setImage(UIImage(named: "ic_notifications_off"), for: .normal)
            }
        } else {
            btnFavorite.setImage(UIImage(named: "ic_favorite_add"), for: .normal)
            btnAlarm.isHidden = true
        }
    }
}

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
    
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnAlarm: UIButton!
    
    private var charger: Charger!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnFavorite.addTarget(self, action: #selector(onClickFavorite(_:)), for: .touchUpInside)
        btnAlarm.addTarget(self, action: #selector(onClickAlarm(_:)), for: .touchUpInside)
    }
    
    func setCharger(item: Charger) {
        charger = item
        
        stationName.text = charger.stationName
        address.text = charger.address
        chargerStatus.text = charger.statusName
        chargerStatus.textColor = charger.cidInfo.getCstColor(cst: Int(charger.status)!)
        chargerType.text = charger.getTotalChargerType()
        
        updateFavoriteImage()
        setAddrModeUI(isAddrMode: false)
    }
    
    func setAddrMode(name:String, addr:String) {
        
        stationName.text = name
        address.text = addr
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
        Server.setFavorite(chargerId: charger.chargerId, mode: !charger.favorite) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let result = json["result"].stringValue
                if result.elementsEqual("1000") {
                    self.charger.favorite = json["mode"].boolValue
                    self.charger.favoriteAlarm = true
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
        Server.setFavoriteAlarm(chargerId: charger.chargerId, state: !charger.favoriteAlarm) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let result = json["result"].stringValue
                if result.elementsEqual("1000") {
                    self.charger.favoriteAlarm = json["noti"].boolValue
                    self.updateFavoriteImage()
                } else {
//                    showSnackbar(view, "즐겨찾기 업데이트를 실패했습니다.\n다시 시도해 주세요.");
                }
            }
        }
    }
    
    func updateFavoriteImage() {
        if charger.favorite {
            btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
            btnAlarm.isHidden = false
            if charger.favoriteAlarm {
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

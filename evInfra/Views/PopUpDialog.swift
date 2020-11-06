//
//  PopUpDialog.swift
//  evInfra
//
//  Created by SH on 2020/11/06.
//  Copyright © 2020 soft-berry. All rights reserved.
//


import Foundation
import SwiftyJSON

class PopUpDialog: UIView {
    @IBOutlet var lb_popup_title: UILabel!
    @IBOutlet var lb_popup_subtitle: UILabel!
    @IBOutlet var img_popup: UIImageView!
    @IBOutlet var lb_popup_message: UILabel!
    @IBOutlet var btn_popup_no: UIButton!
    @IBOutlet var btn_popup_yes: UIButton!
    let defaults = UserDefault()
    
    @IBAction func onClickNoBtn(_ sender: Any) {
        sendSubscribeLocalNoti(subscribe: false)
    }
    
    @IBAction func onClickYesBtn(_ sender: Any) {
        sendSubscribeLocalNoti(subscribe: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView(){
        let view = Bundle.main.loadNibNamed("PopUpDialog", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        lb_popup_title.text = "제주지역 감지됨"
        lb_popup_subtitle.text = "현재 위치가 제주도로 감지되었습니다.\n제주도 지역 공지를 받으시겠습니까?"
    }
    
    private func sendSubscribeLocalNoti(subscribe: Bool){
        Server.updateJejuNotificationState(state: subscribe) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.elementsEqual("1000") {
                    let isReceivePush = json["receive"].boolValue
                    self.defaults.saveBool(key: UserDefault.Key.JEJU_PUSH, value: false)
                    self.defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: isReceivePush)
                    self.removeFromSuperview()
                }
            }
        }
    }
}

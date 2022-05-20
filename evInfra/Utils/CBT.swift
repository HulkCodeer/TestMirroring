//
//  CBT.swift
//  evInfra
//
//  Created by Shin Park on 14/08/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class CBT {

    static func checkCBT(vc: UIViewController) {
        if MemberManager.shared.isLogin {
            Server.getCBTInfo() { (isSuccess, response) in
                if isSuccess {
                    let json = JSON(response)
                    let code = json["code"].stringValue
                    switch code {
                    case "1000":
                        Snackbar().show(message: "CBT for " + json["cbt_name"].stringValue)
                        
                    case "9000": // CBT 대상이 아님. 앱 종료
                        self.showFinishDialog(msg: json["msg"].stringValue)
                        
                    default:
                        self.showFinishDialog(msg: "서버 통신 오류.")
                    }
                }
            }
        } else {
            MemberManager().showLoginAlert(vc: vc)
        }
    }
    
    static func showFinishDialog(msg: String) {
        let message = msg + "\n앱을 종료합니다."
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            exit(0)
        })
        
        var actions = Array<UIAlertAction>()
        actions.append(ok)
        UIAlertController.showAlert(title: "알림", message: message, actions: actions)
    }
}

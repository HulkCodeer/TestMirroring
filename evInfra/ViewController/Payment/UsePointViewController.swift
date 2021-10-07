//
//  UsePointController.swift
//  evInfra
//
//  Created by Shin Park on 07/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import M13Checkbox
import SwiftyJSON

class UsePointViewController: UIViewController {
    
    @IBOutlet weak var labelMyPoint: UILabel!
    @IBOutlet weak var textFieldUsePoint: UITextField!
    
    @IBOutlet weak var viewUseAllPoint: UIView!
    @IBOutlet weak var cbUseAllPoint: M13Checkbox!
    
    var myPoint = 0
    var delegate: SendPointDelegate?
    var data = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
        prepareTextField()
        getMyPoint()
    }
    
    func getMyPoint() {
        Server.getPoint{ (isSuccess, value) in

            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue == "1000" {
                    self.myPoint = json["point"].intValue
                    if self.myPoint > -1 {
                        self.labelMyPoint.text = "\(self.myPoint)".currency()
                    }
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
            }
        }
    }
    
    func prepareView() {
        cbUseAllPoint.boxType = .square
        cbUseAllPoint.tintColor = UIColor(named: "content-primary")
        
        viewUseAllPoint.addTapGesture(target: self, action: #selector(onClickUseAllPoint(_:)))
        
        textFieldUsePoint.becomeFirstResponder()
    }
    
    @IBAction func onClickUseAllCb(_ sender: Any) {
        setAllPoint()
    }
    
    @objc func onClickUseAllPoint(_ sender: UITapGestureRecognizer) {
        cbUseAllPoint.toggleCheckState(true)
        setAllPoint()
    }
    
    func setAllPoint() {
        if cbUseAllPoint.checkState == .checked {
            textFieldUsePoint.text = String(self.myPoint).currency()
            
        } else {
            textFieldUsePoint.text = "0"
        }
    }
    
    
    
    @IBAction func onClickUsePoint(_ sender: Any) {
        if let strPoint = textFieldUsePoint.text, !strPoint.isEmpty, let point = Int(strPoint.replacingOccurrences(of: ",", with: "")) {
            Server.usePoint (point: point) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    if json["code"].stringValue == "1000" {
                        let point = json["point"].stringValue
                        Snackbar().show(message: point.currency() + " 포인트를 사용합니다.", title: "포인트 사용 완료") { () in
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        Snackbar().show(message: json["msg"].stringValue)
                    }
                } else {
                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 다시 시도해 주세요.")
                }
            }
        } else {
            Snackbar().show(message: "사용할 포인트를 입력해 주세요.")
            textFieldUsePoint.becomeFirstResponder()
        }
    }
}

extension UsePointViewController: UITextFieldDelegate {
    
    func prepareTextField() {
        self.textFieldUsePoint.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        var newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        newString = newString.replacingOccurrences(of: ",", with: "") as NSString
        if newString.length > 0 {
            if let point = Int(newString as String) {
                if point >= myPoint { // 내가 보유한 포인트보다 큰 수를 입력한 경우 내 포인트를 입력
                    textFieldUsePoint.text = String(myPoint).currency()
                    cbUseAllPoint.checkState = .checked
                    return false
                } else {
                    textFieldUsePoint.text = String(newString).currency()
                    cbUseAllPoint.checkState = .unchecked // 포인트보다 작은 수 입력한 경우 전체사용 해제
                    return false
                }
            } else {
                return false // 숫자 이외의 문자 입력받지 않음
            }
        }
        return newString.length <= 7 //max length is 7
    }
}

protocol SendPointDelegate {
    func dataReceived(berry: String)
}

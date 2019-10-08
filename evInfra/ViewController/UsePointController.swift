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

class UsePointController: UIViewController {
    
    @IBOutlet weak var labelMyPoint: UILabel!
    @IBOutlet weak var textFieldUsePoint: UITextField!
    
    @IBOutlet weak var viewUseAllPoint: UIView!
    @IBOutlet weak var cbUseAllPoint: M13Checkbox!
    
    var myPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldUsePoint.delegate = self
        
        prepareActionBar()
        prepareMyPoint()
        prepareView()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "포인트 사용"
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func prepareMyPoint() {
        Server.getPoint{ (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue == "1000" {
                    self.myPoint = json["point"].intValue
                    self.labelMyPoint.text = "\(self.myPoint)".currency()
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 페이지 종료 후 재시도 바랍니다.")
            }
        }
    }
    
    func prepareView() {
        cbUseAllPoint.boxType = .square
        cbUseAllPoint.tintColor = UIColor(rgb: 0x15435C)
        viewUseAllPoint.addTapGesture(target: self, action: #selector(onClickUseAllPoint(_:)))
    }
    
    @IBAction func onClickUseAllPoint(_ sender: UITapGestureRecognizer) {
        cbUseAllPoint.toggleCheckState(true)
    }
}

extension UsePointController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length > 0 {
            if let point = Int(newString as String) {
                if point > myPoint { // 내가 보유한 포인트보다 큰 수를 입력한 경우 내 포인트를 입력
                    textFieldUsePoint.text = String(myPoint)
                    return false
                }
            } else {
                return false // 숫자 이외의 문자 입력받지 않음
            }
        }
        
        return newString.length <= 7 //max length is 7
    }
}

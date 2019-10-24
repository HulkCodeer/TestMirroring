//
//  MembershipInfoView.swift
//  evInfra
//
//  Created by bulacode on 17/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON

class MembershipInfoView: UIView {
    
    private let xibName = "MembershipInfoView"

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ivCardInfo: UIImageView!
    @IBOutlet weak var ivPassWord: UIImageView!
    @IBOutlet weak var lbCardNo: UILabel!
    @IBOutlet weak var lbIssueDate: UILabel!
    @IBOutlet weak var lbCardStatus: UILabel!
    @IBOutlet weak var tfCurPw: UITextField!
    @IBOutlet weak var tfNewPw: UITextField!
    @IBOutlet weak var tfNewPwRe: UITextField!
    @IBOutlet weak var btnChangePw: UIButton!
    @IBOutlet weak var stackViewBottom: NSLayoutConstraint!
    
    var delegate: MembershipInfoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    @IBAction func onClickChangePw(_ sender: UIButton) {
        self.changePassword()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.ivCardInfo.image = UIImage(named: "ic_menu_check")?.withRenderingMode(.alwaysTemplate)
        self.ivCardInfo.tintColor = UIColor(rgb: 0x585858)
        self.ivPassWord.image = UIImage(named: "ic_menu_check")?.withRenderingMode(.alwaysTemplate)
        self.ivPassWord.tintColor = UIColor(rgb: 0x585858)
    }
    
    func setCardInfo(cardInfo: JSON) {
        lbCardNo.text = cardInfo["card_no"].stringValue
        lbCardStatus.text = getCardStatusToString(status: cardInfo["status"].stringValue)
        lbIssueDate.text = cardInfo["date"].stringValue
    }
    
    func getCardStatusToString(status: String) -> String {
        switch (status) {
            case "0":
                return "발급 신청";

            case "1":
                return "발급 완료";

            case "2":
                return "카드 분실";

            default:
                return "상태 오류";
        }
    }
    
    func showKeyBoard(keyboardHeight: CGFloat) {
        print("showKeyBoard info")
         self.stackViewBottom.constant = keyboardHeight
         self.scrollView.isScrollEnabled = true
         self.scrollView.setNeedsLayout()
         self.scrollView.layoutIfNeeded()
    }
     func hideKeyBoard() {
          self.stackViewBottom.constant = 0
          self.scrollView.isScrollEnabled = true
          self.scrollView.setNeedsLayout()
          self.scrollView.layoutIfNeeded()
     }
    func changePassword(){
        var chgPwParams = [String: Any]()
        do {
            chgPwParams["cur_pw"] = try tfCurPw.validatedText(validationType: .password)
            chgPwParams["new_pw"] = try tfNewPw.validatedText(validationType: .password)
            _ = try tfNewPwRe.validatedText(validationType: .repassword(password: tfNewPw.text ?? "0000"))
            chgPwParams["card_no"] = lbCardNo.text
            chgPwParams["mb_id"] = MemberManager.getMbId()
            delegate?.changePassword(param: chgPwParams)
        } catch (let error) {
            delegate?.showFailedPasswordError(msg: (error as! ValidationError).message)
        }
    }
}

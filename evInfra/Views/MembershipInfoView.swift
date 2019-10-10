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

    @IBOutlet weak var ivCardInfo: UIImageView!
    @IBOutlet weak var ivPassWord: UIImageView!
    @IBOutlet weak var lbCardNo: UILabel!
    @IBOutlet weak var lbIssueDate: UILabel!
    @IBOutlet weak var lbCardStatus: UILabel!
    @IBOutlet weak var tfCurPw: UITextField!
    @IBOutlet weak var tfNewPw: UITextField!
    @IBOutlet weak var tfNewPwRe: UITextField!
    @IBOutlet weak var btnChangePw: UIButton!
    
    var delegate: MembershipInfoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
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
//        mbsCardNoLabel.text = cardInfo["card_no"].stringValue
//        mbsCardIssueDateLabel.text = cardInfo["status"].stringValue
//        mbsCardStatusLabel.text = cardInfo["date"].stringValue
    }
}

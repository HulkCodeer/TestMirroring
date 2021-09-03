//
//  CidInfoTableViewCell.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/09.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class CidInfoTableViewCell: UITableViewCell {
    
    // power divider
    @IBOutlet weak var dividerView: UIView!
    // 충전기 상태
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusBtn: UIButton!
    
    @IBOutlet weak var lockBtn: UIButton!
    
    // 충전기 속도
    @IBOutlet weak var powerLable: UILabel!
    // 타입
    @IBOutlet weak var dcCombo: UIImageView!
    @IBOutlet weak var dcDemo: UIImageView!
    @IBOutlet weak var acSam: UIImageView!
    @IBOutlet weak var slow: UIImageView!
    // 타입 lb
    @IBOutlet weak var dcComboLb: UILabel!
    @IBOutlet weak var dcDemoLb: UILabel!
    @IBOutlet weak var acSamLb: UILabel!
    @IBOutlet weak var slowLb: UILabel!
    
    // 날짜 lb
    @IBOutlet weak var dateKind: UIButton!
    // 경과 날짜
    @IBOutlet weak var lastDate: UILabel!
    
    // TODO :: Ui DC콤보, 데모, 3상, 완속 순!! (3상과 완속 순서가 바뀜)
    
    let imgDcCombo = "ic_charger_dc_combo_md"  // type_dc_combo
    let imgDcDemo = "ic_charger_dc_demo_md"  // type_dc_demo
    let imgAcThree = "ic_charger_acthree_md"  // type_ac_three
    let imgAcSlow = "ic_charger_slow_md"  // type_ac_slow
    let imgSuper = "ic_charger_super_md"  // type_super
    let imgDestination = "ic_charger_slow_md"  // type_destination
    
    let positive = "content-positive"
    let tertiary = "content-tertiary"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateKind.layer.cornerRadius = 12
        dateKind.layer.borderWidth = 1
        dateKind.layer.borderColor = UIColor.init(named: "border-opaque")?.cgColor
    }

    func getDividerHeight() -> CGFloat {
        let dividerHeight:CGFloat = self.dividerView.bounds.size.height
        let bottomMargin:CGFloat = self.dividerView.layoutMargins.bottom
        let height:CGFloat = dividerHeight+bottomMargin
        return height
    }
    
    @IBAction func onClickWarningBtn(_ sender: Any) {
        Snackbar().show(message: "통신미연결, 충전기 오류로 상태값을 알 수 없는 상태입니다.")
    }
    
    @IBAction func onClickLockBtn(_ sender: Any) {
        Snackbar().show(message: "비개방 충전기로 충전소의 거주자, 이용자 외에는 이용 및 충전이 제한될 수 있습니다. ")
    }
    
    public func setChargerTypeImage(type:Int) {
        // reset img, lb
        self.dcCombo.image = UIImage(named: imgDcCombo)
        self.dcDemo.image = UIImage(named: imgDcDemo)
        self.slow.image = UIImage(named: imgAcSlow)
        self.acSam.image = UIImage(named: imgAcThree)
        
        self.dcCombo.tintColor = UIColor.init(named: tertiary)
        self.dcDemo.tintColor = UIColor.init(named: tertiary)
        self.slow.tintColor = UIColor.init(named: tertiary)
        self.acSam.tintColor = UIColor.init(named: tertiary)
        
        self.dcComboLb.textColor = UIColor.init(named: tertiary)
        self.dcDemoLb.textColor = UIColor.init(named: tertiary)
        self.slowLb.textColor = UIColor.init(named: tertiary)
        self.acSamLb.textColor = UIColor.init(named: tertiary)
        
        self.dcDemoLb.text = "DC 차데모"
        self.acSamLb.text = "AC 3상"
        
        switch (type) {
        case Const.CHARGER_TYPE_DCDEMO:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.init(named: tertiary)
            self.dcDemoLb.textColor = UIColor.init(named: positive)
            self.slowLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            break;
            
        case Const.CHARGER_TYPE_DCCOMBO:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.init(named: positive)
            self.dcDemoLb.textColor = UIColor.init(named: tertiary)
            self.slowLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_AC:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: positive)
            
            self.dcComboLb.textColor = UIColor.init(named: tertiary)
            self.dcDemoLb.textColor = UIColor.init(named: positive)
            self.slowLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: positive)
            
            break;
            
        case Const.CHARGER_TYPE_AC:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: positive)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.init(named: tertiary)
            self.dcDemoLb.textColor = UIColor.init(named: tertiary)
            self.slowLb.textColor = UIColor.init(named: positive)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.init(named: positive)
            self.dcDemoLb.textColor = UIColor.init(named: positive)
            self.slowLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: positive)
            
            self.dcComboLb.textColor = UIColor.init(named: positive)
            self.dcDemoLb.textColor = UIColor.init(named: positive)
            self.slowLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: positive)
            
            break;
            
        case Const.CHARGER_TYPE_SLOW:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: positive)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.init(named: tertiary)
            self.dcDemoLb.textColor = UIColor.init(named: tertiary)
            self.slowLb.textColor = UIColor.init(named: positive)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            
            break;
            
        case Const.CHARGER_TYPE_HYDROGEN:
            self.dcCombo.image = nil
            self.dcDemo.image = nil
            self.slow.image = nil
            self.acSam.image = nil
            
            self.dcComboLb.textColor = UIColor.clear
            self.dcDemoLb.textColor = UIColor.clear
            self.slowLb.textColor = UIColor.clear
            self.acSamLb.textColor = UIColor.clear
            break;

        case Const.CHARGER_TYPE_SUPER_CHARGER:
            self.dcCombo.image = nil
            self.slow.image = nil
            self.dcDemo.image = UIImage(named: imgSuper)
            self.acSam.image = UIImage(named: imgAcThree)
            
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
            self.dcComboLb.textColor = UIColor.clear
            self.slowLb.textColor = UIColor.clear
            
            self.dcDemoLb.textColor = UIColor.init(named: positive)
            self.acSamLb.textColor = UIColor.init(named: tertiary)
            
            self.dcDemoLb.text = "수퍼차저"
            self.acSamLb.text = "데스티네이션"
            break;
            
        case Const.CHARGER_TYPE_DESTINATION :
            self.dcCombo.image = nil
            self.slow.image = nil
            self.dcDemo.image = UIImage(named: imgSuper)
            self.acSam.image = UIImage(named: imgAcThree)
            
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: positive)
            
            self.dcComboLb.textColor = UIColor.clear
            self.slowLb.textColor = UIColor.clear
            
            self.dcDemoLb.textColor = UIColor.init(named: tertiary)
            self.acSamLb.textColor = UIColor.init(named: positive)
            
            self.dcDemoLb.text = "수퍼차저"
            self.acSamLb.text = "데스티네이션"
            
            break;
            
        default:
            break;
        }
    }
    
    
}

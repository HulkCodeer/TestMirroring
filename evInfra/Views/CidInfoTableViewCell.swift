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
    @IBOutlet var dividerView: UIView!
    // 충전기 상태
    @IBOutlet weak var statusLabel: UILabel!
    // 충전기 속도
    @IBOutlet weak var powerLable: UILabel!
    // 타입
    @IBOutlet weak var dcCombo: UIImageView!
    @IBOutlet weak var dcDemo: UIImageView!
    @IBOutlet weak var acSam: UIImageView!
    @IBOutlet weak var slow: UIImageView!
    // 날짜 lb
    @IBOutlet weak var dateKind: UILabel!
    // 경과 날짜
    @IBOutlet weak var lastDate: UILabel!
    
    let imgDcCombo = "ic_charger_dc_combo_md"  // type_dc_combo
    let imgDcDemo = "ic_charger_dc_demo_md"  // type_dc_demo
    let imgAcThree = "ic_charger_acthree_md"  // type_ac_three
    let imgAcSlow = "ic_charger_slow_md"  // type_ac_slow
    let imgSuper = "ic_charger_super_md"  // type_super
    let imgDestination = "ic_charger_slow_md"  // type_destination
    
    let positive = "content-positive"
    let tertiary = "content-tertiary"
    
    // dim image 필요 없음 -> 각 이미지의 tint 색상 변경으로 해결가능
//    let imgDcComboDim = "type_dc_combo_dim"  // type_dc_combo_dim
//    let imgDcDemoDim = "type_dc_demo_dim"  // type_dc_demo_dim
//    let imgAcThreeDim = "type_ac_three_dim"  // type_ac_three_dim
//    let imgAcSlowDim = "type_ac_slow_dim"  // type_ac_slow_dim
//    let imgSuperDim = "type_super_dim"  // type_super_dim
//    let imgDestinationDim = "type_destination_dim"  // type_destination_dim

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    func getDividerHeight() -> CGFloat {
        let dividerHeight:CGFloat = self.dividerView.bounds.size.height
        let bottomMargin:CGFloat = self.dividerView.layoutMargins.bottom
        let height:CGFloat = dividerHeight+bottomMargin
        return height
    }
    
    public func setChargerTypeImage(type:Int) {
        self.dcCombo.image = UIImage(named: imgDcCombo)
        self.dcDemo.image = UIImage(named: imgDcDemo)
        self.slow.image = UIImage(named: imgAcSlow)
        self.acSam.image = UIImage(named: imgAcThree)
        
        self.dcCombo.tintColor = UIColor.init(named: tertiary)
        self.dcDemo.tintColor = UIColor.init(named: tertiary)
        self.slow.tintColor = UIColor.init(named: tertiary)
        self.acSam.tintColor = UIColor.init(named: tertiary)
        switch (type) {
        case Const.CHARGER_TYPE_DCDEMO:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
//            self.dcCombo.image = UIImage(named: imgDcComboDim)
//            self.dcDemo.image = UIImage(named: imgDcDemo)
//            self.acSam.image = UIImage(named: imgAcThreeDim)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCCOMBO:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
//            self.dcCombo.image = UIImage(named: imgDcCombo)
//            self.dcDemo.image = UIImage(named: imgDcDemoDim)
//            self.acSam.image = UIImage(named: imgAcThreeDim)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_AC:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: positive)
            
//            self.dcCombo.image = UIImage(named: imgDcComboDim)
//            self.dcDemo.image = UIImage(named: imgDcDemo)
//            self.acSam.image = UIImage(named: imgAcThree)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_AC:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: positive)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
//            self.dcCombo.image = UIImage(named: imgDcComboDim)
//            self.dcDemo.image = UIImage(named: imgDcDemoDim)
//            self.acSam.image = UIImage(named: imgAcThree)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
//            self.dcCombo.image = UIImage(named: imgDcCombo)
//            self.dcDemo.image = UIImage(named: imgDcDemo)
//            self.acSam.image = UIImage(named: imgAcThreeDim)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC:
            self.dcCombo.tintColor = UIColor.init(named: positive)
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
            self.acSam.tintColor = UIColor.init(named: positive)
            
//            self.dcCombo.image = UIImage(named: imgDcCombo)
//            self.dcDemo.image = UIImage(named: imgDcDemo)
//            self.acSam.image = UIImage(named: imgAcThree)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_SLOW:
            self.dcCombo.tintColor = UIColor.init(named: tertiary)
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: positive)
            self.acSam.tintColor = UIColor.init(named: tertiary)
            
//            self.dcCombo.image = UIImage(named: imgDcComboDim)
//            self.dcDemo.image = UIImage(named: imgDcDemoDim)
//            self.acSam.image = UIImage(named: imgAcThreeDim)
//            self.slow.image = UIImage(named: imgAcSlow)
            break;
            
        case Const.CHARGER_TYPE_HYDROGEN:
            self.dcCombo.image = nil
            self.dcDemo.image = nil
            self.slow.image = nil
            self.acSam.image = nil
//            self.dcCombo.image = UIImage(named: imgDcComboDim)
//            self.dcDemo.image = UIImage(named: imgDcDemoDim)
//            self.acSam.image = UIImage(named: imgAcThreeDim)
//            self.slow.image = UIImage(named: imgAcSlowDim)
            break;

        case Const.CHARGER_TYPE_SUPER_CHARGER:
            self.dcCombo.image = nil
            self.acSam.image = nil
            self.dcDemo.image = UIImage(named: imgSuper)
            self.slow.image = UIImage(named: imgAcThree)
            
            self.dcDemo.tintColor = UIColor.init(named: positive)
            self.slow.tintColor = UIColor.init(named: tertiary)
//            self.dcDemo.image = UIImage(named: imgSuper)
//            self.slow.image = UIImage(named: imgDestinationDim)
            break;
            
        case Const.CHARGER_TYPE_DESTINATION :
            self.dcCombo.image = nil
            self.acSam.image = nil
            self.dcDemo.image = UIImage(named: imgSuper)
            self.slow.image = UIImage(named: imgAcThree)
            
            self.dcDemo.tintColor = UIColor.init(named: tertiary)
            self.slow.tintColor = UIColor.init(named: positive)
//            self.dcDemo.image = UIImage(named: imgSuperDim)
//            self.slow.image = UIImage(named: imgDestination)
            break;
            
        default:
            break;
        }
    }
    
    
}

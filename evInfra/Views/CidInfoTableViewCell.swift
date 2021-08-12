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
    
    let imgDcCombo = "type_dc_combo"
    let imgDcDemo = "type_dc_demo"
    let imgAcThree = "type_ac_three"
    let imgAcSlow = "type_ac_slow"
    let imgSuper = "type_super"
    let imgDestination = "type_destination"
    
    let imgDcComboDim = "type_dc_combo_dim"
    let imgDcDemoDim = "type_dc_demo_dim"
    let imgAcThreeDim = "type_ac_three_dim"
    let imgAcSlowDim = "type_ac_slow_dim"
    let imgSuperDim = "type_super_dim"
    let imgDestinationDim = "type_destination_dim"

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
        switch (type) {
        case Const.CHARGER_TYPE_DCDEMO:
            self.dcCombo.image = UIImage(named: imgDcComboDim)
            self.dcDemo.image = UIImage(named: imgDcDemo)
            self.acSam.image = UIImage(named: imgAcThreeDim)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCCOMBO:
            self.dcCombo.image = UIImage(named: imgDcCombo)
            self.dcDemo.image = UIImage(named: imgDcDemoDim)
            self.acSam.image = UIImage(named: imgAcThreeDim)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_AC:
            self.dcCombo.image = UIImage(named: imgDcComboDim)
            self.dcDemo.image = UIImage(named: imgDcDemo)
            self.acSam.image = UIImage(named: imgAcThree)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_AC:
            self.dcCombo.image = UIImage(named: imgDcComboDim)
            self.dcDemo.image = UIImage(named: imgDcDemoDim)
            self.acSam.image = UIImage(named: imgAcThree)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO:
            self.dcCombo.image = UIImage(named: imgDcCombo)
            self.dcDemo.image = UIImage(named: imgDcDemo)
            self.acSam.image = UIImage(named: imgAcThreeDim)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC:
            self.dcCombo.image = UIImage(named: imgDcCombo)
            self.dcDemo.image = UIImage(named: imgDcDemo)
            self.acSam.image = UIImage(named: imgAcThree)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;
            
        case Const.CHARGER_TYPE_SLOW:
            self.dcCombo.image = UIImage(named: imgDcComboDim)
            self.dcDemo.image = UIImage(named: imgDcDemoDim)
            self.acSam.image = UIImage(named: imgAcThreeDim)
            self.slow.image = UIImage(named: imgAcSlow)
            break;
            
        case Const.CHARGER_TYPE_HYDROGEN:
            self.dcCombo.image = UIImage(named: imgDcComboDim)
            self.dcDemo.image = UIImage(named: imgDcDemoDim)
            self.acSam.image = UIImage(named: imgAcThreeDim)
            self.slow.image = UIImage(named: imgAcSlowDim)
            break;

        case Const.CHARGER_TYPE_SUPER_CHARGER:
            self.dcDemo.image = UIImage(named: imgSuper)
            self.slow.image = UIImage(named: imgDestinationDim)
            break;
            
        case Const.CHARGER_TYPE_DESTINATION :
            self.dcDemo.image = UIImage(named: imgSuperDim)
            self.slow.image = UIImage(named: imgDestination)
            break;
            
        default:
            break;
        }
    }
    
    
}

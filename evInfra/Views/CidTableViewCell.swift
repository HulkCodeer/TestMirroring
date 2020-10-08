//
//  CidTableViewCell.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 15..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class CidTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var powerLable: UILabel!
    @IBOutlet weak var dcCombo: UIImageView!
    @IBOutlet weak var dcDemo: UIImageView!
    @IBOutlet weak var acSam: UIImageView!
    @IBOutlet weak var slow: UIImageView!
    
    @IBOutlet weak var dateKind: UILabel!
	@IBOutlet var waitTimeView: UIView!
	

	@IBOutlet var lastDate: UIButton!
	@IBOutlet var mainView: UIView!
	
	
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

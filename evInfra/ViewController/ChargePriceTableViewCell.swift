//
//  ChargePriceTableViewCell.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/07/13.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit

class ChargePriceTableViewCell: UITableViewCell {
    @IBOutlet weak var lbChargeCompany: UILabel!
    @IBOutlet weak var lbChargePrice: UILabel!
    @IBOutlet weak var vChargePrice: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

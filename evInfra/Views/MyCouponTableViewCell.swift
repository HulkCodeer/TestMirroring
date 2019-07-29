//
//  MyCouponTableViewCell.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit

class MyCouponTableViewCell: UITableViewCell {

    @IBOutlet weak var CouponImgView: UIImageView!
    @IBOutlet weak var CouponDescriptionView: UILabel!
    @IBOutlet weak var CouponUsedDateView: UILabel!
    @IBOutlet weak var CouponStatusImgView: UIImageView!
    @IBOutlet weak var CouponStatusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

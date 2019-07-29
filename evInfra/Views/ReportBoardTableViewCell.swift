//
//  ReportBoardTableViewCell.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class ReportBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var rType: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var rDate: UILabel!
    @IBOutlet weak var adminCommnet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

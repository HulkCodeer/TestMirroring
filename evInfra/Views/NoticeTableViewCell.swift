//
//  NoticeTableViewCell.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

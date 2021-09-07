//
//  FAQTableViewCell.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/07.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class FAQTableViewCell: UITableViewCell {
    @IBOutlet var faqNumLb: UILabel!
    @IBOutlet var faqTitleLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

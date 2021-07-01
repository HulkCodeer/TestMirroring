//
//  EventTableViewCell.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventCommentLabel: UILabel!
    @IBOutlet weak var eventEndDateLabel: UILabel!
    @IBOutlet weak var eventStatusImageView: UIImageView!
    @IBOutlet weak var eventStatusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 8
        
        // set the values for top, left, bottom, right margins
        let margins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)
    }
}

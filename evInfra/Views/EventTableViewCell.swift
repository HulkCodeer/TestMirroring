//
//  EventTableViewCell.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import SDWebImage

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventCommentLabel: UILabel!
    @IBOutlet weak var eventEndDateLabel: UILabel!
    @IBOutlet weak var eventStatusImageView: UIImageView!
    @IBOutlet weak var eventStatusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // set the values for top, left, bottom, right margins
        let margins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
    internal func configure(_ event: AdsInfo) {
        eventCommentLabel.text = event.evtDesc
        eventEndDateLabel.text = "행사종료 : \(event.dpEnd)"
        
        // Promotion state == 0 중지 / 1 == 게시
        switch event.dpState {
        case .inProgress:
            let imgUrl: String = "\(Const.AWS_IMAGE_SERVER)/\(event.thumbNail)"        
            if !imgUrl.isEmpty {
                eventImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "AppIcon"))
            } else {
                eventImageView.image = UIImage(named: "AppIcon")
                eventImageView.contentMode = .scaleAspectFit
            }
            isUserInteractionEnabled = true
            eventStatusView.isHidden = true
            eventStatusImageView.isHidden = true
        case .end:
            isUserInteractionEnabled = false
            eventStatusView.isHidden = false
            eventStatusImageView.isHidden = false
            eventStatusImageView.image = UIImage(named: "ic_event_end")
        }
    }
}

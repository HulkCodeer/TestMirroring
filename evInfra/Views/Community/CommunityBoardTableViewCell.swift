//
//  CommunityBoardTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/06.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class CommunityBoardTableViewCell: UITableViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLable: UILabel!
    @IBOutlet var adminIconImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var replyCountLabel: UILabel!
    @IBOutlet var replyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.sd_cancelCurrentImageLoad()
        profileImage.image = nil
    }
    
    private func initUI() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        replyView.layer.cornerRadius = 8
        adminIconImage.isHidden = true
        contentsLabel.lineBreakMode = .byTruncatingTail
        contentsLabel.numberOfLines = 2
    }
    
    func configure(item: BoardListItem?) {
        guard let item = item else { return }
        
        profileImage.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        userNameLable.text = item.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: item.regdate!))"
        
        if let files = item.files {
            if files.count > 0 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "icon_image_xs")
                attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                
                let attributedString = NSMutableAttributedString(string: item.content!)
                attributedString.append(NSAttributedString(attachment: attachment))
                
                contentsLabel.attributedText = attributedString
                contentsLabel.sizeToFit()
            } else {
                contentsLabel.text = item.content!
            }
        }
        
        if let comment_count = item.comment_count,
            let count = Int(comment_count) {
            
            if count > 99 {
                replyCountLabel.text = "\(count)+"
            } else {
                replyCountLabel.text = "\(count)"
            }
        }
    }
}

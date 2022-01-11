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
    
    private func initUI() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        replyView.layer.cornerRadius = 8
    }
    
    func configure(item: BoardListItem?) {
        guard let item = item else { return }
        
        
        profileImage.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile!)"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        userNameLable.text = item.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: item.regdate!))"
        contentsLabel.text = item.content
        
        if let comment_count = item.comment_count,
            let count = Int(comment_count) {
            
            if count > 99 {
                replyCountLabel.text = "\(count)+"
            } else {
                replyCountLabel.text = "\(count)"
            }
        }
    }
//
//    func configure(item: BoardItem?) {
//        guard let item = item else { return }
//
//        profileImage.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile!)"), placeholderImage: UIImage(named: "ic_person_base36"))
//        userNameLable.text = item.nick
//        dateLabel.text = item.date
//        contentsLabel.text = item.content
//
//        if let reply = item.reply {
//            let replyCount = reply.count
//
//            if reply.count > 99 {
//                replyCountLabel.text = "\(replyCount)+"
//            } else {
//                replyCountLabel.text = "\(replyCount)"
//            }
//        }
//
//        replyCountLabel.text = "0"
//    }
}

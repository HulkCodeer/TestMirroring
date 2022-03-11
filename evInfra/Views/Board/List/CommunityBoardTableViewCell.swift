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
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var adminIconImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var replyCountLabel: UILabel!
    @IBOutlet var replyView: UIView!
    
    var adminList: [Admin]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 2
    }
    
    private func isAdmin(mbId: String) -> Bool {
        guard let adminList = adminList else { return false }
        return adminList.contains { $0.mb_id.equals(mbId) }
    }
    
    func configure(item: BoardListItem?) {
        guard let item = item else { return }
        
        if isReportedItem(item: item) {
            profileImage.isHidden = true
            userNameLabel.isHidden = true
            dateLabel.isHidden = true
            titleLabel.text = item.title
            titleLabel.numberOfLines = 1
            replyView.isHidden = true
            return
        }
        
        profileImage.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))   
        adminIconImage.isHidden = !isAdmin(mbId: item.mb_id!)
        userNameLabel.text = item.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: item.regdate ?? ""))"
        
        let isContainsHtmlTags = item.title!.isContainsHtmlTag()
        if let files = item.files {
            if files.count > 0 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "icon_image_xs")?.tint(with: UIColor(named: "nt-5")!)
                attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                
                let attributedString = NSMutableAttributedString(string: item.title!)
                attributedString.append(NSAttributedString(attachment: attachment))
                
                titleLabel.attributedText = attributedString
                titleLabel.sizeToFit()
            } else {
                if isContainsHtmlTags {
                    titleLabel.attributedText = item.title!.htmlToAttributedString()
                } else {
                    titleLabel.text = item.title!
                }
            }
        } else {
            if isContainsHtmlTags {
                titleLabel.attributedText = item.title!.htmlToAttributedString()
            } else {
                titleLabel.text = item.title!
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
    
    func isReportedItem(item: BoardListItem) -> Bool {
        guard let documentSRL = item.document_srl else { return false }
        return documentSRL.elementsEqual("-1")
    }
}

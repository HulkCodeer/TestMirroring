//
//  CommunityChargeStationTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SDWebImage

class CommunityChargeStationTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var chargeStationButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    
    @IBOutlet var thumbNailImage1: UIImageView!
    @IBOutlet var thumbNailImage2: UIImageView!
    @IBOutlet var thumbNailImage3: UIImageView!
    
    @IBOutlet var likedCount: UILabel!
    @IBOutlet var replyCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        thumbNailImage1.layer.cornerRadius = 12
        thumbNailImage2.layer.cornerRadius = 12
        thumbNailImage3.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        thumbNailImage1.image = nil
        thumbNailImage2.image = nil
        thumbNailImage3.image = nil
    }

    func configure(item: BoardListItem?) {
        guard let item = item else { return }
        
        profileImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile!)"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        nickNameLabel.text = item.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: item.regdate!))"
        
        thumbNailImage1.isHidden = true
        thumbNailImage2.isHidden = true
        thumbNailImage3.isHidden = true
        
        if let files = item.files {
            if files.count > 0 {
                if files.count == 1 {
                    thumbNailImage1.isHidden = false
                    thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
                } else if files.count == 2 {
                    thumbNailImage1.isHidden = false
                    thumbNailImage2.isHidden = false
                    
                    thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
                    thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
                } else {
                    thumbNailImage1.isHidden = false
                    thumbNailImage2.isHidden = false
                    thumbNailImage3.isHidden = false
                    
                    thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
                    thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
                    thumbNailImage3.sd_setImage(with: URL(string: "\(files[2].uploaded_filename!)"))
                }
            }
        }
        
        titleLabel.text = item.title
        contentsLabel.text = item.content
        
        likedCount.text = item.like_count
        replyCount.text = item.comment_count
    }
}

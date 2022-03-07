//
//  CommunityChargeStationTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import SnapKit

class CommunityChargeStationTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var chargeStationButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    
    @IBOutlet var adminIconImage: UIImageView!
    
    @IBOutlet var imageStackView: UIStackView!
    @IBOutlet var thumbNailImage1: UIImageView!
    @IBOutlet var thumbNailImage2: UIImageView!
    @IBOutlet var thumbNailImage3: UIImageView!
    @IBOutlet var thumbNailImage4: UIImageView!
    
    @IBOutlet var likedCount: UILabel!
    @IBOutlet var replyCount: UILabel!
    
    var chargerId: String?
    var chargeStataionButtonTappedCompletion: ((String) -> Void)?
    var adminList: [Admin]?
    
    private lazy var additionalCountLabel: UILabel = {
       let label = UILabel()
        label.text = "+1"
        label.textColor = UIColor(named: "nt-white")
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.sd_cancelCurrentImageLoad()
        thumbNailImage1.sd_cancelCurrentImageLoad()
        thumbNailImage2.sd_cancelCurrentImageLoad()
        thumbNailImage3.sd_cancelCurrentImageLoad()
        thumbNailImage4.sd_cancelCurrentImageLoad()
    }
    
    private func setUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        adminIconImage.isHidden = true
        thumbNailImage1.layer.cornerRadius = 12
        thumbNailImage2.layer.cornerRadius = 12
        thumbNailImage3.layer.cornerRadius = 12
        thumbNailImage4.layer.cornerRadius = 12
        
        imageStackView.isHidden = true
    }
    
    private func isAdmin(mbId: String) -> Bool {
        guard let adminList = adminList else { return false }
        return adminList.contains { $0.mb_id.equals(mbId) }
    }

    func configure(item: BoardListItem?) {
        guard let item = item else { return }
        // 프로필 이미지
        profileImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(item.mb_profile!)"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        // 닉네임
        nickNameLabel.text = item.nick_name
        // 등록 날짜
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: item.regdate!))"
        // admin icon
        adminIconImage.isHidden = !isAdmin(mbId: item.mb_id!)
        
        // 충전소 정보
        let tags = JSON(parseJSON: item.tags!)
        let chargerId = tags["charger_id"].string!
        self.chargerId = chargerId
        
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
            chargeStationButton.setTitle(charger.mStationInfoDto?.mSnm, for: .normal)
            chargeStationButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        }
        
        // 이미지 썸네일
        setImage(files: item.files)
        
        // 제목
        titleLabel.text = item.title
        // 내용
        contentsLabel.text = item.content
        // 좋아요 수
        likedCount.text = item.like_count
        // 댓글 수
        replyCount.text = item.comment_count
    }
    
    private func setImage(files: [FilesItem]?) {
        guard let files = files, files.count != 0 else {
            imageStackView.isHidden = true
            return
        }
        
        imageStackView.isHidden = false
        
        switch files.count {
        case 1:
            thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
        case 2:
            thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
            thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
        case 3:
            thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
            thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
            thumbNailImage3.sd_setImage(with: URL(string: "\(files[2].uploaded_filename!)"))
        case 4:
            thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
            thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
            thumbNailImage3.sd_setImage(with: URL(string: "\(files[2].uploaded_filename!)"))
            thumbNailImage4.sd_setImage(with: URL(string: "\(files[3].uploaded_filename!)"))
        case 5:
            thumbNailImage1.sd_setImage(with: URL(string: "\(files[0].uploaded_filename!)"))
            thumbNailImage2.sd_setImage(with: URL(string: "\(files[1].uploaded_filename!)"))
            thumbNailImage3.sd_setImage(with: URL(string: "\(files[2].uploaded_filename!)"))
            thumbNailImage4.sd_setImage(with: URL(string: "\(files[3].uploaded_filename!)"))
            
            thumbNailImage4.addSubview(additionalCountLabel)
            additionalCountLabel.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.width.equalTo(17)
                $0.height.equalTo(16)
            }
        default:
            break
        }
    }
    
    @IBAction func chargeStationButtonTapped(_ sender: Any) {
        guard let chargerId = chargerId else {
            return
        }
        
        chargeStataionButtonTappedCompletion?(chargerId)
    }
}

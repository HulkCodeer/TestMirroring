//
//  BoardDetailTableViewHeader.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import SwiftyJSON
import Accelerate

class BoardDetailTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var adminTagImage: UIImageView!
    @IBOutlet var reportButton: UIButton!
    @IBOutlet var chargeStationButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var likedCountLabel: UILabel!
    @IBOutlet var commentsCountLabel: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageStackView: UIStackView!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var image5: UIImageView!
    
    private var document: Document?
    private var files: [FilesItem] = []
    private var chargerId: String?
    var buttonClickDelegate: ButtonClickDelegate?
    var adminList: [Admin]?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        getAdminList { adminList in
            self.adminList = adminList
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    private func getAdminList(completion: @escaping ([Admin]) -> Void) {
        Server.getAdminList { (isSuccess, data) in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()

            do {
                let result = try decoder.decode([Admin].self, from: data)
                completion(result)
            } catch {
                completion([])
            }
        }
    }
    
    func setUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        image1.clipsToBounds = true
        image2.clipsToBounds = true
        image3.clipsToBounds = true
        image4.clipsToBounds = true
        image5.clipsToBounds = true
        chargeStationButton.isHidden = true
    }       
    
    override func prepareForReuse() {
        profileImageView.sd_cancelCurrentImageLoad()
        image1.sd_cancelCurrentImageLoad()
        image2.sd_cancelCurrentImageLoad()
        image3.sd_cancelCurrentImageLoad()
        image4.sd_cancelCurrentImageLoad()
        image5.sd_cancelCurrentImageLoad()
    }
    
    func configure(item: BoardDetailResponseData?, isFromStationDetailView: Bool) {
        guard let item = item,
        let document = item.document else { return }
        self.document = document
        
        profileImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(document.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        nickNameLabel.text = document.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: document.regdate ?? ""))"
        
        let isContainsHtmlTagInTitle = document.title!.isContainsHtmlTag()
        if isContainsHtmlTagInTitle {
            titleLabel.attributedText = document.title?.htmlToAttributedString()
        } else {
            titleLabel.text = document.title
        }
        
        let isContainsHtmlTagInContent = document.content!.isContainsHtmlTag()
        if isContainsHtmlTagInContent {
            contentsLabel.attributedText = document.content?.htmlToAttributedString()
        } else {
            contentsLabel.text = document.content
        }
        
        reportButton.isHidden = isAdmin(mbId: document.mb_id!)
        adminTagImage.isHidden = !isAdmin(mbId: document.mb_id!)
        
        // 충전소 정보
        if document.board_id == Board.BOARD_CATEGORY_CHARGER {
            if isFromStationDetailView {
                chargeStationButton.isHidden = true
            } else {
                chargeStationButton.isHidden = false

                let tags = JSON(parseJSON: document.tags!)
                let chargerId = tags["charger_id"].string!
                self.chargerId = chargerId
                
                if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
                    chargeStationButton.setTitle(charger.mStationInfoDto?.mSnm, for: .normal)
                    chargeStationButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
                }
            }
        } else {
            chargeStationButton.isHidden = true
        }
        
        if item.liked ?? 0 >= 1 {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
        }
        
        setImage(files: item.files)
        
        likedCountLabel.text = document.like_count
        commentsCountLabel.text = "\(item.comments?.count ?? 0)"
    }
    
    func setImage(files: [FilesItem]?) {
        guard let files = files, files.count != 0 else {
            imageContainerView.isHidden = true
            return
        }
        
        imageContainerView.isHidden = false
        
        switch files.count {
        case 1:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image1.isHidden = false
            image2.isHidden = true
            image3.isHidden = true
            image4.isHidden = true
            image5.isHidden = true
        case 2:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = true
            image4.isHidden = true
            image5.isHidden = true
        case 3:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
            image4.isHidden = true
            image5.isHidden = true
        case 4:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
            image4.sd_setImage(with: URL(string: files[3].uploaded_filename ?? ""))
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
            image4.isHidden = false
            image5.isHidden = true
        case 5:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
            image4.sd_setImage(with: URL(string: files[3].uploaded_filename ?? ""))
            image5.sd_setImage(with: URL(string: files[4].uploaded_filename ?? ""))
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
            image4.isHidden = false
            image5.isHidden = false
        default:
            break
        }
    }
    
    private func isAdmin(mbId: String) -> Bool {
        guard let adminList = adminList else { return false }
        return adminList.contains { $0.mb_id.equals(mbId) }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        guard let documentSRL = self.document?.document_srl else { return }
        self.buttonClickDelegate?.likeButtonCliked(isLiked: likeButton.isSelected, isComment: false, srl: documentSRL)
    }
    
    @IBAction func threeDotButtonTapped(_ sender: Any) {
        self.buttonClickDelegate?.threeDotButtonClicked(isHeader: true, row: -1)
    }
    
    @IBAction func chargeStationButtonTapped(_ sender: Any) {
        guard let chargerId = chargerId else { return }
        self.buttonClickDelegate?.moveToStation(with: chargerId)
    }
}


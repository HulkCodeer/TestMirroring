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
import Accelerate

class BoardDetailTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
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
    var buttonClickDelegate: ButtonClickDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    func setUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        image1.clipsToBounds = true
        image2.clipsToBounds = true
        image3.clipsToBounds = true
        image4.clipsToBounds = true
        image5.clipsToBounds = true
    }       
    
    override func prepareForReuse() {
        profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.image = nil
    }
    
    func configure(item: BoardDetailResponseData?) {
        self.document = item?.document
        guard let document = self.document else { return }
        
        profileImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(document.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        nickNameLabel.text = document.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: document.regdate ?? ""))"
        titleLabel.text = document.title
        contentsLabel.text = document.content
        
        
        if item?.liked ?? 0 >= 1 {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
        }
        
        setImage(files: item?.files)
        
        likedCountLabel.text = document.like_count
        commentsCountLabel.text = "\(item?.comments?.count ?? 0)"
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
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        guard let documentSRL = self.document?.document_srl else { return }
        self.buttonClickDelegate?.likeButtonCliked(isLiked: likeButton.isSelected, isComment: false, srl: documentSRL)
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        self.buttonClickDelegate?.reportButtonCliked(isHeader: true)
    }
}


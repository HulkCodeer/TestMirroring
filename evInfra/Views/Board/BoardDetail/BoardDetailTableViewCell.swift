//
//  BoardDetailTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SDWebImage

protocol ButtonClickDelegate {
    func threeDotButtonClicked(isHeader: Bool, row: Int)
    func likeButtonCliked(isLiked: Bool, isComment:Bool, srl: String)
    func commentButtonCliked(recomment: Comment, selectedRow: Int)
    func moveToStation(with chargerId: String)
}

class BoardDetailTableViewCell: UITableViewCell {

    @IBOutlet var backgroundCell: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var subCommentImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var likedCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    
    @IBOutlet var adminTagImage: UIImageView!
    @IBOutlet var reportButton: UIButton!
    
    @IBOutlet var likeStackView: UIStackView!
    @IBOutlet var commentStackView: UIStackView!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var writeCommentButton: UIButton!
    
    @IBOutlet var imageScrollStackView: UIScrollView!
    
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var image5: UIImageView!
    
    var buttonClickDelegate: ButtonClickDelegate?
    var comment: Comment?
    var row: Int = 0
    var adminList: [Admin]?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        image1.sd_cancelCurrentImageLoad()
        image2.sd_cancelCurrentImageLoad()
        image3.sd_cancelCurrentImageLoad()
        image4.sd_cancelCurrentImageLoad()
        image5.sd_cancelCurrentImageLoad()
        
        setUI()
        setDeletedCommentUI(isOn: false)
    }
    
    private func setUI() {
        titleLabel.attributedText = nil
        titleLabel.text = nil
        dateLabel.text = nil
        commentLabel.text = nil
        likedCountLabel.text = nil
        commentCountLabel.text = nil
        
        writeCommentButton.isHidden = false
        commentCountLabel.isHidden = false
        
        subCommentImageView.isHidden = true
        imageScrollStackView.isHidden = true
        commentStackView.isHidden = false
        
        image1.layer.cornerRadius = 12
        image2.layer.cornerRadius = 12
        image3.layer.cornerRadius = 12
        image4.layer.cornerRadius = 12
        image5.layer.cornerRadius = 12
        
        backgroundCell.backgroundColor = UIColor(named: "nt-white")
        backView.backgroundColor = UIColor(named: "nt-white")
    }
    
    private func setDeletedCommentUI(isOn: Bool) {
        titleLabel.attributedText = nil
        dateLabel.isHidden = isOn
        likeStackView.isHidden = isOn
        commentStackView.isHidden = isOn
        reportButton.isHidden = isOn
        adminTagImage.isHidden = isOn
        commentLabel.isHidden = isOn
    }
    
    private func isMyComment(mb_id: String) -> Bool {
        return MemberManager.getMbId().description.equals(mb_id)
    }
    
    private func isAdmin(mbId: String) -> Bool {
        guard let adminList = adminList else { return false }
        return adminList.contains { $0.mb_id.equals(mbId) }
    }
    
    func configureComment(comment: Comment?, row: Int) {
        guard let comment = comment else { return }
        self.comment = comment
        self.row = row
        
        // 대댓글 표시
        let isRecomment = !comment.parent_srl!.equals("0")
        if isRecomment {
            backgroundCell.backgroundColor = UIColor(named: "nt-0")
            backView.backgroundColor = UIColor(named: "nt-0")
            subCommentImageView.isHidden = !isRecomment
            writeCommentButton.isHidden = isRecomment
            commentCountLabel.isHidden = isRecomment
        }
        
        // 삭제 댓글 표시
        let isDeletedComment = comment.status!.equals("-1")
        if isDeletedComment {
            setDeletedCommentUI(isOn: true)
            titleLabel.attributedText = comment.content?.htmlToAttributedString()
        } else {
            setDeletedCommentUI(isOn: false)
            
            setImage(files: comment.files)
            titleLabel.text = comment.nick_name
            dateLabel.text = "| \(DateUtils.getTimesAgoString(date: comment.regdate ?? ""))"
            reportButton.isHidden = isAdmin(mbId: comment.mb_id!)
            adminTagImage.isHidden = !isAdmin(mbId: comment.mb_id!)
            commentLabel.text = comment.content
            likedCountLabel.text = comment.like_count
            commentCountLabel.text = comment.comment_count
        }
        
        // 본인이 좋아요 한 글, 하트 표시
        if comment.liked! >= 1 {
            likeButton.isSelected = true
        }
    }
    
    private func setImage(files: [FilesItem]?) {
        guard let files = files, files.count != 0 else {
            imageScrollStackView.isHidden = true
            return
        }

        imageScrollStackView.isHidden = false
        
        switch files.count {
        case 1:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
        case 2:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
        case 3:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
        case 4:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
            image4.sd_setImage(with: URL(string: files[3].uploaded_filename ?? ""))
        case 5:
            image1.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
            image2.sd_setImage(with: URL(string: files[1].uploaded_filename ?? ""))
            image3.sd_setImage(with: URL(string: files[2].uploaded_filename ?? ""))
            image4.sd_setImage(with: URL(string: files[3].uploaded_filename ?? ""))
            image5.sd_setImage(with: URL(string: files[4].uploaded_filename ?? ""))
        default:
            break
        }
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        self.buttonClickDelegate?.threeDotButtonClicked(isHeader: false, row: self.row)
    }
    
    @IBAction func likeButtonClick(_ sender: Any) {
        guard let commentSRL = self.comment?.comment_srl else { return }
        self.buttonClickDelegate?.likeButtonCliked(isLiked: likeButton.isSelected, isComment: true, srl: commentSRL)
    }
    
    @IBAction func writeCommentButtonClick(_ sender: Any) {
        guard let comment = self.comment else {
            return
        }
        
        self.buttonClickDelegate?.commentButtonCliked(recomment: comment, selectedRow: row)
    }
}


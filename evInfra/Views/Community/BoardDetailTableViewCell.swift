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
    func reportButtonCliked(isHeader: Bool)
    func likeButtonCliked(isLiked: Bool, isComment:Bool, srl: String)
    func commentButtonCliked(recomment: Comment)
    func deleteButtonCliked(documentSRL: String, commentSRL: String)
    func modifyButtonCliked(comment: Comment)
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
    
    @IBOutlet var modifyButton: UIButton!
    @IBOutlet var reportButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
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
        
        reportButton.isHidden = false
        deleteButton.isHidden = true
        modifyButton.isHidden = true
        
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
        modifyButton.isHidden = isOn
        deleteButton.isHidden = isOn
        commentLabel.isHidden = isOn
    }
    
    private func isMyComment(mb_id: String) -> Bool {
        return MemberManager.getMbId().description.equals(mb_id)
    }
    
    func configureComment(comment: Comment?, row: Int) {
        guard let comment = comment else { return }
        self.comment = comment
        self.row = row
        
        // 대댓글 표시
        if !comment.parent_srl!.equals("0") {
            backgroundCell.backgroundColor = UIColor(named: "nt-0")
            backView.backgroundColor = UIColor(named: "nt-0")
            subCommentImageView.isHidden = false
            commentStackView.isHidden = true
        }
        
        // 삭제 댓글 표시
        if comment.status!.equals("-1") {
            setDeletedCommentUI(isOn: true)
            titleLabel.attributedText = comment.content?.htmlToAttributedString()
        } else {
            setDeletedCommentUI(isOn: false)
            // 댓글에 이미지 표시
            setImage(files: comment.files)
            
            titleLabel.text = comment.nick_name
            dateLabel.text = "| \(DateUtils.getTimesAgoString(date: comment.regdate ?? ""))"
            commentLabel.text = comment.content
            likedCountLabel.text = comment.like_count
            commentCountLabel.text = comment.comment_count
            
            // 나의 댓글
            if isMyComment(mb_id: comment.mb_id ?? "") {
                reportButton.isHidden = true
                modifyButton.isHidden = false
                deleteButton.isHidden = false
            } else {
                reportButton.isHidden = false
                modifyButton.isHidden = true
                deleteButton.isHidden = true
            }
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
        self.buttonClickDelegate?.reportButtonCliked(isHeader: false)
    }
    
    @IBAction func likeButtonClick(_ sender: Any) {
        guard let commentSRL = self.comment?.comment_srl else { return }
        self.buttonClickDelegate?.likeButtonCliked(isLiked: likeButton.isSelected, isComment: true, srl: commentSRL)
    }
    
    @IBAction func writeCommentButtonClick(_ sender: Any) {
        guard let comment = self.comment else {
            return
        }
        
        self.buttonClickDelegate?.commentButtonCliked(recomment: comment)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let comment = comment else { return }
        
        self.buttonClickDelegate?.deleteButtonCliked(documentSRL: comment.document_srl!, commentSRL: comment.comment_srl!)
    }
    
    @IBAction func modifyButtonTapped(_ sender: Any) {
        guard let comment = comment else { return }

        self.buttonClickDelegate?.modifyButtonCliked(comment: comment)
    }
}


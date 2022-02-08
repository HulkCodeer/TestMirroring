//
//  BoardDetailTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

protocol ButtonClickDelegate {
    func reportButtonCliked(isHeader: Bool)
    func likeButtonCliked(isLiked: Bool, isComment:Bool, srl: String)
    func commentButtonCliked(recomment: Recomment)
    func deleteButtonCliked()
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
    
    private var documentSrl: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    private func setUI() {
        subCommentImageView.isHidden = true
        reportButton.isHidden = false
        deleteButton.isHidden = true
        imageScrollStackView.isHidden = true
        image1.layer.cornerRadius = 12
        image2.layer.cornerRadius = 12
        image3.layer.cornerRadius = 12
        image4.layer.cornerRadius = 12
        image5.layer.cornerRadius = 12
    }
    
    private func isMyComment(mb_id: String) -> Bool {
        if MemberManager.getMbId().description.equals(mb_id) {
            return true
        }
        return false
    }
    
    func configureComment(comment: Comment?, row: Int) {
        self.comment = comment
        guard let comment = self.comment else { return }
//        self.documentSrl = comment.document_srl ?? ""
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
            titleLabel.isHidden = true
            dateLabel.isHidden = true
            likeStackView.isHidden = true
            commentStackView.isHidden = true
            reportButton.isHidden = true
            deleteButton.isHidden = true
            commentLabel.text = "삭제된 댓글 입니다."
            return
        }
        
        if isMyComment(mb_id: comment.mb_id ?? "") {
            reportButton.isHidden = true
            deleteButton.isHidden = false
        }
        
        // 본인이 좋아요 버튼 클릭
        if comment.liked! >= 1 {
            likeButton.isSelected = true
        }
        
        // 댓글에 이미지 표시
        setImage(files: comment.files)
        
        titleLabel.text = comment.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: comment.regdate ?? ""))"
        commentLabel.text = comment.content
        likedCountLabel.text = comment.like_count
        commentCountLabel.text = comment.comment_count
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
    
    @IBAction func reportButtonClick(_ sender: Any) {
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
        
        let recomment = Recomment(targetMbId: comment.mb_id!, targetNickName: comment.nick_name!, parentSRL: comment.comment_srl!, head: comment.head!, depth: "\(Int(comment.depth!)! + 1)", row: row)
        
        self.buttonClickDelegate?.commentButtonCliked(recomment: recomment)
    }
    
    @IBAction func deleteButtonClick(_ sender: Any) {
        self.buttonClickDelegate?.deleteButtonCliked()
    }
}


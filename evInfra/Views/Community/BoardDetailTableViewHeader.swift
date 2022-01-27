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
    
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageStackView: UIStackView!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var image5: UIImageView!
    
    private var files: [FilesItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    func setUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        image1.translatesAutoresizingMaskIntoConstraints = true
        image2.translatesAutoresizingMaskIntoConstraints = true
        image3.translatesAutoresizingMaskIntoConstraints = true
        image4.translatesAutoresizingMaskIntoConstraints = true
        image5.translatesAutoresizingMaskIntoConstraints = true
//        image1.isHidden = true
//        image2.isHidden = true
//        image3.isHidden = true
//        image4.isHidden = true
//        image5.isHidden = true
//        imageStackView.isHidden = true
//        self.addSubview(imageTableView)
//        self.imageTableView.delegate = self
//        self.imageTableView.dataSource = self
//        self.imageTableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
    }       
    
    override func prepareForReuse() {
        profileImageView.sd_cancelCurrentImageLoad()
        profileImageView.image = nil
    }
    
    func configure(item: BoardDetailResponseData?) {
        
        guard let document = item?.document else { return }
        
        profileImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(document.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        
        nickNameLabel.text = document.nick_name
        dateLabel.text = "| \(DateUtils.getTimesAgoString(date: document.regdate ?? ""))"
        titleLabel.text = document.title
        contentsLabel.text = document.content
        
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
}

//extension BoardDetailTableViewHeader: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//}
//
//extension BoardDetailTableViewHeader: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell else { return UITableViewCell() }
//
//        cell.configure(file: files[indexPath.row])
//
//        debugPrint("\(files[indexPath.row].uploaded_filename)")
//
//        return cell
//    }
//}


class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet var fileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(file: FilesItem) {
        fileImageView.sd_setImage(with: URL(string: file.uploaded_filename ?? ""))
    }
}


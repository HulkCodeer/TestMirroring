//
//  BoardDetailTableViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

class BoardDetailTableViewCell: UITableViewCell {

    @IBOutlet var subCommentImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var likedCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func reportButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func likeButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func writeCommentButtonClick(_ sender: Any) {
        
    }
}

//
//  BoardDetailTableViewHeader.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

class BoardDetailTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var likedCountLabel: UILabel!
    @IBOutlet var commentsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    private func setUI() {
        
    }
}

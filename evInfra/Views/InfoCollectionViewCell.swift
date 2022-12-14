//
//  InfoCollectionViewCell.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material

class InfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareImageView()
    }
}

extension InfoCollectionViewCell {
    fileprivate func prepareImageView() {
        cellImage.clipsToBounds = true
        cellImage.contentMode = .scaleAspectFill
        contentView.clipsToBounds = true
        contentView.layout(cellImage).edges()
    }
}

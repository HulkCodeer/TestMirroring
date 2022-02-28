//
//  PhotoRegisterCollectionViewCell.swift
//  evInfra
//
//  Created by PKH on 2022/01/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

class PhotoRegisterCollectionViewCell: UICollectionViewCell {

    @IBOutlet var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
}

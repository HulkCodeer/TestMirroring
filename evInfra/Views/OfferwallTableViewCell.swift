//
//  OfferwallTableViewCell.swift
//  evInfra
//
//  Created by SooJin Choi on 2020/11/06.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import ExpyTableView

class OfferwallTableViewCell: UITableViewCell, ExpyTableViewHeaderCell {
    
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentStateImg: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var contentImg: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentTitle.isHidden = true
        contentStateImg.isHidden = true
        content.isHidden = true
        contentImg.isHidden = true
        
        content.numberOfLines = 0
        content.textColor = UIColor(hex: "#333333")
        content.fontSize = 16
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        switch state {
        case .willExpand:
            arrowDown(animated: !cellReuse)
        case .willCollapse:
            arrowRight(animated: !cellReuse)
        case .didExpand:
            break
        case .didCollapse:
            break
        }
    }
    
    private func arrowDown(animated: Bool) {
        if contentStateImg.isHidden == false {
            UIView.animate(withDuration: (animated ? 0.3 : 0)){
                self.contentStateImg.transform = CGAffineTransform(rotationAngle: -0.999 * (CGFloat.pi))
            }
        }
    }
    
    private func arrowRight(animated: Bool) {
        if contentStateImg.isHidden == false {
            UIView.animate(withDuration: (animated ? 0.3 : 0)){
                self.contentStateImg.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
    }
}

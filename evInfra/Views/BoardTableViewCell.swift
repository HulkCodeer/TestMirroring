//
//  BoardTableViewCell.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class BoardTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var rUserImage: UIImageView!
    @IBOutlet weak var rUserGuardIcon: UIImageView!
    @IBOutlet weak var rUserGuardLabel: UILabel!
    @IBOutlet weak var rUserName: UILabel!
    @IBOutlet weak var rDate: UILabel!
    @IBOutlet weak var rChargerType: UILabel!
    
    @IBOutlet weak var rContents: UILabel!
    
    @IBOutlet weak var rEditBtn: UIButton!
    @IBOutlet weak var rDeleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        rUserImage.layer.borderWidth = 1
        rUserImage.layer.masksToBounds = false
        rUserImage.layer.borderColor = UIColor.white.cgColor
        rUserImage.layer.cornerRadius = rUserImage.frame.height/2
        rUserImage.clipsToBounds = true
        
        rContents.numberOfLines = 0
        rContents.lineBreakMode = .byWordWrapping
        rContents.sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func makeShadow(){
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 3, height: 0)
        cellView.layer.shadowOpacity = 1;
        cellView.layer.shadowRadius = 0.8;
        cellView.layer.masksToBounds = false;
    }
}

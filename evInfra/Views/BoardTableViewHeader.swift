//
//  BoardTableViewHeader.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
class BoardTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userGuardIcon: UIImageView!
    @IBOutlet weak var userGuardLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var uDate: UILabel!
    @IBOutlet weak var uChargerType: UILabel!
    
    @IBOutlet weak var uImage: UIImageView!
    @IBOutlet weak var uText: UILabel!
    @IBOutlet weak var uGoCharger: UIButton!
    
    @IBOutlet weak var uEditBtn: UIButton!
    @IBOutlet weak var uDeletBtn: UIButton!
    @IBOutlet weak var uReplyBtn: UIButton!
    
    @IBOutlet weak var uReplyCnt: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        headerView.roundCorners([.topLeft, .topRight], radius: 15 * (100 / headerView.frame.height))
        
        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        
        uText.numberOfLines = 0
        uText.lineBreakMode = .byWordWrapping
        uText.sizeToFit()
        uReplyCnt.text = ""
    }
}

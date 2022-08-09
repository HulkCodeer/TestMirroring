//
//  LeftViewTableHeader.swift
//  evInfra
//
//  Created by bulacode on 09/08/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

class LeftViewTableHeader: UITableViewHeaderFooterView {
    
//    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellTitle.text = ""
    }
}

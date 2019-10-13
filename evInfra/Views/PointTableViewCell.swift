//
//  PointTableViewCell.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class PointTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelAction: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    
    func reloadData(evPoint: EvPoint) {
        print("date: " + evPoint.date!)
        print("action: " + evPoint.action!)
        print("point: " + evPoint.point!)
        self.labelDate.text = evPoint.date
        self.labelAmount.text = (evPoint.point?.currency() ?? "") + " 포인트"
        
        if evPoint.action?.elementsEqual("save") ?? false {
            self.labelAction.text = "적립"
        } else if evPoint.action?.elementsEqual("used") ?? false {
            self.labelAction.text = "사용"
        } else {
            self.labelAction.text = "포인트"
        }
    }
}

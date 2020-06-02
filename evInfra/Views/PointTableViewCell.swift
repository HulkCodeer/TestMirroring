//
//  PointTableViewCell.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class PointTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDate: UILabel! //date
    @IBOutlet weak var labelAction: UILabel! //action
    @IBOutlet weak var labelAmount: UILabel! //berry
    @IBOutlet weak var labelTitle: UILabel! //desc
    @IBOutlet weak var labelTime: UILabel! //time
    @IBOutlet weak var labelCategory: UILabel! //type
    
    let POINT_TYPE_NONE:Int = 0 // default value
    let POINT_TYPE_CHARGING:Int = 1; // 충전
    let POINT_TYPE_EVENT:Int = 2; // event
    let POINT_TYPE_REWARD:Int = 3; // 보상형 광고 적립
    
    func reloadData(evPoint: EvPoint) {
        
        let dateArr = evPoint.date?.components(separatedBy: " ")
        
        var date = dateArr?[0]
        let time = dateArr?[1]
        
        //remove year
        date = String(date?.dropFirst(5) ?? "")
            
        self.labelDate.text = date
        self.labelTime.text = time
        self.labelTitle.text = evPoint.desc
        
        if evPoint.action?.elementsEqual("save") ?? false {
            self.labelAction.text = "적립"
            self.labelAmount.text = "+" + (evPoint.point?.currency() ?? "") + " B"
        } else if evPoint.action?.elementsEqual("used") ?? false {
            self.labelAction.text = "사용"
            self.labelAmount.text = "-" + (evPoint.point?.currency() ?? "") + " B"
        } else {
            self.labelAction.text = "베리"
        }
        
        switch evPoint.type {
        case self.POINT_TYPE_CHARGING:
            self.labelCategory.text = "충전"
        case self.POINT_TYPE_EVENT:
            self.labelCategory.text = "이벤트"
        case self.POINT_TYPE_REWARD:
            self.labelCategory.text = "광고참여"
        case self.POINT_TYPE_NONE:
            break
        default:
            break
        }
    }
}

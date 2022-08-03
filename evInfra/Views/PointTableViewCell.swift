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

    func reloadData(point: EvPoint, beforeDate: String?, isFirst: Bool) {
        var (date, time) = sliceDate(date: point.date)
        
        setDate(currentDate: date, beforeDate: beforeDate, isFirst: isFirst)
        
        //remove year
        date = String(date?.dropFirst(5) ?? "")
            
        self.labelDate.text = date
        self.labelTime.text = time
        self.labelTitle.text = point.desc
        
        if point.action?.elementsEqual("save") ?? false {
            self.labelAction.text = "적립"
            self.labelAmount.text = "+" + (point.point?.currency() ?? "") + " B"
            self.labelAmount.textColor = UIColor(named: "gr-5")
        } else if point.action?.elementsEqual("used") ?? false {
            self.labelAction.text = "사용"
            self.labelAmount.text = "-" + (point.point?.currency() ?? "") + " B"
            self.labelAmount.textColor = UIColor(named: "content-primary")
        } else {
            self.labelAction.text = "기타"
        }
        
        let pointType = PointType(point.type)
        self.labelCategory.text = pointType.category
    }
    
    // MARK: Action
    
    private func setDate(currentDate: String?, beforeDate: String?, isFirst: Bool) {
        let (preDate, _) = sliceDate(date: beforeDate)
        
        self.labelDate.isHidden = !isFirst
        
        if let date = currentDate,
           let preDate = preDate,
           preDate.elementsEqual(date) {
            self.labelDate.isHidden = true
        } else {
            self.labelDate.isHidden = false
        }
    }
    
    private func sliceDate(date: String?) -> (date: String?, time: String?) {
        let separate = " "
        let dateArr = date?.components(separatedBy: separate)
        let date = dateArr?[0]
        let time = dateArr?[1]
        
        return (date, time)
    }
    
    // MARK: Object
    
    enum PointType {
        case none        // default value
        case charging   // 충전
        case event      // event
        case reward    // 보상형 광고
        
        case unkown     // EvPoint type Optional 관련
        
        init(_ type: Int?) {
            switch type {
            case 0:
                self = .none
            case 1:
                self = .charging
            case 2:
                self = .event
            case 3:
                self = .reward
            default:
                self = .unkown
            }
        }
        
        var category: String? {
            switch self {
            case .charging:
                return "충전"
            case .event:
                return  "이벤트"
            case .reward:
                return "광고참여"
            case .none, .unkown:
                return nil
            }
        }
    }
}

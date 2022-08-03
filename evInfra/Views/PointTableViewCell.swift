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
        
        setAmountView(actionType: point.loadActionType(), point: point.point)
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
  
    private func setCategory(type pointType: EvPoint.PointType) {
        var category: String?
        
        switch pointType {
        case .charging:
            category = "충전"
        case .event:
            category = "이벤트"
        case .reward:
            category = "광고참여"
        case .none, .unknown:
            break
        }
        
        self.labelCategory.text = category
    }
    
    private func setAmountView(actionType: EvPoint.ActionType, point: String?) {
        switch actionType {
        case .unknown:
            labelAction.text = "기타"
        case .savePoint, .usePoint:
            setAmountLabel(isSave: actionType == .savePoint, point: point)
        }
    }
    
    private func setAmountLabel(isSave: Bool?, point: String?) {
        guard let isSave = isSave else { return }
        let flag = isSave ? "+" : "-"
        let color: UIColor = isSave ? Colors.gr5.color : Colors.contentPrimary.color
        let currencyPoint = point?.currency() ?? String()
        
        labelAction.text = isSave ? "적립" : "사용"
        
        labelAmount.text = flag + currencyPoint + "B"
        labelAmount.textColor = color
        
    }
    
}

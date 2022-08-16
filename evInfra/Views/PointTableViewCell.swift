//
//  PointTableViewCell.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import UIKit

import Then
import SnapKit
import Material

//CommonBaseTableViewCell 적용!!!
internal final class PointTableViewCell: UITableViewCell {
    static let cellIdentifier = "PointTableViewCell"
//    @IBOutlet weak var labelDate: UILabel! //date
//    @IBOutlet weak var labelAction: UILabel! //action
//    @IBOutlet weak var labelAmount: UILabel! //berry
//    @IBOutlet weak var labelTitle: UILabel! //desc
//    @IBOutlet weak var labelTime: UILabel! //time
//    @IBOutlet weak var labelCategory: UILabel! //type
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private let dateStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    private let yearLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = Colors.contentTertiary.color
    }
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = Colors.contentPrimary.color
    }

    private let chargeInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = Colors.contentPrimary.color
    }
    private let timeCategoryLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = Colors.contentPrimary.color
    }
    
    private let amountStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    private let amountLabel = UILabel().then {
        $0.textColor = Colors.contentPrimary.color
    }
    private let actionLabel = UILabel().then { // 적립, 사용 등
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.nt2.color
    }
    
    // 선도 추가할까?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUI()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setUI() {
        self.selectionStyle = .none
        
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(dateStackView)
        contentStackView.addArrangedSubview(chargeInfoStackView)
        contentStackView.addArrangedSubview(amountStackView)
        self.addSubview(dividerView)

        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(yearLabel)

        chargeInfoStackView.addArrangedSubview(titleLabel)
        chargeInfoStackView.addArrangedSubview(timeCategoryLabel)

        amountStackView.addArrangedSubview(amountLabel)
        amountStackView.addArrangedSubview(actionLabel)
    }
    
    private func setConstraints() {
        let contentMargin: CGFloat = 5
        
        let dividerHeight: CGFloat = 1
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(contentMargin)
            $0.bottom.equalToSuperview().inset(contentMargin)
        }
        
        // dateView
        
        // chargeInfoView
        
        // amountView
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(dividerHeight)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
        
    // MARK: Action
    
    func configure(point: EvPoint, beforeDate: String?, isFirst: Bool) {
        let (year, date, time) = sliceDate(date: point.date)
        
        titleLabel.text = point.desc
        
        yearLabel.text = year
        dateLabel.text = date
        
        setDate(currentDate: date, beforeDate: beforeDate, isFirst: isFirst)
        setTimeCategory(type: point.loadPointType(), time: time)
        setAmountView(actionType: point.loadActionType(), point: point.point)
    }
    
    // MARK: private Action
    
    private func setDate(currentDate: String?, beforeDate: String?, isFirst: Bool) {
        let (_, preDate, _) = sliceDate(date: beforeDate)
        
        self.dateStackView.isHidden = !isFirst
        
        if let date = currentDate,
           let preDate = preDate,
           preDate.elementsEqual(date) {
            self.dateStackView.isHidden = true
        } else {
            self.dateStackView.isHidden = false
        }
    }
    
    private func setTimeCategory(type pointType: EvPoint.PointType, time: String?) {
        let time = time ?? String()
        var category = String()
        
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
        
        timeCategoryLabel.text = time + " | " + category
    }
    
    private func setAmountView(actionType: EvPoint.ActionType, point: String?) {
        switch actionType {
        case .unknown:
            actionLabel.text = "기타"
        case .savePoint, .usePoint:
            setAmountLabel(isSave: actionType == .savePoint, point: point)
        }
    }
    
    private func setAmountLabel(isSave: Bool?, point: String?) {
        guard let isSave = isSave else { return }
        let flag = isSave ? "+" : "-"
        let color: UIColor = isSave ? Colors.gr5.color : Colors.contentPrimary.color
        let currencyPoint = point?.currency() ?? String()
        
        actionLabel.text = isSave ? "적립" : "사용"
        
        amountLabel.text = flag + currencyPoint + "B"
        amountLabel.textColor = color
        
    }
    
    // yyyy.MM.dd HH:mm
    private func sliceDate(date dateStr: String?) -> (year: String?, date: String?, time: String?) {
        guard let date = dateStr?.toDate(dateFormat: Constants.date.longDateShortTime)
        else { return (nil, nil, nil) }
                
        let year = date.toString(dateFormat: Constants.date.year)
        let monDay = date.toString(dateFormat: Constants.date.monthDayDot)
        let time = date.toString(dateFormat: Constants.date.time)
        
        return (year, monDay, time)
    }
  
}

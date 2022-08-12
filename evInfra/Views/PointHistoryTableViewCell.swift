//
//  PointHistoryTableViewCell.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//


import UIKit

import Then
import SnapKit
import Material

internal final class PointHistoryTableViewCell: UITableViewCell {
    static let identfier = "PointHistoryTableViewCell"
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 18
    }
    
    private let dateStackView = UIStackView().then {
        $0.axis = .vertical
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
        $0.textColor = Colors.contentTertiary.color
    }
    private let timeCategoryLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private let amountStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .trailing
        $0.distribution = .equalSpacing
    }
    private let amountLabel = UILabel().then {
        $0.textColor = Colors.contentPrimary.color
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    private let actionLabel = UILabel().then { // 적립, 사용 등
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#E6E6E6")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
        setConstraints()
    }
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
        
//        self.addSubview(dividerView)
        
        contentView.addSubview(dateStackView)
        contentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(chargeInfoStackView)
        contentStackView.addArrangedSubview(amountStackView)
        

        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(yearLabel)
        
        chargeInfoStackView.addArrangedSubview(titleLabel)
        chargeInfoStackView.addArrangedSubview(timeCategoryLabel)
        
        amountStackView.addArrangedSubview(amountLabel)
        amountStackView.addArrangedSubview(actionLabel)
    }
    
    private func setConstraints() {
        let topMargin: CGFloat = 8
        let leadingMargin: CGFloat = 4
        let horizontalPadding: CGFloat = 18
        
        let stackViewVerticalSpacing: CGFloat = 4
        
        let dividerHeight: CGFloat = 1
        
        dateStackView.spacing = stackViewVerticalSpacing
        chargeInfoStackView.spacing = stackViewVerticalSpacing
        amountStackView.spacing = stackViewVerticalSpacing
        
        dateStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(leadingMargin)
        }
        
        contentStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(dateStackView.snp.trailing).offset(horizontalPadding)
            $0.trailing.equalToSuperview()
        }
        
//        dividerView.snp.makeConstraints {
//            $0.top.leading.trailing.equalToSuperview()
//            $0.height.equalTo(dividerHeight)
//        }
    }
    
    // MARK: Action
    
    func configure(point: EvPoint, beforeDate: String?, isFirst: Bool) {
        let (year, date, time) = sliceDate(date: point.date)
        
        titleLabel.text = point.desc
        
        yearLabel.text = year
        dateLabel.text = date
        
        let isBeforeSameDate = isBeforeSameDate(currentDate: date, beforeDate: beforeDate, isFirst: isFirst)
        dateStackView.isHidden = isBeforeSameDate
//        dividerView.isHidden = isFirst ? true : isBeforeSameDate
        
        setTimeCategory(type: point.loadPointType(), time: time)
        setAmountView(actionType: point.loadActionType(), point: point.point)
    }
    
    // MARK: private Action
    
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
        let color: UIColor = isSave ? Colors.contentPositive.color : Colors.contentPrimary.color
        let currencyPoint = point?.currency() ?? String()
        
        actionLabel.text = isSave ? "적립" : "사용"
        
        amountLabel.text = flag + currencyPoint + "B"
        amountLabel.textColor = color
        
    }
    
    private func isBeforeSameDate(currentDate: String?, beforeDate: String?, isFirst: Bool) -> Bool {
        guard !isFirst else { return false }
        let (_, preDate, _) = sliceDate(date: beforeDate)
        
        guard let currentDate = currentDate, let preDate = preDate else { return false }

        return preDate.elementsEqual(currentDate)
    }
    
    private func sliceDate(date dateStr: String?) -> (year: String?, date: String?, time: String?) {
        guard let date = dateStr?.toDate(dateFormat: Constant.date.longDateShortTime)
        else { return (nil, nil, nil) }
                
        let year = date.toString(dateFormat: Constant.date.year)
        let monthDay = date.toString(dateFormat: Constant.date.monthDayDot)
        let time = date.toString(dateFormat: Constant.date.time)
        
        return (year, monthDay, time)
    }
    
}

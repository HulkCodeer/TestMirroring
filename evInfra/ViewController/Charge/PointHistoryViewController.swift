//
//  PointHistoryViewController.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import SwiftyJSON
import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources

internal final class PointHistoryViewController: CommonBaseViewController, StoryboardView {
    
    private let pointInfoView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private let pointTableView = UITableView().then {
        $0.rowHeight = 72
        $0.separatorStyle = .none
        $0.register(PointHistoryTableViewCell.self, forCellReuseIdentifier: PointHistoryTableViewCell.identfier)
    }
    
    private let myPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 6
    }
    private let myPointMarkLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        $0.text = "나의 보유 베리"
    }
    private let myPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = UIColor.init(hex: "#292929")
    }
    private let pointGuideButton = UIButton().then {
        let image = Icons.iconQuestionXs.image
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.contentPrimary.color
        $0.contentMode = .scaleAspectFill
    }
    
    private let impendPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    private let impendPointMarkLbael = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        var month = Date().toString(dateFormat: Constant.date.month)
        $0.text = month + "월 소멸예정 베리"
    }
    private let impendPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#292929")
    }

    private let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    private let startDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.contentHorizontalAlignment = .right
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.backgroundColor = .clear
    }
    private let endDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.backgroundColor = .clear
    }
    private let dateDividerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "~"
        $0.textAlignment = .center
    }
    
    private let historyButtonsView = PointCategoryButtonsView()
    
    private let startDateView = DatePickerView().then {
        $0.isHidden = true
    }
    private let endDateView = DatePickerView().then {
        $0.isHidden = true
    }
    
    private let pointEmptyLabel = UILabel().then {
        $0.isHidden = true
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        
        $0.text = "포인트 내역이 없습니다."
    }
    
    private let pointTypeRelay = ReplayRelay<PointType>.create(bufferSize: 1)
    private let startDateRelay = BehaviorRelay(value: Date())
    private let endDateRelay = BehaviorRelay(value: Date())
    
    init(reactor: PointHistoryReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View LifeCycle
    
    override func loadView() {
        super.loadView()
        
        setUI()
        setConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeUI()
    }
    
    // MARK: bind
    
    internal func bind(reactor: PointHistoryReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: PointHistoryReactor) {
        historyButtonsView.allTypeButton.rx.tap
            .map{ _ in Reactor.Action.loadPointHistory(.all) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        historyButtonsView.useTypeButton.rx.tap
            .map { _ in Reactor.Action.loadPointHistory(.use) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        historyButtonsView.saveTypeButton.rx.tap
            .map{ _ in Reactor.Action.loadPointHistory(.save) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: PointHistoryReactor) {
        
    }
    
    private func subscribeUI() {
        pointGuideButton.rx.tap
            .bind(with: self) { owner, _  in
                owner.showPointGuide()
            }
            .disposed(by: disposeBag)
        
        startDateButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.startDateView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.endDateView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        startDateView.dateObservable
            .bind(to: startDateRelay)
            .disposed(by: disposeBag)
        
        endDateView.dateObservable
            .bind(to: endDateRelay)
            .disposed(by: disposeBag)
        
        startDateRelay
            .bind(with: self) { owner, date in
                let dateTitle = date.toYearMonthDay()
                owner.startDateButton.setTitle(dateTitle, for: .normal)
                owner.endDateView.minimumDate(date: date)
            }
            .disposed(by: disposeBag)
        
        endDateRelay
            .bind(with: self) { owner, date in
                let dateTitle = date.toYearMonthDay()
                owner.endDateButton.setTitle(dateTitle, for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: set ui
    
    private func setUI() {
        startDateView.configure(Date())
        endDateView.configure(Date())
        
        contentView.addSubview(pointInfoView)
        contentView.addSubview(pointTableView)
        contentView.addSubview(startDateView)
        contentView.addSubview(endDateView)

        pointInfoView.addSubview(myPointStackView)
        pointInfoView.addSubview(impendPointStackView)
        pointInfoView.addSubview(dateStackView)
        pointInfoView.addSubview(historyButtonsView)

        myPointStackView.addArrangedSubview(myPointMarkLabel)
        myPointStackView.addArrangedSubview(myPointLabel)
        myPointStackView.addArrangedSubview(pointGuideButton)
        
        impendPointStackView.addArrangedSubview(impendPointMarkLbael)
        impendPointStackView.addArrangedSubview(impendPointLabel)

        dateStackView.addArrangedSubview(startDateButton)
        dateStackView.addArrangedSubview(dateDividerLabel)
        dateStackView.addArrangedSubview(endDateButton)

        pointTableView.addSubview(pointEmptyLabel)
    }
    
    private func setConstraints() {
        let horizontalMargin: CGFloat = 20
        let myPointViewTopPadding: CGFloat = 20
        let impendPointViewTopPadding: CGFloat = 20
        let dateViewTopPadding: CGFloat = 20
        let historyButtonsViewBottomPadding: CGFloat = 16
        
        let pointInfoHeight: CGFloat = 172
        let guideButtonSize: CGFloat = 16
        let historyButtonsViewHeight: CGFloat = 30
        
        pointInfoView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(pointInfoHeight)
        }
        pointTableView.snp.makeConstraints {
            $0.top.equalTo(pointInfoView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
            $0.bottom.equalTo(view)
        }
        startDateView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view)
        }
        endDateView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(startDateView)
        }

        myPointStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(myPointViewTopPadding)
            $0.centerX.equalToSuperview()
        }
        pointGuideButton.snp.makeConstraints {
            $0.size.equalTo(guideButtonSize)
        }
        
        impendPointStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(myPointStackView.snp.bottom).offset(impendPointViewTopPadding)
        }

        dateStackView.snp.makeConstraints {
            $0.top.equalTo(impendPointStackView.snp.bottom).offset(dateViewTopPadding)
            $0.leading.equalToSuperview().inset(horizontalMargin)
            $0.trailing.equalToSuperview().inset(horizontalMargin)
        }
        historyButtonsView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(historyButtonsViewBottomPadding)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
            $0.height.equalTo(historyButtonsViewHeight)
        }
        
        pointEmptyLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    // MARK: Action
    
    private func showPointGuide() {
        let pointGuideVC = PointUseGuideViewController()
        GlobalDefine.shared.mainNavi?.push(viewController: pointGuideVC)
    }
    
    private func setImpendPoint(point: String) {
        let berryFlagText = "베리"
        let impendText = point + berryFlagText
        
        impendPointLabel.text = impendText
        impendPointLabel.attributedText = pointFontColor(text: impendText, pointText: berryFlagText)
    }
    
    private func pointFontColor(text: String, pointText: String) -> NSMutableAttributedString {
        let font: UIFont = .systemFont(ofSize: 14)
        let entireNSString = text as NSString
        let attributeString = NSMutableAttributedString(
            string: text,
            attributes: [.font: font]
        )
        
        attributeString.addAttribute(
            .foregroundColor,
            value: UIColor.init(hex: "#7B7B7B"),
            range: entireNSString.range(of: pointText))
        return attributeString
    }
    
    // MARK: Object
    
    enum PointType {
        case all
        case use
        case save
    }
}

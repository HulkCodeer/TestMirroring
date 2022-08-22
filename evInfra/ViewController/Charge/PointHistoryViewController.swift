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
    private lazy var customNavigationBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "MY 베리 내역"
    }
    private lazy var settingButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    private lazy var pointInfoView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var pointTableView = UITableView().then {
        $0.rowHeight = 72
        $0.separatorStyle = .none
        $0.register(PointHistoryTableViewCell.self, forCellReuseIdentifier: PointHistoryTableViewCell.identifier)
    }
    
    private lazy var myPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 6
    }
    private lazy var myPointMarkLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        $0.text = "나의 보유 베리"
    }
    private lazy var myPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = UIColor.init(hex: "#292929")
    }
    private lazy var pointGuideButton = UIButton().then {
        let image = Icons.iconQuestionXs.image
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.contentPrimary.color
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var impendPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    private lazy var impendPointMarkLbael = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        var month = Date().toString(dateFormat: Constants.date.shortMonth)
        $0.text = "\(month)월 소멸예정 베리"
    }
    private lazy var impendPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#292929")
    }

    private lazy var dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    private lazy var startDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.contentHorizontalAlignment = .right
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.backgroundColor = .clear
    }
    private lazy var endDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.backgroundColor = .clear
    }
    private lazy var dateDividerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "~"
        $0.textAlignment = .center
    }
    
    private lazy var pointTypeButtonsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = -1
    }
    
    private lazy var startDateView = DatePickerView().then {
        $0.isHidden = true
    }
    private lazy var endDateView = DatePickerView().then {
        $0.isHidden = true
    }
    
    private lazy var pointEmptyLabel = UILabel().then {
        $0.isHidden = true
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B")
        
        $0.text = "포인트 내역이 없습니다."
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeUI()
    }
    
    // MARK: bind
    
    internal func bind(reactor: PointHistoryReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        
        // pointType make + button bind
        makePointTypeButton(reactor: reactor)
    }
    
    private func bindAction(reactor: PointHistoryReactor) {
        MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                Observable.just(PointHistoryReactor.Action.loadPointInfo)
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
        
        let pointTypeObservable = reactor.state.compactMap { $0.pointType }
        
        Observable.combineLatest(pointTypeObservable, startDateRelay, endDateRelay)
            .map { Reactor.Action.loadPointHistory(type: $0, startDate: $1, endDate: $2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: PointHistoryReactor) {
        let evPointsObservable = reactor.state.compactMap { $0.evPointsViewItems }
        let evPointsCountObservable = reactor.state.compactMap { $0.evPointsCount }
        let totalPointObservable = reactor.state.compactMap { $0.totalPoint }
        let expirePointObservable = reactor.state.compactMap { $0.expirePoint }

        totalPointObservable
            .asDriver(onErrorJustReturn: "0")
            .drive(myPointLabel.rx.text)
            .disposed(by: disposeBag)
        
        expirePointObservable
            .asDriver(onErrorJustReturn: "0")
            .map { "\($0) 베리" }
            .drive(with: self) { owner, impendText in
                owner.impendPointLabel.text = impendText
                owner.impendPointLabel.attributedText = owner.pointFontColor(text: impendText, pointText: "베리")
            }
            .disposed(by: disposeBag)
        
        evPointsObservable
            .asDriver(onErrorJustReturn: [])
            .drive(pointTableView.rx.items(
                cellIdentifier: PointHistoryTableViewCell.identifier,
                cellType: PointHistoryTableViewCell.self)
            ) { indexPath, evPoinViewItem, cell in
                let isFirst = indexPath == 0
                let beforeDate = !isFirst ? evPoinViewItem.previousItemDate : nil
                
                cell.configure(point: evPoinViewItem.evPoint, beforeDate: beforeDate, isFirst: isFirst)
            }
            .disposed(by: disposeBag)
        
        evPointsCountObservable
            .asDriver(onErrorJustReturn: 0)
            .map { $0 <= 0 }
            .drive(with: self) { owner, isEmpty in
                owner.pointEmptyLabel.isHidden = !isEmpty
                owner.pointTableView.isScrollEnabled = !isEmpty
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeUI() {
        settingButton.rx.tap
            .asDriver()
            .drive { _ in
                let pointSettionVC = UIStoryboard(name: "Charge", bundle: nil)
                    .instantiateViewController(ofType: PreUsePointViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: pointSettionVC)
            }
            .disposed(by: disposeBag)
        
        pointGuideButton.rx.tap
            .asDriver()
            .drive{ _ in
                let pointGuideVC = PointUseGuideViewController()
                GlobalDefine.shared.mainNavi?.push(viewController: pointGuideVC)
            }
            .disposed(by: disposeBag)
        
        startDateButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.startDateView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
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
            .asDriver()
            .drive(with: self) { owner, date in
                let dateTitle = date.toYearMonthDay()
                owner.startDateButton.setTitle(dateTitle, for: .normal)
                owner.endDateView.minimumDate(date: date)
            }
            .disposed(by: disposeBag)
        
        endDateRelay
            .asDriver()
            .drive(with: self) { owner, date in
                let dateTitle = date.toYearMonthDay()
                owner.endDateButton.setTitle(dateTitle, for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: set ui
    
    private func setUI() {
        startDateView.configure(Date())
        endDateView.configure(Date())
        
        contentView.addSubview(customNavigationBar)
        contentView.addSubview(pointInfoView)
        contentView.addSubview(pointTableView)
        contentView.addSubview(startDateView)
        contentView.addSubview(endDateView)

        customNavigationBar.addSubview(settingButton)
        
        pointInfoView.addSubview(myPointStackView)
        pointInfoView.addSubview(impendPointStackView)
        pointInfoView.addSubview(dateStackView)
        pointInfoView.addSubview(pointTypeButtonsStackView)

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
        
        let guideButtonSize: CGFloat = 16
        let pointInfoHeight: CGFloat = 172
        let historyButtonsViewHeight: CGFloat = 30
        
        customNavigationBar.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        settingButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.view.naviBarItemPadding)
            $0.width.equalTo(Constants.view.naviBarItemWidth)
        }
        
        pointInfoView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
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
        
        pointTypeButtonsStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(historyButtonsViewBottomPadding)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
            $0.height.equalTo(historyButtonsViewHeight)
        }
        
        pointEmptyLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    // MARK: Action
    
    private func makePointTypeButton(reactor: PointHistoryReactor) {
        let buttonTypes = EvPoint.PointType.allCases
        var buttons = [EvPoint.PointType: SwitchColorButton]()
        for (index, pointType) in buttonTypes.enumerated() {
            let round: SwitchColorButton.Const.RoundType = {
                switch index {
                case 0:
                    return .sectionRound(.left)
                case buttonTypes.count - 1:
                    return .sectionRound(.right)
                default:
                    return .none
                }
            }()
            
            let button = SwitchColorButton(level: .myBerry, roundType: round).then {
                $0.setTitle(pointType.value, for: .normal)
            }
            
            // MARK: Button BindAction
            button.rx.tap
                .map { PointHistoryReactor.Action.setPointType(pointType) }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
            buttons[pointType] = button
            self.pointTypeButtonsStackView.addArrangedSubview(button)
        }
    
        let pointTypeObservable = reactor.state.compactMap { $0.pointType }
        let allButton = buttons[.all]
        let useButton = buttons[.usePoint]
        let saveButton = buttons[.savePoint]
        
        // MARK: Button BindState
        pointTypeObservable
            .asDriver(onErrorJustReturn: .all)
            .drive { pointType in
                switch pointType {
                case .all:
                    allButton?.rx.isSelected.onNext(true)
                    useButton?.rx.isSelected.onNext(false)
                    saveButton?.rx.isSelected.onNext(false)
                case .usePoint:
                    useButton?.rx.isSelected.onNext(true)
                    allButton?.rx.isSelected.onNext(false)
                    saveButton?.rx.isSelected.onNext(false)
                case .savePoint:
                    saveButton?.rx.isSelected.onNext(true)
                    allButton?.rx.isSelected.onNext(false)
                    useButton?.rx.isSelected.onNext(false)
                }
            }
            .disposed(by: disposeBag)
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

}

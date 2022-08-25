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
import ReusableKit

internal final class PointHistoryViewController: CommonBaseViewController, StoryboardView {

    typealias pointHistoryDataSource = RxTableViewSectionedReloadDataSource<PointHistorySectionModel>
    
    private enum Reusable {
        static let pointCell = ReusableCell<PointHistoryTableViewCell>()
    }
    
    private let dataSource = pointHistoryDataSource (
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeue(Reusable.pointCell, for: indexPath)
            
            let isFirst = indexPath.row == 0
            let beforeDate = !isFirst ? item.previousItemDate : nil
            
            cell.configure(point: item.evPoint, beforeDate: beforeDate, isFirst: isFirst)
            return cell
    })
    
    private lazy var customNavigationBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "MY 베리 내역"
    }
    private lazy var settingButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    private lazy var pointHistoryWrappingView = UIView()
    
    private lazy var pointInfoView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var pointTableView = UITableView().then {
        $0.rowHeight = 72
        $0.separatorStyle = .none
        
        $0.register(Reusable.pointCell)
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
        var month = Date().toString(dateFormat: .monthShort)
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
        
        $0.clipsToBounds = true
        $0.roundCorners(
            cornerType: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            radius: 8,
            borderColor: UIColor(hex: "#CECECE"),
            borderWidth: 1)
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

        startDateView.dateObservable
            .observe(on: MainScheduler.instance)
            .map { PointHistoryReactor.Action.setStartDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endDateView.dateObservable
            .observe(on: MainScheduler.instance)
            .map { PointHistoryReactor.Action.setEndDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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
                owner.endDateView.isHidden = true
            }
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.endDateView.isHidden = false
                owner.startDateView.isHidden = true
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: PointHistoryReactor) {
        reactor.state.compactMap { $0.totalPoint }
            .asDriver(onErrorJustReturn: "0")
            .drive(myPointLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.expirePoint }
            .asDriver(onErrorJustReturn: "0")
            .map { "\($0) 베리" }
            .drive(with: self) { owner, impendText in
                owner.impendPointLabel.text = impendText
                owner.impendPointLabel.pointFirstText(
                    pointText: "베리",
                    pointColor: UIColor.init(hex: "#7B7B7B"))
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.evPointsViewItems }
            .map { [PointHistorySectionModel(items: $0)] }
            .bind(to: pointTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.evPointsCount }
            .asDriver(onErrorJustReturn: 0)
            .map { $0 <= 0 }
            .drive(with: self) { owner, isEmpty in
                owner.pointEmptyLabel.isHidden = !isEmpty
                owner.pointTableView.isScrollEnabled = !isEmpty
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.startDate }
            .asDriver(onErrorJustReturn: Date())
            .drive(with: self) { owner, date in
                let dateTitle = date.toYearMonthDay()
                owner.startDateButton.setTitle(dateTitle, for: .normal)
                owner.endDateView.minimumDate(date: date)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.endDate }
            .asDriver(onErrorJustReturn: Date())
            .map { $0.toYearMonthDay() }
            .drive(with: self) { owner, dateStr in
                owner.endDateButton.setTitle(dateStr, for: .normal)
            }
            .disposed(by: disposeBag)
        
        let pointTypeObservable = reactor.state.compactMap { $0.pointType }
        let startDateObservable = reactor.state.compactMap { $0.startDate }
        let endDateObseervable = reactor.state.compactMap { $0.endDate }
        
        Observable.combineLatest(pointTypeObservable, startDateObservable, endDateObseervable)
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.loadPointHistory(($0, $1, $2)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
        
    // MARK: set ui
    
    private func setUI() {
        startDateView.configure(Date())
        endDateView.configure(Date())
        
        contentView.addSubview(customNavigationBar)
        contentView.addSubview(pointHistoryWrappingView)
        
        customNavigationBar.addSubview(settingButton)
        
        pointHistoryWrappingView.addSubview(pointInfoView)
        pointHistoryWrappingView.addSubview(pointTableView)
        pointHistoryWrappingView.addSubview(startDateView)
        pointHistoryWrappingView.addSubview(endDateView)

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
        
        pointHistoryWrappingView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(horizontalMargin)
            $0.bottom.equalTo(view)
        }
        
        pointInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(pointInfoHeight)
        }

        pointTableView.snp.makeConstraints {
            $0.top.equalTo(pointInfoView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        startDateView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
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
            $0.leading.trailing.equalToSuperview()
        }
        
        pointTypeButtonsStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(historyButtonsViewBottomPadding)
            $0.leading.trailing.equalToSuperview()
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
        
        for pointType in buttonTypes {

            let button = SwitchColorButton().then {
                $0.setTitle(pointType.value, for: .normal)
            }
            
            // MARK: Button Bind
            button.rx.tap
                .map { PointHistoryReactor.Action.setPointType(pointType) }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
            reactor.state.compactMap { $0.pointType}
                .asDriver(onErrorJustReturn: .all)
                .map { $0 == pointType}
                .drive (button.rx.isSelected)
                .disposed(by: disposeBag)
            
            buttons[pointType] = button
            self.pointTypeButtonsStackView.addArrangedSubview(button)
        }

    }
    
}

// MARK: Object

struct PointHistorySectionModel {
    var items: [PointHistoryReactor.PointViewItem]
}

extension PointHistorySectionModel: SectionModelType {
    typealias item = PointHistoryReactor.PointViewItem

    init(original: PointHistorySectionModel, items: [item]) {
        self = original
        self.items = items
    }
}

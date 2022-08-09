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

internal final class PointHistoryViewController: CommonBaseViewController, StoryboardView {
    
    private let pointInfoView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private let pointContractionView = UIView()
    private let historyContentView = UIView()
    
    private let myPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    private let myPointMarkLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B96")
    }
    private let myPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = UIColor.init(hex: "#292929")
    }
    private let pointGuideButton = UIButton().then {
        let image = Icons.iconQuestionXs.image
        $0.setImage(image, for: .normal)
        $0.contentMode = .scaleAspectFill
    }
    
    private let impendPointStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    private let impendPointMarkLbael = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#7B7B7B96")
    }
    private let impendPointLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.init(hex: "#292929")
    }

    private let startDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
    }
    private let endDateButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
    }
    private let dateDividerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "~"
    }
    
    private let historyButtonsView = PointCategoryButtonsView()
    
    private let resultMsgLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    private let pointTableView = UITableView()
    
    private let pointTypeRelay = ReplayRelay<PointType>.create(bufferSize: 1)
    
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
    }
    
    // MARK: set ui
    
    private func setUI() {
        contentView.addSubview(pointInfoView)
        contentView.addSubview(pointTableView)
        contentView.addSubview(resultMsgLabel)
        contentView.addSubview(datePicker)

        pointInfoView.addSubview(pointContractionView)
        pointInfoView.addSubview(historyContentView)
        
        pointContractionView.addSubview(myPointStackView)
        pointContractionView.addSubview(impendPointStackView)
        
        myPointStackView.addArrangedSubview(myPointMarkLabel)
        myPointStackView.addArrangedSubview(myPointLabel)
        myPointStackView.addArrangedSubview(pointGuideButton)

        impendPointStackView.addArrangedSubview(impendPointMarkLbael)
        impendPointStackView.addArrangedSubview(impendPointLabel)
        pointInfoView.addSubview(historyButtonsView)

        historyContentView.addSubview(startDateButton)
        historyContentView.addSubview(endDateButton)
        historyContentView.addSubview(dateDividerLabel)
        
    }
    
    private func setConstraints() {
        let historyButtonsViewVerticalMargin: CGFloat = 20
        let historyButtonsViewBottomMargin: CGFloat = 16
        
        let pointContractionHeight: CGFloat = 88
        let historyContentHeight: CGFloat = 52
        let pointInfoHeight: CGFloat = pointContractionHeight + historyContentHeight
        let historyButtonsViewHeight: CGFloat = 30
        
        pointInfoView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(pointInfoHeight)
        }
        
        pointTableView.snp.makeConstraints {
            $0.top.equalTo(pointInfoView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        historyButtonsView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(historyButtonsViewBottomMargin)
            $0.leading.equalToSuperview().inset(historyButtonsViewVerticalMargin)
            $0.trailing.equalToSuperview().inset(historyButtonsViewVerticalMargin)
            $0.height.equalTo(historyButtonsViewHeight)
        }
    }
    
    // MARK: Action
    
    private func pointFontColor() {
        
    }
    
    private func showPointGuide() {
        let pointGuideVC = PointUseGuideViewController()
        GlobalDefine.shared.mainNavi?.push(viewController: pointGuideVC)
    }
    
    // MARK: Object
    enum PointType {
        case all
        case use
        case save
    }
}

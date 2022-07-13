//
//  NewAcceptTermsViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReusableKit
import ReactorKit

internal final class NewAcceptTermsViewController: CommonBaseViewController, StoryboardView {
    
    enum Const {
        static let cellTotalCount: Int = 8
    }
    
    enum TermsType: Int, CaseIterable {
        case serviceUse = 0
        case privacyAgree = 1
        case privacyPolicy = 2
        case serviceLocation = 3
        case contents = 4
        case marketing = 5
        case ad = 6
        case age = 7
        case none
        
        init(value: Int) {
            switch value {
            case 0: self = .serviceUse
            case 1: self = .privacyAgree
            case 2: self = .privacyPolicy
            case 3: self = .serviceLocation
            case 4: self = .contents
            case 5: self = .marketing
            case 6: self = .ad
            case 7: self = .age
            default: self = .none
            }
        }
        
        internal var title: String {
            switch self {
            case .serviceUse: return "서비스 이용약관"
            case .privacyAgree: return "개인정보 수집 및 이용 동의"
            case .privacyPolicy: return "개인정보처리방침"
            case .serviceLocation: return "위치기반서비스 이용약관"
            case .contents: return "(선택) 콘텐츠 활용 동의"
            case .marketing: return "(선택) 홍보 및 마케팅 목적 개인정보 수집 및 이용 동의"
            case .ad: return "(선택) 광고성 정보 수신 동의"
            case .age: return "만 14세 이상입니다."
            case .none: return ""
            }
        }
    }
    
    // MARK: UI
    
    private enum Reusable {
        static let acceptTermsCell = ReusableCell<AcceptTermsCell>(nibName: AcceptTermsCell.reuseID)
    }
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원 가입"
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "더 나은 충전 생활을 위해"
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "아래와 같은 동의가 필요합니다."
    }
    
    private lazy var allAcceptTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var allAcceptCheckBtn = CheckBox().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isSelected = false
    }

    private lazy var allAcceptTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.textColor = Colors.contentPrimary.color
        $0.text = "전체 동의하기"
    }

    private lazy var allAcceptTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(Reusable.acceptTermsCell)
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 56
        $0.allowsSelection = false
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var nextBtn = NextButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
    }
    
    // MARK: VARIABLE
    private var cellViewModels = [AceeptTermsCellViewModel].init(repeating: AceeptTermsCellViewModel(with: .none, isChecked: false, index: 0), count: Const.cellTotalCount)
    private var isCheckedCells = [Bool].init(repeating: false, count: Const.cellTotalCount)
        
    // MARK: SYSTEM FUNC
    
    internal func bind(reactor: AcceptTermsReactor) {
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let viewcon = NewSignUpViewController()
                viewcon.reactor = reactor
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(allAcceptTotalView)
        allAcceptTotalView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        allAcceptTotalView.addSubview(allAcceptCheckBtn)
        allAcceptCheckBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        allAcceptTotalView.addSubview(allAcceptTitleLabel)
        allAcceptTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(allAcceptCheckBtn.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
        }
        
        allAcceptTotalView.addSubview(allAcceptTitleBtn)
        allAcceptTitleBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let lineView = self.createLineView()
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(allAcceptTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allAcceptTitleBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                for (index, _) in self.cellViewModels.enumerated() {
                    self.isCheckedCells[index] = !self.allAcceptCheckBtn.isSelected
                }
                self.nextBtn.isEnabled = !self.allAcceptCheckBtn.isSelected
                self.allAcceptCheckBtn.isSelected = !self.allAcceptCheckBtn.isSelected
                self.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        self.nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
}

extension NewAcceptTermsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return TermsType.allCases.filter { $0 != .none }.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: AcceptTermsCell.self, for: indexPath)
        let index = indexPath.row
        let termsType = TermsType(value: index)
        let model = AceeptTermsCellViewModel(with: termsType, isChecked: isCheckedCells[index], index: index)
                    
        cellViewModels[index] = model
        
        model.tappedMoveObservable
            .asDriver(onErrorJustReturn: -1)
            .filter { $0 != -1 }
            .drive(onNext: { index in
                let viewcon = NewTermsViewController()
                
                switch TermsType(value: index) {
                case .serviceUse:
                    viewcon.tabIndex = .serviceUse
                                    
                case .privacyAgree:
                    viewcon.tabIndex = .privacyAgree
                
                case .privacyPolicy:
                    viewcon.tabIndex = .privacyAgree
                
                case .serviceLocation:
                    viewcon.tabIndex = .serviceLocation
                
                case .contents:
                    viewcon.tabIndex = .contents
                
                case .marketing:
                    viewcon.tabIndex = .marketing
                    
                case .ad:
                    viewcon.tabIndex = .ad
                    
                default: break                    
                }
                
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)
        
        model.tappedCheckedObservable
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isChecked in
                guard let self = self else { return }
                self.isCheckedCells[index] = isChecked
                
                self.nextBtn.isEnabled = self.isCheckedCells[0...3].allSatisfy({ $0 }) && self.isCheckedCells.last == true
                
                self.allAcceptCheckBtn.isSelected = self.isCheckedCells.allSatisfy({ $0 })
            })
            .disposed(by: self.disposeBag)
        
        cell.bind(to: model)
        
        return cell
    }
}

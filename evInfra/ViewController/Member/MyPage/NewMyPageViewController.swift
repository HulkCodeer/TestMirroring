//
//  NewMyPageViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/21.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import ReusableKit
import RxDataSources
import SwiftyJSON

internal final class NewMyPageViewController: CommonBaseViewController, StoryboardView {
    typealias MainDataSource = RxTableViewSectionedReloadDataSource<MyCarListSectionModel>
    
    private enum Reusable {
        static let myPageCarListCell = ReusableCell<MyPageCarListCell>(nibName: MyPageCarListCell.reuseID)
        static let myPageCarEmptyCell = ReusableCell<MyPageCarEmptyCell>(nibName: MyPageCarEmptyCell.reuseID)
    }
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "개인정보 관리"
    }
    
    private lazy var profileTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var profileImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconProfileEmpty.image        
    }
    
    private lazy var userInfoTotalView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 8
        $0.backgroundColor = .white
    }
    
    private lazy var nickNameLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
    }
    
    private lazy var userMoreInfoLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private lazy var modifyUserInfoBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("수정하기", for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.IBcornerRadius = 6
        $0.backgroundColor = Colors.backgroundSecondary.color
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    private lazy var myCarGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "내 차량"
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(Reusable.myPageCarListCell)
        $0.register(Reusable.myPageCarEmptyCell)
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 72
        $0.allowsSelection = true
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
    }
    
    // MARK: VARIABLE
    
    private let dataSource = MainDataSource(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .myCarInfoItem(let reactor):
            let cell = tableView.dequeue(Reusable.myPageCarListCell, for: indexPath)
            cell.reactor = reactor
            return cell
            
        case .myCarEmptyItem(let reactor):
            let cell = tableView.dequeue(Reusable.myPageCarEmptyCell, for: indexPath)
            cell.reactor = reactor
            return cell
        }
    })
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(profileTotalView)
        profileTotalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(104)
        }
        
        self.profileTotalView.addSubview(profileImgView)
        profileImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        
        self.profileTotalView.addSubview(userInfoTotalView)
        userInfoTotalView.snp.makeConstraints {
            $0.leading.equalTo(profileImgView.snp.trailing).offset(16)
            $0.height.equalTo(44)
            $0.centerY.equalTo(profileImgView.snp.centerY)
        }
        
        userInfoTotalView.addArrangedSubview(nickNameLbl)
        userInfoTotalView.addArrangedSubview(userMoreInfoLbl)
        
        self.profileTotalView.addSubview(modifyUserInfoBtn)
        modifyUserInfoBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-17)
            $0.width.equalTo(84)
            $0.height.equalTo(36)
            $0.centerY.equalToSuperview()
        }
        
        let line = self.createLineView(color: Colors.backgroundSecondary.color)
        self.contentView.addSubview(line)
        line.snp.makeConstraints {
            $0.top.equalTo(profileTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        
        self.contentView.addSubview(myCarGuideLbl)
        myCarGuideLbl.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(myCarGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        profileImgView.IBcornerRadius = 56 / 2
        profileImgView.sd_setImage(with: URL(string: "\(Const.EI_IMG_SERVER)\(MemberManager.shared.profileImage)"), placeholderImage: Icons.iconProfileEmpty.image)
        nickNameLbl.text = MemberManager.shared.memberNickName
        guard !MemberManager.shared.ageRange.isEmpty, !MemberManager.shared.gender.isEmpty else { return }
        userMoreInfoLbl.text = "\(MemberManager.shared.ageRange), \(MemberManager.shared.gender)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    func bind(reactor: MyPageReactor) {
        Observable.just(MyPageReactor.Action.getMyCarList)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.sections}
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}

enum MyCarListItem {
    case myCarInfoItem(reactor: MyPageCarListReactor)
    case myCarEmptyItem(reactor: MyPageCarListReactor)
}

struct MyCarListSectionModel {
    var myCarList: [MyCarListItem]
    
    init(items: [MyCarListItem]) {
        self.myCarList = items
    }
}

extension MyCarListSectionModel: SectionModelType {
    typealias Item = MyCarListItem
    
    var items: [MyCarListItem] {
        self.myCarList
    }
    
    init(original: MyCarListSectionModel, items: [Item]) {
        self = original
        self.myCarList = items
    }
}
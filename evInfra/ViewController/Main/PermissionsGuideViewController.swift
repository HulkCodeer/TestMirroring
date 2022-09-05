//
//  PermissionsGuideViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/09/01.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit

internal final class PermissionsGuideViewController: CommonBaseViewController, StoryboardView {
    
    enum PermissionTypes: CaseIterable {
        case location
        case test
        
        internal var title: String {
            switch self {
            case .location: return "위치 동의(선택)"
            case .test: return "위치 동의(선택)"
            }
        }
        
        internal var description: String {
            switch self {
            case .location: return "내 현재 위치를 기준으로 주변 충전소 찾기,\n충전소 경로 안내, 근처의 혜택 정보 및\n광고 제공을 위한 필수 정보로 활용됩니다."
            case .test: return "내 현재 위치를 기준으로 주변 충전소 찾기,\n충전소 경로 안내, 근처의 혜택 정보 및\n광고 제공을 위한 필수 정보로 활용됩니다."
            }
        }
        
        internal var typeImage: UIImage {
            switch self {
            case .location: return Icons.iconCurrentLocationMd.image
            case .test: return Icons.iconCurrentLocationMd.image
            }
        }
    }
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {        
        $0.naviTitleLbl.text = "권한동의"
        $0.naviBackBtn.isHidden = true
    }
    
    private lazy var totalView = UIView()
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "더 나은 충전 생활을 위해"
        $0.textAlignment = .natural
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.text = "아래의 권한 동의가 필요합니다."
        $0.textAlignment = .natural
    }
    
    private lazy var permissionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 24
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()        
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        self.totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        self.totalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        self.totalView.addSubview(permissionStackView)
        permissionStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        for type in PermissionTypes.allCases {
            permissionStackView.addArrangedSubview(self.createPermissionView(type: type))
        }
    }
    
    // MARK: FUNC
    
    private func createPermissionView(type: PermissionTypes) -> UIView {
        let view = UIView()
        
        let imgTotalView = UIView().then {
            $0.IBcornerRadius = 48/2
            $0.backgroundColor = Colors.backgroundPositiveLight.color
        }
        view.addSubview(imgTotalView)
        imgTotalView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        let imgView = UIImageView().then {
            $0.image = Icons.iconCurrentLocationMd.image
            $0.tintColor = Colors.backgroundPositive.color
        }
        imgTotalView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.center.equalToSuperview()
        }
                
        let mainTitleLbl = UILabel().then {
            $0.text = type.title
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.backgroundAlwaysDark.color
            $0.sizeToFit()
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(imgTotalView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        let subTitleLbl = UILabel().then {
            $0.text = type.description
            $0.textAlignment = .natural
            $0.numberOfLines = 3
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
            $0.sizeToFit()
        }
        
        view.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(4)
            $0.leading.equalTo(imgTotalView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.lessThanOrEqualTo(100)
        }        
        return view
    }
    
    // MARK: REACTOR
    
    init(reactor: PermissionsGuideReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func bind(reactor: PermissionsGuideReactor) {
        
    }
}

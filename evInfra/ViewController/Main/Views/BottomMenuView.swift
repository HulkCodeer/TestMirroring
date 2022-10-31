//
//  BottomMenuView.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import Then
import RxCocoa
import SnapKit

internal final class BottomMenuView: UIView {
    /*
     @IBOutlet var btn_menu_layer: UIView!
     @IBOutlet var btn_main_charge: UIButton!
     @IBOutlet var btn_main_community: UIButton!
     @IBOutlet var btn_main_help: UIButton!             // 삭제 evPay 버튼으로 변경.
     @IBOutlet var btn_main_favorite: UIButton!
     
     @IBOutlet weak var btnChargePrice: UIButton!
     */
    
    private lazy var btn_menu_layer = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.shadowRadius = 5
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowOffset = CGSize(width: 0.5, height: 2)
//        $0.layer.masksToBounds = false
    }
    private lazy var menuStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    private lazy var qrChargeLayer = UIView()
    private lazy var qrChargeIcon = UIImageView().then {
        $0.image = ChargeType.basic.value.icon
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFit
    }
    private lazy var qrChargeLabel = UILabel().then {
        $0.text = ChargeType.basic.value.title
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11)
    }
    internal lazy var btn_main_charge = UIButton()

    private lazy var communityLayer = UIView()
    private lazy var communityIcon = UIImageView().then {
        $0.image = Icons.iconCommentSm.image
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFit
    }
    private lazy var communityLabel = UILabel().then {
        $0.text = "자유게시판"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11)
    }
    internal lazy var btn_main_community = UIButton()
    
    private lazy var evPayLayer = UIView()
    private lazy var evPayIcon = UIImageView().then {
        $0.image = EvPayType.basic.icon
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFit
    }
    private lazy var evPayLabel = UILabel().then {
        $0.text = "EV Pay 관리"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11)
    }
    internal lazy var evPayButton = UIButton()

    private lazy var favoriteLayer = UIView()
    private lazy var favoriteIcon = UIImageView().then {
        $0.image = Icons.iconStarSm.image
        $0.tintColor = Colors.contentTertiary.color
        $0.contentMode = .scaleAspectFit
    }
    private lazy var favoriteLabel = UILabel().then {
        $0.text = "즐겨찾기"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 11)
    }
    internal lazy var btn_main_favorite = UIButton()
    
    // 따로.
//    private lazy var chargePriceLayer = UIView().then {
//        $0.backgroundColor = Colors.backgroundPrimary.color
//    }
//    private lazy var chargePriceIcon = UIImageView().then {
//        $0.image = Icons.iconCoinFill.image
//        $0.tintColor = Colors.nt6.color
//    }
//    private lazy var chargePriceLabel = UILabel().then {
//        $0.text = "충전 요금 안내"
//        $0.textColor = Colors.nt6.color
//    }
//    internal lazy var btnChargePrice = UIButton()
    
    // MARK: System func
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconTopPadding: CGFloat = 10
        let labelTopPadding: CGFloat = 4
        
        let iconWidth: CGFloat = 32
        let iconHeight: CGFloat = 24
        
        self.addSubview(btn_menu_layer)
        btn_menu_layer.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(62)
        }
        
        btn_menu_layer.addSubview(menuStackView)
        menuStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        
        menuStackView.addArrangedSubview(qrChargeLayer)
        menuStackView.addArrangedSubview(communityLayer)
        menuStackView.addArrangedSubview(evPayLayer)
        menuStackView.addArrangedSubview(favoriteLayer)
        
        qrChargeLayer.addSubview(qrChargeIcon)
        qrChargeIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(iconTopPadding)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconHeight)
            $0.width.equalTo(iconWidth)
        }
        qrChargeLayer.addSubview(qrChargeLabel)
        qrChargeLabel.snp.makeConstraints {
            $0.top.equalTo(qrChargeIcon.snp.bottom).offset(labelTopPadding)
            $0.centerX.equalToSuperview()
        }
        qrChargeLayer.addSubview(btn_main_charge)
        btn_main_charge.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        communityLayer.addSubview(communityIcon)
        communityIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(iconTopPadding)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconHeight)
            $0.width.equalTo(iconWidth)
        }
        communityLayer.addSubview(communityLabel)
        communityLabel.snp.makeConstraints {
            $0.top.equalTo(communityIcon.snp.bottom).offset(labelTopPadding)
            $0.centerX.equalToSuperview()
        }
        communityLayer.addSubview(btn_main_community)
        btn_main_charge.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        evPayLayer.addSubview(evPayIcon)
        evPayIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(iconTopPadding)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconHeight)
            $0.width.equalTo(iconWidth)
        }
        evPayLayer.addSubview(evPayLabel)
        evPayLabel.snp.makeConstraints {
            $0.top.equalTo(evPayIcon.snp.bottom).offset(labelTopPadding)
            $0.centerX.equalToSuperview()
        }
        evPayLayer.addSubview(evPayButton)
        evPayButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        favoriteLayer.addSubview(favoriteIcon)
        favoriteIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(iconTopPadding)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconHeight)
            $0.width.equalTo(iconWidth)
        }
        favoriteLayer.addSubview(favoriteLabel)
        favoriteLabel.snp.makeConstraints {
            $0.top.equalTo(favoriteIcon.snp.bottom).offset(labelTopPadding)
            $0.centerX.equalToSuperview()
        }
        favoriteLayer.addSubview(btn_main_favorite)
        btn_main_favorite.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func setQRButton(_ type: ChargeType) {
        qrChargeLabel.text = type.value.title
        qrChargeIcon.image = type.value.icon
    }
    
    internal func setEvPayButton(_ type: EvPayType = .basic) {
        evPayIcon.image = type.icon
    }
    
    enum ChargeType {
        case basic
        case charging
        
        var value: (title: String, icon: UIImage) {
            switch self {
            case .basic:
                return ("QR충전", Icons.iconQr.image)

            case .charging:
                return ("충전중", Icons.icLineCharging.image)
            }
        }
    }
    
    enum EvPayType {
        case basic
        case badge
        
        var icon: UIImage {
            switch self {
            case .basic:
                return Icons.iconEvpay.image
            case .badge:
                return Icons.iconEvpayNew.image
            }
        }
    }
}

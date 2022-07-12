//
//  FavoriteCell.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/07/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import SnapKit
import Then

internal class NewFavoriteCell: UITableViewCell, ReactorKit.View {
    internal var disposeBag = DisposeBag()
    
    private lazy var verticalContainerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .fill
    }
    
    private lazy var hStackView1 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.alignment = .fill
    }
    
    private lazy var hStackView2 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
    }
    
    private lazy var hStackView3 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
    }
    
    private lazy var stationNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.numberOfLines = 1
        $0.textColor = Colors.contentPrimary.color
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var alarmButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_notifications_off"), for: .normal)
        $0.setImage(UIImage(named: "ic_notifications_active"), for: .selected)
        $0.contentMode = .scaleToFill
    }

    private lazy var favoriteButton = UIButton().then {
        $0.setImage(UIImage(named: "bookmark"), for: .normal)
        $0.setImage(UIImage(named: "bookmark_on"), for: .selected)
        $0.contentMode = .scaleToFill
    }
    
    private lazy var addressLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 2
        $0.textColor = Colors.contentPrimary.color
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var distanceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = Colors.gr5.color
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var statusLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = Colors.contentPrimary.color
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var typeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = Colors.contentTertiary.color
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        contentView.addSubview(verticalContainerStackView)
        verticalContainerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        verticalContainerStackView.addArrangedSubview(hStackView1)
        verticalContainerStackView.addArrangedSubview(hStackView2)
        verticalContainerStackView.addArrangedSubview(hStackView3)
        
        // hStackView1
        hStackView1.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(verticalContainerStackView)
            $0.bottom.equalTo(hStackView2.snp.top).offset(-4)
        }
        hStackView1.addArrangedSubview(stationNameLabel)
        hStackView1.addArrangedSubview(alarmButton)
        hStackView1.addArrangedSubview(favoriteButton)
        stationNameLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(alarmButton.snp.leading).offset(-8)
        }
        alarmButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(favoriteButton.snp.leading)
            $0.leading.equalTo(stationNameLabel.snp.trailing)
        }
        favoriteButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalTo(alarmButton.snp.trailing)
            $0.top.trailing.bottom.equalToSuperview()
        }
        
        // hStackView2
        hStackView2.snp.makeConstraints {
            $0.top.equalTo(hStackView1.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(verticalContainerStackView)
            $0.bottom.equalTo(hStackView3.snp.top).offset(-8)
        }
        hStackView2.addArrangedSubview(addressLabel)
        hStackView2.addArrangedSubview(distanceLabel)
        addressLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(distanceLabel.snp.leading).offset(-8)
        }
        distanceLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(addressLabel.snp.trailing).offset(8)
        }
        
        // hStackView3
        hStackView3.snp.makeConstraints {
            $0.top.equalTo(hStackView2.snp.bottom).offset(8)
            $0.bottom.leading.trailing.equalTo(verticalContainerStackView)
        }
        hStackView3.addArrangedSubview(statusLabel)
        hStackView3.addArrangedSubview(typeLabel)
        statusLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(typeLabel.snp.leading)
        }
        typeLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(statusLabel.snp.trailing)
        }
    }
    
    internal func bind(reactor: NewFavoriteCellReactor<FavoriteListInfo>) {
        reactor.state.compactMap {
            $0.model.stationName
        }.bind(to: stationNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.address
        }.bind(to: addressLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.totalStatusName
        }.map { String($0) }
        .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.cstColor
        }.bind(to: statusLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.distance
        }.bind(to: distanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.type
        }.bind(to: typeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.isFavorite
        }.bind(to: favoriteButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.isAlarmOn
        }.bind(to: alarmButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap.map {
            Reactor.Action.favoriteButtonTapped(chargerId: reactor.initialState.model.chargerId, isOn: !self.favoriteButton.isSelected)
        }.bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: {
                if !self.favoriteButton.isSelected {
                    Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
                } else {
                    Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
                }
            }).disposed(by: disposeBag)
        
        alarmButton.rx.tap.map {
            Reactor.Action.alarmButtonTapped(chargerId: reactor.initialState.model.chargerId, isOn: !self.alarmButton.isSelected)
        }.bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

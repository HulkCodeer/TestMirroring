//
//  ReportHistoryCell.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import SnapKit
import Then

internal final class ReportHistoryCell: UITableViewCell, ReactorKit.View {
    internal var disposeBag = DisposeBag()
    
    private lazy var cellSelectButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var containerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    private lazy var titleWithDateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
    }
    
    private lazy var reportTypeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17, weight: .regular)
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = UIColor(named: "nt-5")
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private lazy var stateWithChargerNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
    }
    
    private lazy var statusLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = UIColor(named: "gr-4")
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var stationNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.textColor = UIColor(named: "gr-7")
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var adminCommentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = UIColor(named: "nt-5")
        $0.numberOfLines = 2
        $0.lineBreakMode = .byWordWrapping
        $0.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        makeUI()
    }
    
    private func makeUI() {
        contentView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        containerStackView.addArrangedSubview(titleWithDateStackView)
        containerStackView.addArrangedSubview(stateWithChargerNameStackView)
        containerStackView.addArrangedSubview(adminCommentLabel)
        titleWithDateStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(containerStackView)
            $0.bottom.equalTo(stateWithChargerNameStackView.snp.top).offset(-8)
        }
        
        stateWithChargerNameStackView.snp.makeConstraints {
            $0.top.equalTo(titleWithDateStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(containerStackView)
            $0.bottom.equalTo(adminCommentLabel.snp.top).offset(-8)
        }
        
        adminCommentLabel.snp.makeConstraints {
            $0.top.equalTo(stateWithChargerNameStackView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalTo(containerStackView)
        }
        
        titleWithDateStackView.addArrangedSubview(reportTypeLabel)
        titleWithDateStackView.addArrangedSubview(dateLabel)
        reportTypeLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(titleWithDateStackView)
            $0.trailing.equalTo(dateLabel.snp.leading)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalTo(titleWithDateStackView)
            $0.leading.equalTo(reportTypeLabel.snp.trailing)
        }
        
        stateWithChargerNameStackView.addArrangedSubview(statusLabel)
        stateWithChargerNameStackView.addArrangedSubview(stationNameLabel)
        statusLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(stateWithChargerNameStackView)
            $0.trailing.equalTo(stationNameLabel.snp.leading).offset(-16)
        }

        stationNameLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalTo(stateWithChargerNameStackView)
            $0.leading.equalTo(statusLabel.snp.trailing)
        }
        
        contentView.addSubview(cellSelectButton)
        cellSelectButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func bind(reactor: ReportHistoryCellReactor<ReportHistoryListDataModel.ReportHistoryInfo>) {
        reactor.state.compactMap {
            $0.model.type
        }.bind(to: reportTypeLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.reg_date
        }.bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.status
        }.bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap {
            $0.model.snm
        }.bind(to: stationNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        cellSelectButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let reportChargeViewController = UIStoryboard(name: "Report", bundle: nil).instantiateViewController(ofType: ReportChargeViewController.self)
                reportChargeViewController.info.charger_id = reactor.initialState.model.charger_id
                
                GlobalDefine.shared.mainNavi?.push(viewController: reportChargeViewController)
            }.disposed(by: disposeBag)
        
        adminCommentLabel.isHidden = true
        
        guard reactor.initialState.model.status_id != ReportHistoryListDataModel.ReportHistoryInfo.ReportStatus.reject.rawValue,
              let _ = reactor.initialState.model.admin_cmt else {

            adminCommentLabel.isHidden = false
            reactor.state.compactMap {
                $0.model.admin_cmt
            }.bind(to: adminCommentLabel.rx.text)
                .disposed(by: disposeBag)
            return
        }
    }
}

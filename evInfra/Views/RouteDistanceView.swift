//
//  RouteDistanceView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol DelegateRouteDistance {
    func closeView()
    func showNaviagtionSelectedMenu()
}

internal final class RouteDistanceView: UIView {
    let containerView = UIView().then {
        $0.backgroundColor = UIColor(named: "background-primary")
        $0.layer.cornerRadius = 6
    }
    
    let stackView = UIStackView().then {
        $0.alignment = .leading
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "background-secondary")
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 6
    }
    
    let routeStartButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "background-positive")
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.tintColor = UIColor(named: "content-primary")
        $0.setImage(UIImage(named: "icon_corner_right_md"), for: .normal)
        $0.setTitle("계산중", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 6
    }
    
    private let disposeBag = DisposeBag()
    var delegate: DelegateRouteDistance?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        isHidden = true
        
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        stackView.addArrangedSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(36)
        }

        stackView.addArrangedSubview(routeStartButton)
        routeStartButton.snp.makeConstraints {
            $0.width.equalTo(88)
            $0.height.equalTo(36)
        }
    }
    
    private func bind() {
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.closeView()
            }).disposed(by: disposeBag)
        
        routeStartButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.showNaviagtionSelectedMenu()
            }).disposed(by: disposeBag)
    }
    
    internal func setRouteLabel(with distance: NSString) {
        routeStartButton.setTitle("\(distance) 안내시작", for: .normal)
    }
}



//
//  CarRegistrationFirstStepViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class CarRegistrationFirstStepViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
    
    private lazy var firstStepTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
                 
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "반가워요! 이브이님 😊\n차량에 맞는 전기차 충전소를 찾아드릴게요. "
        $0.numberOfLines = 2
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = "내 전기차 번호를 등록해보세요. "
        $0.numberOfLines = 1
    }
    
    private lazy var carNumberLookUpTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .next
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(firstStepTotalView)
        firstStepTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        firstStepTotalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalTo(firstStepTotalView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        firstStepTotalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        firstStepTotalView.addSubview(carNumberLookUpTf)
        carNumberLookUpTf.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        
    }
}

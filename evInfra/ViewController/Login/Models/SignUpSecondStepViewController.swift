//
//  SignUpSecondStepViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/14.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class SignUpSecondStepViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
    
    private lazy var secondStepTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "EV Infra 내에서 사용될\n정보를 입력해주세요."
        $0.numberOfLines = 2
    }
    
    private lazy var loginInfoGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = ""
        $0.numberOfLines = 1
    }
            
    private lazy var requiredGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "*은 필수항목 입니다."
        let attributeText = NSMutableAttributedString(string: tempText)
        let allRange = NSMakeRange(0, attributeText.length)
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.contentSecondary.color], range: allRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)], range: allRange)
        var chageRange = (attributeText.string as NSString).range(of: "*")
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: chageRange)
        $0.attributedText = attributeText
        $0.numberOfLines = 1
    }
    
    private lazy var ageGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "연령대*"
        let attributeText = NSMutableAttributedString(string: tempText)
        let allRange = NSMakeRange(0, attributeText.length)
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.contentPrimary.color], range: allRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], range: allRange)
        var chageRange = (attributeText.string as NSString).range(of: "*")
        attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
        attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], range: chageRange)
        $0.attributedText = attributeText
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
    }
    
    private lazy var selectBoxTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "20대"
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxArrow = ChevronArrow.init(.size24(.down)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBimageColor = Colors.contentPrimary.color
    }
    
    private lazy var selectBoxTotalBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(secondStepTotalView)
        secondStepTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        secondStepTotalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        secondStepTotalView.addSubview(loginInfoGuideLbl)
        loginInfoGuideLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(41)
        }
        
        secondStepTotalView.addSubview(requiredGuideLbl)
        requiredGuideLbl.snp.makeConstraints {
            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        secondStepTotalView.addSubview(ageGuideLbl)
        ageGuideLbl.snp.makeConstraints {
            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }
        
//        secondStepTotalView.addSubview(selectBoxTotalView)
//        selectBoxTotalView.snp.makeConstraints {
//            $0.top.equalTo(ageGuideLbl.snp.bottom).offset(8)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(48)
//            $0.bottom.equalToSuperview()
//        }
//
//        selectBoxTotalView.addSubview(selectBoxTitleLbl)
//        selectBoxTitleLbl.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(16)
//            $0.centerY.equalToSuperview()
//        }
//
//        selectBoxTotalView.addSubview(selectBoxArrow)
//        selectBoxArrow.snp.makeConstraints {
//            $0.trailing.equalToSuperview().offset(-16)
//            $0.centerY.equalToSuperview()
//            $0.width.height.equalTo(24)
//        }
//
//        selectBoxTotalView.addSubview(selectBoxTotalBtn)
//        selectBoxTotalBtn.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }
    
    internal func bind(reactor: SignUpReactor) {
        selectBoxTotalBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                
//                let rowVC = NewBottomSheetViewController()
//                rowVC.items = reactor.currentState.quitAccountReasonList?.compactMap { $0.reasonMessage } ?? []
//                rowVC.headerTitleStr = "탈퇴 사유 선택"
//                rowVC.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
//                self.addChildViewController(rowVC)
//                self.view.addSubview(rowVC.view)
//                                                                              
//                rowVC.selectedCompletion = { [weak self] index in
//                    guard let self = self else { return }
//                    reactor.selectedReasonIndex = index
//                    self.selectBoxTitleLbl.text = rowVC.items[index]
//                    self.nextBtn.isEnabled = true
//                    self.reasonTotalView.isHidden = false
//                    rowVC.view.removeFromSuperview()
//                    rowVC.removeFromParentViewController()
//                }
            })
            .disposed(by: self.disposeBag)
    }
}

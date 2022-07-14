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
    
    private lazy var stepOneTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var stepOneScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = true
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
    
    private lazy var nickNameGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "프로필/닉네임*"
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
    
    private lazy var nickNameTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .next
    }
    
    private lazy var nickNameWrringLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.text = "닉네임은 공백을 포함하지 않은 2글자 이상으로 작성해주세요"
    }
    
    private lazy var emailGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "이메일*"
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
    
    private lazy var emailTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .next
    }
    
    private lazy var emailWrringLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.text = "이메일 형식을 확인해주세요"
    }
    
    private lazy var phoneGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "전화번호*"
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
    
    private lazy var phoneTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.keyboardType = .numberPad
        $0.returnKeyType = .next
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
    }
    
    private lazy var phoneWrringLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.text = "전화번호를 정확하게 입력해주세요"
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(stepOneTotalView)
        stepOneTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        stepOneTotalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        stepOneTotalView.addSubview(loginInfoGuideLbl)
        loginInfoGuideLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(41)
        }
        
        stepOneTotalView.addSubview(requiredGuideLbl)
        requiredGuideLbl.snp.makeConstraints {
            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        stepOneTotalView.addSubview(nickNameGuideLbl)
        nickNameGuideLbl.snp.makeConstraints {
            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        stepOneTotalView.addSubview(nickNameTf)
        nickNameTf.snp.makeConstraints {
            $0.top.equalTo(nickNameGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        stepOneTotalView.addSubview(nickNameWrringLbl)
        nickNameWrringLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(nickNameTf.snp.bottom).offset(2)
        }
        
        stepOneTotalView.addSubview(emailGuideLbl)
        emailGuideLbl.snp.makeConstraints {
            $0.top.equalTo(nickNameTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        stepOneTotalView.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        stepOneTotalView.addSubview(emailWrringLbl)
        emailWrringLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(emailTf.snp.bottom).offset(2)
        }
        
        stepOneTotalView.addSubview(phoneGuideLbl)
        phoneGuideLbl.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        stepOneTotalView.addSubview(phoneTf)
        phoneTf.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        stepOneTotalView.addSubview(phoneWrringLbl)
        phoneWrringLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(phoneTf.snp.bottom).offset(2)
            $0.bottom.equalToSuperview()
        }
    }
    
    internal func bind(reactor: AcceptTermsReactor) {
        reactor.state.compactMap { $0.isValidNickName }
            .asDriver(onErrorJustReturn: false)
            .drive(nickNameWrringLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidEmail }
            .asDriver(onErrorJustReturn: false)
            .drive(emailWrringLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidPhone }
            .asDriver(onErrorJustReturn: false)
            .drive(phoneWrringLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
}

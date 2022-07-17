//
//  SignUpStepOneViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import AnyFormatKit
import UIKit

internal final class SignUpUserInfoStepViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var totalView = UIView().then {
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
        $0.numberOfLines = 2
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
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .default
        $0.keyboardType = .default
        $0.placeholder = "닉네임을 입력해주세요"
        $0.delegate = self
        $0.addLeftPadding(padding: 16)
    }
    
    private lazy var nickNameWarningLbl = UILabel().then {
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
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .default
        $0.keyboardType = .emailAddress
        $0.placeholder = "이메일을 입력해주세요."
        $0.delegate = self
        $0.addLeftPadding(padding: 16)
    }
    
    private lazy var emailWarningLbl = UILabel().then {
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
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.keyboardType = .numberPad
        $0.returnKeyType = .default
        $0.placeholder = "전화번호를 입력해주세요."
        $0.delegate = self
        $0.addLeftPadding(padding: 16)
    }
    
    private lazy var phoneWarningLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.text = "전화번호를 정확하게 입력해주세요"
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
        
        totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        totalView.addSubview(loginInfoGuideLbl)
        loginInfoGuideLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(41)
        }
        
        totalView.addSubview(requiredGuideLbl)
        requiredGuideLbl.snp.makeConstraints {
            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(nickNameGuideLbl)
        nickNameGuideLbl.snp.makeConstraints {
            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        totalView.addSubview(nickNameTf)
        nickNameTf.snp.makeConstraints {
            $0.top.equalTo(nickNameGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        totalView.addSubview(nickNameWarningLbl)
        nickNameWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(nickNameTf.snp.bottom).offset(2)
        }
        
        totalView.addSubview(emailGuideLbl)
        emailGuideLbl.snp.makeConstraints {
            $0.top.equalTo(nickNameTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        totalView.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        totalView.addSubview(emailWarningLbl)
        emailWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(emailTf.snp.bottom).offset(2)
        }
        
        totalView.addSubview(phoneGuideLbl)
        phoneGuideLbl.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        totalView.addSubview(phoneTf)
        phoneTf.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        totalView.addSubview(phoneWarningLbl)
        phoneWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(phoneTf.snp.bottom).offset(2)
            $0.height.equalTo(15)
            $0.bottom.greaterThanOrEqualToSuperview().offset(30)
        }
    }
    
    internal func bind(reactor: SignUpReactor) {
        reactor.state.compactMap { $0.signUpUserData }
            .asDriver(onErrorJustReturn: Login(.none))
            .drive(onNext: { [weak self] userData in
                guard let self = self else { return }
                
                if !userData.email.isEmpty {
                    self.loginInfoGuideLbl.text = "\(userData.loginType.value)에서 제공된 정보이며, 커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                } else {
                    self.loginInfoGuideLbl.text = "커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                }
                                
                self.nickNameTf.text = userData.name
                self.emailTf.text = userData.email
                
                if let _otherInfo = userData.otherInfo {
                    self.emailTf.isEnabled = !_otherInfo.is_email_verified
                }
                                
                self.phoneTf.text = userData.displayPhoneNumber                                                                               
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidNickName }
            .asDriver(onErrorJustReturn: false)
            .drive(nickNameWarningLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidEmail }
            .asDriver(onErrorJustReturn: false)
            .drive(emailWarningLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidPhone }
            .asDriver(onErrorJustReturn: false)
            .drive(phoneWarningLbl.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
}

extension SignUpUserInfoStepViewController: UITextFieldDelegate {
    private func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTf {
            guard let text = textField.text else {
                return false
            }
            let characterSet = CharacterSet(charactersIn: string)
            if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
                return false
            }

            let formatter = DefaultTextInputFormatter(textPattern: "###-####-####")
            let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
            textField.text = result.formattedText
            let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
            return false
        } else if textField == nickNameTf {
            guard let text = textField.text else {
                return false
            }
            
            let newLength = text.count + string.count - range.length
            if newLength > 12 {
                Snackbar().show(message: "닉네임은 최대 12자까지 입력가능합니다")
                return false
            }
        }
        return true
    }
    
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nickNameTf {
            emailTf.becomeFirstResponder()
        } else if textField == emailTf {
            phoneTf.becomeFirstResponder()
        } else {
            phoneTf.resignFirstResponder()
            view.endEditing(true)
        }
        return true
    }
}

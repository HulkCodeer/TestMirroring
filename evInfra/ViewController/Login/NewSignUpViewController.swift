//
//  NewSignUpViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit
import SwiftyJSON
import AnyFormatKit

internal final class NewSignUpViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "정보 입력"
    }
    
    private lazy var userInfoStepTotalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
    
    private lazy var userInfoStepTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        $0.addGestureRecognizer(gesture)
    }
    
    private lazy var userInfoStepDismissKeyboardBtn = UIButton().then {
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
        $0.isHidden = true
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
        $0.isHidden = true
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
        $0.isHidden = true
    }
            
    private lazy var userInfoMoreTotalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = true
    }
    
    private lazy var userInfoMoreTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var moreMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "EV Infra 내에서 사용될\n정보를 입력해주세요."
        $0.numberOfLines = 2
    }
    
    private lazy var moreLoginInfoGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.text = ""
        $0.numberOfLines = 1
    }
            
    private lazy var moreRequiredGuideLbl = UILabel().then {
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
    
    private lazy var genderGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "성별*"
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
    
    private lazy var genderTotalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.spacing = 26
        $0.backgroundColor = .white
    }
           
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음으로", for: .normal)
        $0.setTitle("다음으로", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
    }
    
    // MARK: VARIABLE
        
    private var genderRadioArr: [Radio] = []
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
                                        
        self.contentView.addSubview(userInfoStepTotalScrollView)
        userInfoStepTotalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        userInfoStepTotalScrollView.addSubview(userInfoStepTotalView)
        userInfoStepTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
                                
        userInfoStepTotalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        userInfoStepTotalView.addSubview(loginInfoGuideLbl)
        loginInfoGuideLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(41)
        }
        
        userInfoStepTotalView.addSubview(requiredGuideLbl)
        requiredGuideLbl.snp.makeConstraints {
            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        userInfoStepTotalView.addSubview(nickNameGuideLbl)
        nickNameGuideLbl.snp.makeConstraints {
            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        userInfoStepTotalView.addSubview(nickNameTf)
        nickNameTf.snp.makeConstraints {
            $0.top.equalTo(nickNameGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        userInfoStepTotalView.addSubview(nickNameWarningLbl)
        nickNameWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(nickNameTf.snp.bottom).offset(2)
        }
        
        userInfoStepTotalView.addSubview(emailGuideLbl)
        emailGuideLbl.snp.makeConstraints {
            $0.top.equalTo(nickNameTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        userInfoStepTotalView.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        userInfoStepTotalView.addSubview(emailWarningLbl)
        emailWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(emailTf.snp.bottom).offset(2)
        }
        
        userInfoStepTotalView.addSubview(phoneGuideLbl)
        phoneGuideLbl.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        userInfoStepTotalView.addSubview(phoneTf)
        phoneTf.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        userInfoStepTotalView.addSubview(phoneWarningLbl)
        phoneWarningLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(phoneTf.snp.bottom).offset(2)
            $0.height.equalTo(15)
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
        
        self.contentView.addSubview(userInfoMoreTotalScrollView)
        userInfoMoreTotalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }

        userInfoMoreTotalScrollView.addSubview(userInfoMoreTotalView)
        userInfoMoreTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.centerX.equalToSuperview()
        }
        
        userInfoMoreTotalView.addSubview(moreMainTitleLbl)
        moreMainTitleLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        userInfoMoreTotalView.addSubview(moreLoginInfoGuideLbl)
        moreLoginInfoGuideLbl.snp.makeConstraints {
            $0.top.equalTo(moreMainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(41)
        }

        userInfoMoreTotalView.addSubview(moreRequiredGuideLbl)
        moreRequiredGuideLbl.snp.makeConstraints {
            $0.top.equalTo(loginInfoGuideLbl.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(16)
        }

        userInfoMoreTotalView.addSubview(ageGuideLbl)
        ageGuideLbl.snp.makeConstraints {
            $0.top.equalTo(requiredGuideLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }

        userInfoMoreTotalView.addSubview(selectBoxTotalView)
        selectBoxTotalView.snp.makeConstraints {
            $0.top.equalTo(ageGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        selectBoxTotalView.addSubview(selectBoxTitleLbl)
        selectBoxTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        selectBoxTotalView.addSubview(selectBoxArrow)
        selectBoxArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        selectBoxTotalView.addSubview(selectBoxTotalBtn)
        selectBoxTotalBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        userInfoMoreTotalView.addSubview(genderGuideLbl)
        genderGuideLbl.snp.makeConstraints {
            $0.top.equalTo(selectBoxTotalView.snp.bottom).offset(27)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        userInfoMoreTotalView.addSubview(genderTotalStackView)
        genderTotalStackView.snp.makeConstraints {
            $0.top.equalTo(genderGuideLbl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviTotalView.backClosure = {
            let isFirstStepViewHidden = self.userInfoStepTotalScrollView.isHidden
            
            guard isFirstStepViewHidden else {
                GlobalDefine.shared.mainNavi?.pop()
                return
            }
            
            self.userInfoStepTotalScrollView.isHidden = !isFirstStepViewHidden
            self.userInfoMoreTotalScrollView.isHidden = isFirstStepViewHidden
        }
        
        userInfoStepDismissKeyboardBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let bottom = keyboardHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            view.layoutIfNeeded()
            nextBtn.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-bottom)
            }
    
            let contentsInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottom / 2, right: 0.0)
            if userInfoStepTotalScrollView.isHidden {
                userInfoMoreTotalScrollView.contentInset = contentsInset
                userInfoMoreTotalScrollView.scrollIndicatorInsets = contentsInset
            } else {
                userInfoStepTotalScrollView.contentInset = contentsInset
                userInfoStepTotalScrollView.scrollIndicatorInsets = contentsInset
            }
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
        let contentsInset: UIEdgeInsets = .zero
        if userInfoStepTotalScrollView.isHidden {
            userInfoMoreTotalScrollView.contentInset = contentsInset
            userInfoMoreTotalScrollView.scrollIndicatorInsets = contentsInset
        } else {
            userInfoStepTotalScrollView.contentInset = contentsInset
            userInfoStepTotalScrollView.scrollIndicatorInsets = contentsInset
        }

        nextBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
        
    @objc private func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    internal func bind(reactor: SignUpReactor) {
        Observable.just(SignUpReactor.Action.getSignUpUserData)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.signUpUserData }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Login(.none))
            .drive(onNext: { [weak self] userData in
                guard let self = self else { return }
                
                if !userData.email.isEmpty {
                    self.loginInfoGuideLbl.text = "\(userData.loginType.value)에서 제공된 정보이며, 커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                    self.moreLoginInfoGuideLbl.text = "\(userData.loginType.value)에서 제공된 정보이며, 커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                } else {
                    self.loginInfoGuideLbl.text = "커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                    self.moreLoginInfoGuideLbl.text = "커뮤니티와 고객 센터 안내 등에서 사용됩니다."
                }
                                
                self.nickNameTf.text = userData.name
                self.emailTf.text = userData.email
                
                if let _otherInfo = userData.otherInfo {
                    self.emailTf.isEnabled = !_otherInfo.is_email_verified
                }
                                
                self.phoneTf.text = userData.displayPhoneNumber
                
                self.nickNameTf.isEnabled = userData.name.isEmpty
                self.phoneTf.isEnabled = userData.phoneNo.isEmpty
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isValidUserInfo }
            .asDriver(onErrorJustReturn: (false, false, false))
            .drive(onNext: { [weak self] validUserInfo in
                guard let self = self else { return }
                self.nickNameWarningLbl.isHidden = validUserInfo.isValidNickName
                self.emailWarningLbl.isHidden = validUserInfo.isValidEmail
                self.phoneWarningLbl.isHidden = validUserInfo.isValidPhoneNo
                
                guard validUserInfo.isValidNickName, validUserInfo.isValidEmail, validUserInfo.isValidPhoneNo else { return }
                let isFirstStepViewHidden = self.userInfoStepTotalScrollView.isHidden
                self.userInfoStepTotalScrollView.isHidden = !isFirstStepViewHidden
                self.userInfoMoreTotalScrollView.isHidden = isFirstStepViewHidden
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
                
        reactor.state.compactMap { $0.signUpUserData }
            .asDriver(onErrorJustReturn: Login(.none))
            .drive(onNext: { [weak self] userData in
                guard let self = self else { return }
                                                                
                switch userData.loginType {
                case .apple:
                    self.loginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                    
                case .kakao:
                    self.loginInfoGuideLbl.text = "카카오에서 제공된 정보이며, 추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                    
                default:
                    self.loginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                }
                                                                         
                self.selectBoxTitleLbl.text = userData.displayAgeRang
                
                for genderType in Login.Gender.allCases {
                    let genderView = self.createGenderView(type: genderType, reactor: reactor)
                    
                    genderView.rx.tap
                        .map { SignUpReactor.Action.setGenderType(genderType) }
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                    
                    self.genderTotalStackView.addArrangedSubview(genderView)
                }
                
                // 구현해야함
//                if let gender = user.gender, !gender.isEmpty {
//                    if gender.equals("남성") {
//                        radioMale.isSelected = true
//                    } else if gender.equals("여성") {
//                        radioFemale.isSelected = true
//                    } else {
//                        radioOther.isSelected = true
//                    }
//                    genderSelected = gender
//                }
                
            })
            .disposed(by: self.disposeBag)
        
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let isFirstStepViewHidden = self.userInfoStepTotalScrollView.isHidden
                guard !isFirstStepViewHidden else {
                    let viewcon = CarRegistrationViewController()
                    viewcon.reactor = reactor
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    return
                }
                
                Observable.just(SignUpReactor.Action.validUserInfoStep)
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
                                
        nickNameTf.rx.controlEvent([.editingChanged, .valueChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                Observable.just(SignUpReactor.Action.setNickname(self.nickNameTf.text ?? ""))
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
        emailTf.rx.controlEvent([.editingChanged, .valueChanged])
            .asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                Observable.just(SignUpReactor.Action.setEmail(self.emailTf.text ?? ""))
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
        selectBoxTotalBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                
                let rowVC = NewBottomSheetViewController()
                rowVC.items = Login.AgeType.allCases.map { $0.value }
                rowVC.headerTitleStr = "탈퇴 사유 선택"
                rowVC.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
                self.addChildViewController(rowVC)
                self.view.addSubview(rowVC.view)

                rowVC.selectedCompletion = { [weak self] index in
                    guard let self = self else { return }
                    reactor.selectedReasonIndex = Login.AgeType(value: index)
                                        
                    
                    self.selectBoxTitleLbl.text = rowVC.items[index]
                    self.nextBtn.isEnabled = true
                    rowVC.view.removeFromSuperview()
                    rowVC.removeFromParentViewController()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func createIconRequired() -> UILabel{
        return UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.backgroundPositive.color
            $0.textAlignment = .natural
            $0.text = "*"
            $0.numberOfLines = 1
            $0.sizeToFit()
        }
    }
    
    private func createGenderView(type: Login.Gender, reactor: SignUpReactor) -> UIButton {
        let view = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
        }
                        
        let genderSelectBtn = Radio().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
        }
        
        reactor.state.compactMap { $0.genderType }
            .asDriver(onErrorJustReturn: .man)
            .drive(onNext: { genderType in
                genderSelectBtn.isSelected = type == genderType
            })
            .disposed(by: self.disposeBag)
                                        
        view.addSubview(genderSelectBtn)
        genderSelectBtn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        let genderTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = type.value
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.contentPrimary.color
            $0.isUserInteractionEnabled = false
        }
        
        view.addSubview(genderTitleLbl)
        genderTitleLbl.snp.makeConstraints {
            $0.leading.equalTo(genderSelectBtn.snp.trailing).offset(8)
            $0.centerY.equalTo(genderSelectBtn.snp.centerY)
            $0.trailing.equalToSuperview()
        }
                                        
        return view
    }
}

extension NewSignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
            
            
            guard let _reactor = self.reactor else { return false }
            Observable.just(SignUpReactor.Action.setPhone(self.phoneTf.text ?? ""))
                .bind(to: _reactor.action)
                .disposed(by: self.disposeBag)
            
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

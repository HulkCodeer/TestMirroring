//
//  ModifyMyPageViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/07/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import AnyFormatKit

internal final class ModifyMyPageViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "정보 수정"
    }
    
    private lazy var saveTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "저장"
        $0.textColor = Colors.contentPrimary.color
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var saveBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        $0.addGestureRecognizer(gesture)
    }
            
    private lazy var profileImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconProfileEmpty.image
        $0.IBcornerRadius = 112 / 2
    }
    
    private lazy var profileEditTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBcornerRadius = 32/2
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var profileEditImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconEditMd.image
        $0.tintColor = Colors.contentPrimary.color
    }
    
    private lazy var nickNameGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "닉네임"
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
    
    private lazy var nickNameTf = SignUpTextField().then {
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
        let tempText = "이메일"
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
    
    private lazy var emailTf = SignUpTextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.returnKeyType = .default
        $0.keyboardType = .emailAddress
        $0.delegate = self
        $0.addLeftPadding(padding: 16)
        $0.isEnabled = false
    }
    
    private lazy var emailWarningLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
    }
    
    private lazy var phoneGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "전화번호"
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
    
    private lazy var phoneTf = SignUpTextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.keyboardType = .numberPad
        $0.returnKeyType = .default
        $0.delegate = self
        $0.addLeftPadding(padding: 16)
        $0.isEnabled = false
    }
    
    private lazy var phoneWarningLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.textAlignment = .natural
        $0.text = "전화번호를 정확하게 입력해주세요"
    }    
    
    private lazy var moreMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "EV Infra 내에서 사용될\n정보를 입력해주세요."
        $0.numberOfLines = 2
    }
    
    private lazy var ageGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        let tempText = "연령대"
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
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 26
        $0.backgroundColor = .white
    }
        
    
    // MARK: VARIABLE
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(saveTitleLbl)
        saveTitleLbl.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(naviTotalView.snp.centerY)
            $0.height.equalTo(20)
        }
        
        self.contentView.addSubview(saveBtn)
        saveBtn.snp.makeConstraints {
            $0.center.equalTo(saveTitleLbl.snp.center)
            $0.width.height.equalTo(44)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.bottom.equalToSuperview()
        }

        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(screenWidth - 32)
            $0.center.equalToSuperview()
        }
                                        
        totalView.addSubview(profileImgView)
        profileImgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(112)
        }
        
        totalView.addSubview(profileEditTotalView)
        profileEditTotalView.snp.makeConstraints {
            $0.trailing.equalTo(profileImgView.snp.trailing).offset(-4)
            $0.bottom.equalTo(profileImgView.snp.bottom).offset(-4)
            $0.width.height.equalTo(32)
        }

        profileEditTotalView.addSubview(profileEditImgView)
        profileEditImgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        totalView.addSubview(nickNameGuideLbl)
        nickNameGuideLbl.snp.makeConstraints {
            $0.top.equalTo(profileImgView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }

        totalView.addSubview(nickNameTf)
        nickNameTf.snp.makeConstraints {
            $0.top.equalTo(nickNameGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        totalView.addSubview(emailGuideLbl)
        emailGuideLbl.snp.makeConstraints {
            $0.top.equalTo(nickNameTf.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }

        totalView.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        totalView.addSubview(phoneGuideLbl)
        phoneGuideLbl.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        totalView.addSubview(phoneTf)
        phoneTf.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        totalView.addSubview(ageGuideLbl)
        ageGuideLbl.snp.makeConstraints {
            $0.top.equalTo(phoneTf.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        totalView.addSubview(selectBoxTotalView)
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

        totalView.addSubview(genderGuideLbl)
        genderGuideLbl.snp.makeConstraints {
            $0.top.equalTo(selectBoxTotalView.snp.bottom).offset(32)
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        totalView.addSubview(genderTotalStackView)
        genderTotalStackView.snp.makeConstraints {
            $0.top.equalTo(genderGuideLbl.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-30)
        }
        
        profileImgView.sd_setImage(with: URL(string: "\(Const.EI_IMG_SERVER)\(MemberManager.shared.profileImage)"), placeholderImage: Icons.iconProfileEmpty.image)
        
    }
        
    func bind(reactor: SignUpReactor) {
        for genderType in Login.Gender.allCases {
            let genderView = self.createGenderView(type: genderType, reactor: reactor)
            genderView.rx.tap
                .map { SignUpReactor.Action.setGenderType(genderType) }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
            self.genderTotalStackView.addArrangedSubview(genderView)
        }
    }
    
    @objc private func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func createGenderView(type: Login.Gender, reactor: SignUpReactor) -> UIButton {
        let view = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
        }
                        
        let genderSelectBtn = Radio().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.isSelected = false
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


extension ModifyMyPageViewController: UITextFieldDelegate {
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
//            Observable.just(SignUpReactor.Action.setPhone(self.phoneTf.text ?? ""))
//                .bind(to: _reactor.action)
//                .disposed(by: self.disposeBag)
            
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

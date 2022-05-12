//
//  MembershipReJoinViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal final class MembershipReissuanceViewController: UIViewController {
    
    // MARK: UI
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var guideLblTop = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "재발급 신청 전, 본인 확인을 위해"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var guideLblBottom = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "결제 비밀번호를 입력해주세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var passwordTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "비밀번호"
    }
    
    private lazy var passwordInputTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.IBcornerRadius = 디자인가이드에 이미지로 되어있어서 알 수가 없음
        $0.keyboardType = .numberPad
        $0.delegate = self
    }
    
    private lazy var findPasswordGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
        $0.textAlignment = .natural
        let text = "비밀번호가 기억나지 않으신가요?"
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        $0.attributedText = attributedText
    }
    
    private lazy var nextBtn = NextButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음", for: .normal)
        $0.isEnabled = false
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "재발급 신청")
        
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(0)
            let safeAreaBottonInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            $0.height.equalTo(60 + safeAreaBottonInset)
        }
        
        view.addSubview(findPasswordGuideLbl)
        findPasswordGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top).offset(-16)
        }
        
        view.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.bottom.equalTo(nextBtn.snp.top)
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        totalView.addSubview(guideLblTop)
        guideLblTop.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        totalView.addSubview(guideLblBottom)
        guideLblBottom.snp.makeConstraints {
            $0.top.equalTo(guideLblTop.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        
        totalView.addSubview(passwordTitleLbl)
        passwordTitleLbl.snp.makeConstraints {
            $0.top.equalTo(guideLblBottom.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        
        totalView.addSubview(passwordInputTf)
        passwordInputTf.snp.makeConstraints {
            $0.top.equalTo(passwordTitleLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        view.layoutIfNeeded()
        nextBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            view.layoutIfNeeded()
            nextBtn.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
        nextBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
}

extension MembershipReissuanceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        
        if string.isEmpty && text.count == 1 {
            nextBtn.isEnabled = false
        } else {
            nextBtn.isEnabled = true
        }
        
        return true
    }
}

internal final class NextButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            isEnabled ? setTitleColor(UIColor(named: "nt-9"), for: .normal) : setTitleColor(UIColor(named: "content-disabled"), for: .disabled)
            
            backgroundColor = isEnabled ? UIColor(named: "gr-5") : UIColor(named: "background-disabled")
        }
    }
}

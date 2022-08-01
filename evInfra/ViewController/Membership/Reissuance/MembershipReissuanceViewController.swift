//
//  MembershipReJoinViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import SwiftyJSON
import ReactorKit

internal final class MembershipReissuanceViewController: BaseViewController, StoryboardView {
    
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
        $0.keyboardType = .numberPad
        $0.isSecureTextEntry = true
        $0.delegate = self
        $0.borderColor = UIColor(named: "nt-2")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
    }
    
    private lazy var clearTxtImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icon_close_md")
        $0.tintColor = UIColor(named: "content-primary")
        $0.isHidden = true
    }
    
    private lazy var clearTxtBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var moveFindPasswordBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var nextBtn = NextButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
    }
    
    private lazy var negativeMessageLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor(named: "content-negative")
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    // MARK: VARIABLE
        
    internal var delegate: MembershipReissuanceInfoDelegate?
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(0)
            let safeAreaBottonInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            $0.height.equalTo(60 + safeAreaBottonInset)
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
            $0.height.equalTo(48)
        }
        
        totalView.addSubview(clearTxtImgView)
        clearTxtImgView.snp.makeConstraints {
            $0.trailing.equalTo(passwordInputTf.snp.trailing).offset(-16)
            $0.centerY.equalTo(passwordInputTf.snp.centerY)
            $0.width.height.equalTo(24)
        }
        
        totalView.addSubview(clearTxtBtn)
        clearTxtBtn.snp.makeConstraints {
            $0.center.equalTo(clearTxtImgView.snp.center)
            $0.width.height.equalTo(44)
        }
        
        totalView.addSubview(negativeMessageLbl)
        negativeMessageLbl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(passwordInputTf.snp.bottom).offset(4)
            $0.height.equalTo(16)
        }
        
        totalView.addSubview(findPasswordGuideLbl)
        findPasswordGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        totalView.addSubview(moveFindPasswordBtn)
        moveFindPasswordBtn.snp.makeConstraints {
            $0.leading.equalTo(findPasswordGuideLbl.snp.leading)
            $0.trailing.equalTo(findPasswordGuideLbl.snp.trailing)
            $0.center.equalTo(findPasswordGuideLbl.snp.center)
            $0.height.equalTo(44)
        }
        
        passwordInputTf.addLeftPadding(padding: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "재발급 신청 화면"
        clearTxtBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.passwordInputTf.text = ""
                self.setEnableComponent(isEnabled: false)
            })
            .disposed(by: self.disposebag)
        
        passwordInputTf.rx.text
            .asDriver()
            .skip(1)
            .drive(onNext: { [weak self] text in
                guard let self = self else { return }
                            
                let str = text ?? ""
                let tfStr = self.passwordInputTf.text ?? ""
                let isEnabled = str.count + tfStr.count >= 1
                
                self.setEnableComponent(isEnabled: isEnabled)
            })
            .disposed(by: self.disposebag)
        
        moveFindPasswordBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let viewcon = FindPasswordViewController()
                self.navigationController?.push(viewController: viewcon)
            })
            .disposed(by: self.disposebag)
    }
    
    internal func bind(reactor: MembershipReissuanceReactor) {
        nextBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .do { _ in self.view.endEditing(true) }
            .map { _ in Reactor.Action.getCheckPassword(self.passwordInputTf.text ?? "") }
            .bind(to: reactor.action)
            .disposed(by: self.disposebag)
        
        reactor.state.compactMap { $0.addressInfo }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] addressInfo in
                guard let self = self else { return }
                switch addressInfo.code {
                case 1000:
                    let infoReactor = MembershipReissuanceInfoReactor(provider: RestApi())
                    infoReactor.cardNo = reactor.cardNo
                    let viewcon = MembershipReissuanceInfoViewController()
                    viewcon.reactor = infoReactor
                    let reissuanceModel = ReissuanceModel(cardNo: reactor.cardNo, mbPw: self.passwordInputTf.text ?? "", mbName: addressInfo.info.mbName, phoneNo: addressInfo.info.phoneNo, zipCode: addressInfo.info.zipCode, address: addressInfo.info.addr, addressDetail: addressInfo.info.addrDetail)
                    viewcon.delegate = self.delegate
                    viewcon.showInfo(model: reissuanceModel)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)

                case 1103:
                    self.negativeMessageLbl.text = addressInfo.msg
                    self.negativeMessageLbl.isHidden = false
                    self.passwordInputTf.borderColor = UIColor(named: "content-negative")

                default: break
                }
            }
            .disposed(by: self.disposebag)
                
    }
    
    private func setEnableComponent(isEnabled: Bool) {
        self.clearTxtBtn.isHidden = !isEnabled
        self.clearTxtImgView.isHidden = !isEnabled
        self.nextBtn.isEnabled = isEnabled
        self.passwordInputTf.borderColor = isEnabled ? UIColor(named: "nt-9") : UIColor(named: "nt-2")
        self.negativeMessageLbl.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareActionBar(with: "재발급 신청")
        
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
        guard !string.isEmpty else { return true }
        let text = textField.text ?? ""
        return text.count < 4
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


extension UITextField {
    func addLeftPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}

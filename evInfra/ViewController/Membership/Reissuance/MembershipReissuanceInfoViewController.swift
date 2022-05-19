//
//  MembershipCardReissuanceViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Material
import RxSwift
import RxCocoa
import SwiftyJSON

protocol MembershipReissuanceInfoDelegate {
    func reissuanceComplete()
}

internal final class MembershipReissuanceInfoViewController: BaseViewController {
    
    // MARK: UI
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var guideStrTopLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "카드 배송 정보를 입력해주세요"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var guideStrBottomLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "입력된 정보로 카드 우편 배송되어요! 📮"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var nameTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "수령인 이름"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var nameTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
    }
    
    private lazy var phoneTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "연락처"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var phoneTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.keyboardType = .numberPad
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.delegate = self
    }
    
    private lazy var addressTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "수령 주소"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var addressStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    private lazy var moveSearchAddressBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("우편번호 검색", for: .normal)
        $0.setTitleColor(UIColor(named: "content-secondary"), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = UIColor(named: "background-secondary")
        $0.IBcornerRadius = 6
    }
    
    private lazy var zipCodeTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.keyboardType = .numberPad
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "우편번호"
        $0.isEnabled = false
    }
    
    private lazy var addressTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "배송 주소"
        $0.isEnabled = false
    }
    
    private lazy var detailAddressTf = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "상세 주소"
    }
    
    private lazy var completeBtn = NextButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("재발급 신청 완료", for: .normal)
        $0.setTitleColor(UIColor(named: "content-primary"), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
    }
    
    // MARK: VARIABLE
        
    internal var delegate: MembershipReissuanceInfoDelegate?
    
    private var disposeBag = DisposeBag()
    private var reissuanceModel = ReissuanceModel()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
                
        let screenWidth = UIScreen.main.bounds.width
        let scrollViewWidth = screenWidth - 32 // 스크린 넓이 - 양쪽마진
        let halfWidth = (screenWidth / 2) - 32 // 스크린 넓이 / 2 - 양쪽마진
        let tfHeight = 40
                
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(0)
            let safeAreaBottonInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            $0.height.equalTo(60 + safeAreaBottonInset)
        }
        
        view.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(completeBtn.snp.top)
            $0.width.equalTo(screenWidth)
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.equalTo(24)
            $0.width.equalTo(scrollViewWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        totalView.addSubview(guideStrTopLbl)
        guideStrTopLbl.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        totalView.addSubview(guideStrBottomLbl)
        guideStrBottomLbl.snp.makeConstraints {
            $0.top.equalTo(guideStrTopLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        
        totalView.addSubview(nameTitleLbl)
        nameTitleLbl.snp.makeConstraints {
            $0.top.equalTo(guideStrBottomLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        
        totalView.addSubview(nameTf)
        nameTf.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(nameTitleLbl.snp.bottom).offset(8)
            $0.width.equalTo(halfWidth)
            $0.height.equalTo(tfHeight)
        }
        
        totalView.addSubview(phoneTitleLbl)
        phoneTitleLbl.snp.makeConstraints {
            $0.top.equalTo(nameTf.snp.bottom).offset(32)
            $0.height.equalTo(20)
            $0.leading.trailing.equalToSuperview()
        }

        totalView.addSubview(phoneTf)
        phoneTf.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(phoneTitleLbl.snp.bottom).offset(8)
            $0.height.equalTo(tfHeight)
        }

        totalView.addSubview(addressTitleLbl)
        addressTitleLbl.snp.makeConstraints {
            $0.top.equalTo(phoneTf.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }

        totalView.addSubview(addressStackView)
        addressStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(addressTitleLbl.snp.bottom).offset(8)
            $0.height.equalTo(tfHeight)
        }

        addressStackView.addArrangedSubview(zipCodeTf)
        addressStackView.addArrangedSubview(moveSearchAddressBtn)
                
        totalView.addSubview(addressTf)
        addressTf.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(addressStackView.snp.bottom).offset(8)
            $0.height.equalTo(tfHeight)
        }

        totalView.addSubview(detailAddressTf)
        detailAddressTf.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(addressTf.snp.bottom).offset(8)
            $0.height.equalTo(tfHeight)
            $0.bottom.greaterThanOrEqualTo(0)
        }
        
        nameTf.addLeftPadding(padding: 12)
        phoneTf.addLeftPadding(padding: 12)
        zipCodeTf.addLeftPadding(padding: 12)
        addressTf.addLeftPadding(padding: 12)
        detailAddressTf.addLeftPadding(padding: 12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moveSearchAddressBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
                let saVC = mapStoryboard.instantiateViewController(withIdentifier: "SearchAddressViewController") as! SearchAddressViewController
                saVC.searchAddressDelegate = self
                self.navigationController?.push(viewController: saVC)
            })
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(nameTf.rx.text,
                         phoneTf.rx.text,
                         zipCodeTf.rx.text,
                         addressTf.rx.text,
                         detailAddressTf.rx.text)
            .map { [weak self] name, phone, zipCode, address, detailAddress in
                guard let self = self,
                      let _nameText = name,
                      let _phoneText = phone,
                      let _zipCodeText = zipCode,
                      let _addressText = address,
                      let _detailAddressText = detailAddress else { return false }
                
                self.reissuanceModel.mbName = _nameText
                self.reissuanceModel.phoneNo = _phoneText
                self.reissuanceModel.zipCode = _zipCodeText
                self.reissuanceModel.address = _addressText
                self.reissuanceModel.addressDetail = _detailAddressText
                                                
                return !_nameText.isEmpty && !_phoneText.isEmpty && !_zipCodeText.isEmpty && !_addressText.isEmpty && !_detailAddressText.isEmpty
            }
            .bind(to: completeBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
            
        
        completeBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                Server.postReissueMembershipCard(model: self.reissuanceModel) { (isSuccess, value) in
                    let json = JSON(value)
                    printLog(out: "jsonData : \(json)")
                    if isSuccess {
                        switch json["code"].intValue {
                        case 1000:
                            self.delegate?.reissuanceComplete()
                            self.backButtonTapped() 
                        default: break
                        }
                    }
                }
                
            })
            .disposed(by: self.disposeBag)
        
//        if contactText.count > 9, contactText.count < 12, GlobalFunctionSwift.matches(for: "^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$", in: contactText) != 0 {
//            self.delegate?.updatePhoneNumber(phoneNumber: contactText)
//            self.button02Act?()
//            self.close()
//        } else {
//            self.openAlert(alertMessage: "올바르지 않은 연락처입니다.\n다시 확인해 주세요.")
//        }
            
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
        
        completeBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            view.layoutIfNeeded()
            completeBtn.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
        completeBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    @objc
    override func backButtonTapped() {
        guard let _navi = navigationController else { return }
        for vc in _navi.viewControllers {
            if let _vc = vc as? MembershipCardViewController {
                _ = navigationController?.popToViewController(_vc, animated: true)
                return
            }
        }
    }
    
    internal func showInfo(model: ReissuanceModel) {
        reissuanceModel = model
        
        nameTf.text = reissuanceModel.mbName
        phoneTf.text = reissuanceModel.phoneNo
        zipCodeTf.text = reissuanceModel.zipCode
        addressTf.text = reissuanceModel.address
        detailAddressTf.text = reissuanceModel.addressDetail                
    }
}

extension MembershipReissuanceInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.phoneTf:
            let bottomOffset = CGPoint(x: 0, y: totalScrollView.contentSize.height - totalScrollView.bounds.size.height)
            totalScrollView.setContentOffset(bottomOffset, animated: true)
            
        default: break
        }
    }
}

extension MembershipReissuanceInfoViewController: SearchAddressViewDelegate {
    func recieveAddressInfo(zonecode: String, fullRoadAddr: String) {
        zipCodeTf.text = zonecode
        addressTf.text = fullRoadAddr
    }
}

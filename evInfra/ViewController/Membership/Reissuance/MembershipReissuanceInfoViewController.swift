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
import ReactorKit
import UIKit

protocol MembershipReissuanceInfoDelegate {
    func reissuanceComplete()
}

internal final class MembershipReissuanceInfoViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "재발급 신청"
    }
    
    private lazy var totalScrollView = UIScrollView().then {        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView()
    private lazy var guideStrTopLbl = UILabel().then {        
        $0.text = "EV Pay카드 배송 정보를 입력해주세요"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var guideStrBottomLbl = UILabel().then {
        
        $0.text = "입력된 정보로 카드 우편 배송되어요! 📮"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var nameTitleLbl = UILabel().then {
        
        $0.text = "수령인 이름"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var nameTf = UITextField().then {
        
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.returnKeyType = .next
    }
    
    private lazy var phoneTitleLbl = UILabel().then {
        
        $0.text = "연락처"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var phoneTf = UITextField().then {
        
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.keyboardType = .numberPad
        $0.returnKeyType = .next
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.delegate = self
    }
    
    private lazy var addressTitleLbl = UILabel().then {
        
        $0.text = "수령 주소"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
    }
    
    private lazy var addressStackView = UIStackView().then {
        
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    private lazy var totalSearchAddressBtn = UIButton()
    
    private lazy var moveSearchAddressBtn = UIButton().then {
        
        $0.setTitle("우편번호 검색", for: .normal)
        $0.setTitle("우편번호 검색", for: .disabled)
        $0.setTitleColor(UIColor(named: "content-secondary"), for: .normal)
        $0.setTitleColor(UIColor(named: "content-secondary"), for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = UIColor(named: "background-secondary")
        $0.IBcornerRadius = 6
        $0.isEnabled = false
    }
    
    private lazy var zipCodeTf = UITextField().then {
        
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
        
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "배송 주소"
        $0.isEnabled = false
    }
    
    private lazy var detailAddressTf = UITextField().then {
        
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-tertiary")
        $0.IBborderColor = UIColor(named: "border-opaque")
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.placeholder = "상세 주소"
    }
    
    private lazy var completeBtn = NextButton().then {
        $0.setTitle("재발급 신청 완료", for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
    }
    
    // MARK: VARIABLE
        
    internal var delegate: MembershipReissuanceInfoDelegate?
        
    private var reissuanceModel = ReissuanceModel()
    
    // MARK: SYSTEM FUNC
            
    override func loadView() {
        super.loadView()
                        
        let screenWidth = UIScreen.main.bounds.width
        let scrollViewWidth = screenWidth - 32 // 스크린 넓이 - 양쪽마진
        let halfWidth = (screenWidth / 2) - 32 // 스크린 넓이 / 2 - 양쪽마진
        let tfHeight = 40
        
        self.contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
                
        self.contentView.addSubview(completeBtn)
        completeBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(0)
            let safeAreaBottonInset = UIWindow.key?.safeAreaInsets.bottom ?? 0
            $0.height.equalTo(60 + safeAreaBottonInset)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(commonNaviView.snp.bottom)
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
        
        totalView.addSubview(totalSearchAddressBtn)
        totalSearchAddressBtn.snp.makeConstraints {
            $0.edges.equalTo(addressStackView)
        }
                
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
    
    internal func bind(reactor: MembershipReissuanceInfoReactor) {
        
        completeBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let popupModel = PopupModel(title: "EV Pay카드 배송 정보 확인",
                                            message: "수령인 : \(self.nameTf.text ?? "")\n주소 : \(self.addressTf.text ?? "") \(self.detailAddressTf.text ?? "")\n\n위 주소로 EV Pay카드를 발급하시겠습니까?",
                                            confirmBtnTitle: "네", cancelBtnTitle: "아니오",
                                            confirmBtnAction: { [weak self] in
                    guard let self = self else { return }
                    Observable.just(Reactor.Action.setReissuance(self.reissuanceModel))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                }, textAlignment: .left)
                    
                let popup = ConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
            })
            .disposed(by: self.disposeBag)
            
        
        reactor.state.compactMap { $0.serverResult }
            .asDriver(onErrorJustReturn: ServerResult(JSON.null))
            .drive(onNext: { [weak self] serverCode in
                guard let self = self else { return }
                                                
                switch serverCode.code {
                case 1000:
                    self.delegate?.reissuanceComplete()
                    self.actionBack()
                default: break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        self.view.addGestureRecognizer(tap)
        
        self.commonNaviView.backClosure = { [weak self] in
            guard let self = self else { return }
            self.actionBack()
        }
        
        totalSearchAddressBtn.rx.tap
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        completeBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            view.layoutIfNeeded()
            completeBtn.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
            
            let contentsInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight / 2, right: 0)
            totalScrollView.contentInset = contentsInset
            totalScrollView.scrollIndicatorInsets = contentsInset
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
        let contentsInset: UIEdgeInsets = .zero
        totalScrollView.contentInset = contentsInset
        totalScrollView.scrollIndicatorInsets = contentsInset
        
        completeBtn.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(0)
        }
    }
            
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    internal func showInfo(model: ReissuanceModel) {
        reissuanceModel = model
        
        nameTf.text = reissuanceModel.mbName
        phoneTf.text = reissuanceModel.phoneNo
        zipCodeTf.text = reissuanceModel.zipCode
        addressTf.text = reissuanceModel.address
        detailAddressTf.text = reissuanceModel.addressDetail
        
        completeBtn.isEnabled = !reissuanceModel.mbName.isEmpty && !reissuanceModel.phoneNo.isEmpty && !reissuanceModel.zipCode.isEmpty && !reissuanceModel.address.isEmpty && !reissuanceModel.addressDetail.isEmpty
    }
    
    private func actionBack() {
        guard let _navi = GlobalDefine.shared.mainNavi else { return }
        for vc in _navi.viewControllers {
            if let _vc = vc as? MembershipCardViewController {
                _ = _navi.popToViewController(_vc, animated: true)
                return
            }
        }
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
        
        zipCodeTf.sendActions(for: .valueChanged)
        addressTf.sendActions(for: .valueChanged)
    }
}

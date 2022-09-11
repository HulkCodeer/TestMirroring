//
//  MembershipIssuanceViewController.swift
//  evInfra
//
//  Created by SH on 2020/10/06.
//  Copyright © 2020 soft-berry. All rights reserved.
//


import SwiftyJSON
import Material
import UIKit
import M13Checkbox

class MembershipIssuanceViewController: UIViewController,
    MembershipTermViewDelegate,
    SearchAddressViewDelegate, MyPayRegisterViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewSeperator: UIView!
    @IBOutlet var tfPassword: HSUnderLineTextField!
    @IBOutlet var tfConfirmPassword: HSUnderLineTextField!
    @IBOutlet var tfCarNo: HSUnderLineTextField!
    @IBOutlet var tfName: HSUnderLineTextField!
    @IBOutlet var tfPhoneNum: HSUnderLineTextField!
    @IBOutlet var btnZipSearch: UIButton!
    @IBOutlet var tfZipCode: HSUnderLineTextField!
    @IBOutlet var tfAddress: HSUnderLineTextField!
    @IBOutlet var tfAddressDetail: HSUnderLineTextField!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var labelAgreeTerm: UILabel!
    @IBOutlet var checkAgree: M13Checkbox!
    
    var membershipTermView : MembershipTermView? = nil
    @IBOutlet var scrollview_bottom: NSLayoutConstraint!
    
    @IBAction func onClickZipSearchBtn(_ sender: Any) {
        searchZipCode()
    }
    
    @IBAction func onValueChanged(_ sender: Any) {
        if checkAgree.checkState == .checked {
            self.btnNext.isEnabled = true
        } else {
            self.btnNext.isEnabled = false
        }
    }
    @IBAction func onClickNextBtn(_ sender: Any) {
        var issuanceParam = [String: Any]()
        do {
            issuanceParam["mb_name"] = try tfName.validatedText(validationType: .membername)
            issuanceParam["mb_pw"] = try tfPassword.validatedText(validationType: .password)
            _ = try tfConfirmPassword.validatedText(validationType: .repassword(password: tfPassword.text ?? "0000"))
            issuanceParam["phone_no"] = try tfPhoneNum.validatedText(validationType: .phonenumber)
            issuanceParam["car_no"] = try tfCarNo.validatedText(validationType: .carnumber)
            issuanceParam["zip_code"] = try tfZipCode.validatedText(validationType: .zipcode)
            issuanceParam["addr_detail"] = try tfAddressDetail.validatedText(validationType: .address)
            issuanceParam["addr"] = tfAddress.text
            issuanceParam["mb_id"] = MemberManager.shared.mbId
            verifyMemgberInfo(params: issuanceParam)
            
            self.btnNext.isEnabled = false
        } catch (let error) {
            showValidateFailMsg(msg: (error as! ValidationError).message)
        }
    }
    
    var payRegistResult: JSON?
    var memberData: [String: Any]? = nil
    var isConfirmTerm = false
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let result = payRegistResult {
            updateAfterPayRegist(json: result)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        btnNext.layer.cornerRadius = 4
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initView() {
        viewSeperator.backgroundColor = UIColor(hex: "#B2B2B2")
        
        let checkboxColor = UIColor(named: "content-primary")
        checkAgree.boxType = .square
        checkAgree.checkState = .unchecked
        checkAgree.tintColor = checkboxColor
        
        let tap_touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tap_touch)
        
        let text = labelAgreeTerm.text
        let textRange = NSRange(location: 0, length: (text?.count)!)
        let attributedText = NSMutableAttributedString(string: text!)
        attributedText.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        labelAgreeTerm.attributedText = attributedText
        
        let term_touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTermTouch(recognizer:)))
        labelAgreeTerm.addGestureRecognizer(term_touch)
        
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        
        btnNext.isEnabled = false
        
        btnZipSearch.layer.borderColor = UIColor(hex: "#B2B2B2").cgColor
        btnZipSearch.layer.borderWidth = 2
        btnZipSearch.layer.cornerRadius = 4
    
    }
    
    func updateAfterPayRegist(json: JSON) {
        if (json["pay_code"].intValue == PaymentCard.PAY_REGISTER_SUCCESS) {
            if let params = self.memberData {
                applyMembershipCard(params: params)
                logEvent(with: .completePaymentCard)
            } else {
                Snackbar().show(message: "회원정보를 다시 입력해 주세요.")
                self.btnNext.isEnabled = true
            }
        } else {
            if json["resultMsg"].stringValue.isEmpty {
                Snackbar().show(message: "카드 등록을 실패하였습니다. 다시 시도해 주세요.")
            } else {
                Snackbar().show(message: json["resultMsg"].stringValue)
            }
            self.btnNext.isEnabled = true
        }
    }
    
    func moveToMyPayRegist() {
        let mainStoryboard = UIStoryboard(name : "Member", bundle: nil)
        let payRegistVC = mainStoryboard.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
        payRegistVC.myPayRegisterViewDelegate = self
        navigationController?.push(viewController: payRegistVC)
    }
    
    func checkPaymentCardStatus() {
        Server.getPayRegisterStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                switch payCode {
                    case PaymentCard.PAY_NO_USER, PaymentCard.PAY_NO_CARD_USER:
                        self.moveToMyPayRegist()

                    case PaymentCard.PAY_DEBTOR_USER, PaymentCard.PAY_NO_VERIFY_USER, PaymentCard.PAY_DELETE_FAIL_USER:
                        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
                            self.navigationController?.pop()
                        })
                        var actions = Array<UIAlertAction>()
                        actions.append(ok)
                        UIAlertController.showAlert(title: "알림", message: json["ResultMsg"].stringValue, actions: actions)

                    case PaymentCard.PAY_FINE_USER:
                        Server.getPayRegisterInfo { (isSuccess, value) in
                            if isSuccess {
                                if let data = self.memberData {
                                    self.applyMembershipCard(params: data)
                                } else {
                                    Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                                }
                            } else {
                                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                            }
                        }
                    
                    case PaymentCard.PAY_REGISTER_FAIL_PG:
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")

                    default:
                        break
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }

    
    func verifyMemgberInfo(params: [String : Any]) {
        guard let name = params["mb_name"],  let address = params["addr"], let detail_address = params["addr_detail"] else {
            Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
            self.btnNext.isEnabled = true
            return
        }
        
        self.memberData = params
        var actions = Array<UIAlertAction>()
        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
            self.checkPaymentCardStatus()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.btnNext.isEnabled = true
            self.dismiss(animated: true, completion: nil)
        })
        actions.append(ok)
        actions.append(cancel)
        let msg = "\(name)\n\(address)\n\(detail_address)\n위 주소로 회원카드를 발급하시겠습니까?"
        UIAlertController.showAlert(title: "알림", message: msg, actions: actions)
    }
    
    func applyMembershipCard(params: [String : Any]) {
        Server.registerMembershipCard(values: params, completion: {(isSuccess, value) in
            if isSuccess {
                let json = JSON(value)                
                let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in                    
                    UserDefault().saveBool(key: UserDefault.Key.IS_HIDDEN_DELEVERY_COMPLETE_TOOLTIP, value: false)
                    MemberManager.shared.hasMembership = true
                    MemberManager.shared.hasPayment = true
                    
                    let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
                    guard let _mainNavi = GlobalDefine.shared.mainNavi else { return }
                    for vc in _mainNavi.viewControllers {
                        if let _vc = vc as? NewPaymentQRScanViewController {
                            _ = _mainNavi.popToViewController(_vc, animated: true)
                            return
                        }
                    }
                                        
                    let viewcon = mbsStoryboard.instantiateViewController(ofType: MembershipCardViewController.self)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                })
                var actions = Array<UIAlertAction>()
                actions.append(ok)
                switch json["code"].stringValue {
                    case "1000":
                        let message = "회원카드는 일반우편으로 발송되며 즉시 충전을 원하실 경우 마이페이지 > 회원카드 관리에 있는 카드번호를 충전기에 입력하시면 됩니다.\n감사합니다.(한전 이외의 충전사업자는 익일 반영됩니다)"
                        UIAlertController.showAlert(title: "알림", message: message, actions: actions)
                        self.logEvent(with: .completeApplyEVICard)
                    default:
                        UIAlertController.showAlert(title: "알림", message: json["msg"].stringValue, actions: actions)
                }
            }
        })
    }
    
    func recieveAddressInfo(zonecode: String, fullRoadAddr: String) {
        tfZipCode.text = zonecode
        tfAddress.text = fullRoadAddr
    }
    
    func searchZipCode() {
        let mainStoryboard = UIStoryboard(name : "Map", bundle: nil)
        let saVC = mainStoryboard.instantiateViewController(ofType: SearchAddressViewController.self)
        saVC.searchAddressDelegate = self
        
        navigationController?.push(viewController: saVC)
    }
    
    func showValidateFailMsg(msg: String) {
        Snackbar().show(message: msg)
    }
    
    func finishRegisterResult(json: JSON) {
        payRegistResult = json
    }
    
    func onCancelRegister() {
        Snackbar().show(message: "결제 수단 등록이 취소되었습니다. 다시 시도해주세요.")
    }
    
    func confirmMembershipTerm() {
        if let msView = self.membershipTermView {
            isConfirmTerm = true
            msView.removeFromSuperview()
            checkAgree.checkState = .checked
            self.btnNext.isEnabled = true
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "EV Infra 멤버쉽 카드 신청"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    fileprivate func handleTermTouch(recognizer: UITapGestureRecognizer) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsVC = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsVC.tabIndex = .MembershipTerms
        navigationController?.push(viewController: termsVC)
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        var keyboardHeight: CGFloat = 0
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height  + CGFloat(16.0)
        }
        self.scrollview_bottom.constant = keyboardHeight
        self.scrollView.isScrollEnabled = true
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollview_bottom.constant = 0
        self.scrollView.isScrollEnabled = true
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }
}

extension MembershipIssuanceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= 4 //max length is 4
    }
    
}

// MARK: - Amplitude Logging 이벤트
extension MembershipIssuanceViewController {
    private func logEvent(with event: EventType.PaymentEvent) {
        switch event {
        case .completeApplyEVICard:
            AmplitudeManager.shared.logEvent(type: .payment(event))
        case .completePaymentCard:
            AmplitudeManager.shared.logEvent(type: .payment(event))
        default: break
        }
    }
}

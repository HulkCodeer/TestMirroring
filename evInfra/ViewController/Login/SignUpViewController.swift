//
//  SignUpViewController.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import AnyFormatKit
import DLRadioButton
import MaterialComponents.MaterialBottomSheet
import RxSwift

protocol SignUpViewControllerDelegate {
    func successSignUp()
}
internal final class SignUpViewController: UIViewController {
    
    // MARK: UI
    
    @IBOutlet weak var viewSignUpInfo_1: UIView!
    @IBOutlet weak var viewSignUpInfo_2: UIView!
    
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var viewAge: UIView!
    @IBOutlet weak var lbAge: UILabel!
    
    @IBOutlet weak var lbWarnNickname: UILabel!
    @IBOutlet weak var lbWarnEmail: UILabel!
    @IBOutlet weak var lbWarnPhone: UILabel!
    @IBOutlet weak var lbWarnAge: UILabel!
    @IBOutlet weak var lbWarnGender: UILabel!
    @IBOutlet weak var radioMale: DLRadioButton!
    @IBOutlet weak var radioFemale: DLRadioButton!
    @IBOutlet weak var radioOther: DLRadioButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet var ivNext: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollviewBottomConstraints: NSLayoutConstraint!
    @IBOutlet var loginInfoGuideLbl: UILabel!
    @IBOutlet var step2LoginInfoGuideLbl: UILabel!
    
    // MARK: VARIABLE
    
    internal var delegate: SignUpViewControllerDelegate?
    internal var user: Login?
    
    private let ageList: Array<String> = ["20대", "30대", "40대", "50대 이상", "선택안함"]
    private var page = 0
    private var ageIndex = 0
    private var genderSelected: String?
    private var profileImgName = ""
    private let disposebag = DisposeBag()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareView()
        createProfileImage()
    }
    
    override func viewWillLayoutSubviews() {
        viewAge.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        viewAge.layer.borderWidth = 1
        viewAge.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func prepareView() {
        if let _user = self.user, _user.email != nil {
            loginInfoGuideLbl.text = "\(_user.loginType.value)에서 제공된 정보이며, 커뮤니티와 고객 센터 안내 등에서 사용됩니다."
        } else {
            loginInfoGuideLbl.text = "커뮤니티와 고객 센터 안내 등에서 사용됩니다."
        }
        
        if let _user = self.user {
            switch _user.loginType {
            case .apple:
                step2LoginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                
            case .kakao:
                step2LoginInfoGuideLbl.text = "카카오에서 제공된 정보이며, 추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
                
            default: step2LoginInfoGuideLbl.text = "추후 해당 정보를 기반한 맞춤형 정보를 제공할 예정입니다."
            }
        }
        
        tfNickname.delegate = self
        tfEmail.delegate = self
        tfPhone.delegate = self
        
        tfEmail.keyboardType = .emailAddress
        tfPhone.keyboardType = .numberPad
        
        if let user = self.user {
            tfNickname.text = user.name
            tfEmail.text = user.email
            
            if let other = user.otherInfo, other.is_email_verified == true{
                tfEmail.isEnabled = false
            }
            
//            var phoneNo = user.phoneNo
//            if phoneNo != nil, phoneNo!.starts(with: "+82") {
//                phoneNo = phoneNo?.replaceAll(of: "^[^1]*1", with: "01")
//            }
//            tfPhone.text = phoneNo
            
//            if let age = user.ageRange, !age.isEmpty {
//                ageIndex = ageList.index(of: age)!
//                lbAge.text = ageList[ageIndex]
//            }
//
//            if let gender = user.gender, !gender.isEmpty {
//                if gender.equals("남성") {
//                    radioMale.isSelected = true
//                } else if gender.equals("여성") {
//                    radioFemale.isSelected = true
//                } else {
//                    radioOther.isSelected = true
//                }
//                genderSelected = gender
//            }
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        viewAge.addTapGesture(target: self, action: #selector(openBottonSheet(_:)))
        
        radioMale.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
        radioFemale.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
        radioOther.addTarget(self, action: #selector(btnTouch(_:)), for: .touchUpInside)
    }
    
    // MARK: - KeyBoardHeight
    @objc private func keyboardWillShow(_ notification: Notification) {
        var keyboardHeight: CGFloat = 0
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        self.scrollviewBottomConstraints.constant = -keyboardHeight + self.btnSignUp.bounds.height
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.scrollviewBottomConstraints.constant = 0
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }
    
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction private func openBottonSheet(_ sender: UITapGestureRecognizer) {
        let componentStoryboard = UIStoryboard(name : "BerryComponent", bundle: nil)
        let bottomSheetVC = componentStoryboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as! BottomSheetViewController
        
        bottomSheetVC.titleStr = "연령대 선택"
        bottomSheetVC.contentList = ageList
        bottomSheetVC.delegate = self
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: bottomSheetVC)

        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 312
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
    
    @objc private func btnTouch(_ sender:DLRadioButton) {
        genderSelected = sender.currentTitle!
    }
    
    private func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "회원 가입"

        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        if page != 0 {
            viewSignUpInfo_2.isHidden = true
            page = 0
            btnSignUp.setTitle("다음으로", for: .normal)
            ivNext.isHidden = false
        } else {
            self.navigationController?.pop()
        }
    }
    

    @IBAction private func onClickSignUp(_ sender: Any) {
        if page == 0 {
            if checkValidFirstForm() {
                viewSignUpInfo_2.isHidden = false
                page = 1
                btnSignUp.setTitle("EV Infra 시작하기", for: .normal)
                ivNext.isHidden = true
            }
        } else {
            guard checkValidSecondForm(), let _user = user else { return }
            switch _user.loginType {
            case .apple:
                signUpApple()
            case .evinfra, .kakao:
                signUp()
            default:
                signUp()
            }
            
        }
    }
    
    private func checkValidFirstForm() -> Bool {
        if let name = tfNickname.text, !name.isEmpty, name.count > 1, !name.contains(" ") {
            lbWarnNickname.isHidden = true
            if let email = tfEmail.text, StringUtils.isValidEmail(email) {
                lbWarnEmail.isHidden = true
                if let phone = tfPhone.text, StringUtils.isValidPhoneNum(phone) {
                    lbWarnPhone.isHidden = true
                    return true
                } else {
                    lbWarnPhone.isHidden = false
                }
            } else {
                lbWarnEmail.isHidden = false
            }
        } else {
            lbWarnNickname.isHidden = false
        }
        return false
    }
    
    private func checkValidSecondForm() -> Bool {
        if ageIndex > -1 {
            lbWarnAge.isHidden = true
            if let gender = genderSelected, !gender.isEmpty {
                lbWarnGender.isHidden = true
                return true
            } else {
                lbWarnGender.isHidden = false
            }
        } else {
            lbWarnAge.isHidden = false
        }
        return false
    }
    
    private func signUpApple() {
        guard var _user = self.user, let _appleAuthorizationCode = _user.appleAuthorizationCode else { return }
        if !profileImgName.isEmpty{
            _user.profile_image = profileImgName
        }
        
//        _user.name = tfNickname.text
//        _user.email = tfEmail.text
//        _user.phoneNo = tfPhone.text
//        _user.ageRange = ageList[ageIndex]
//        _user.gender = genderSelected ?? <#default value#>
        
        RestApi().postRefreshToken(appleAuthorizationCode: String(data: _appleAuthorizationCode, encoding: .utf8) ?? "" )
            .convertData()
            .compactMap { result -> String? in
                switch result {
                case .success(let data):
                    
                    var jsonData: JSON = JSON(JSON.null)
                    var jsonString: JSON = JSON(parseJSON: "")
                    do {
                        jsonData = try JSON(data: data, options: .allowFragments)
                        jsonString = JSON(parseJSON: jsonData.rawString() ?? "")
                    } catch let error {
                        printLog(out: "Json Parse Error \(error.localizedDescription)")
                    }
                                    
                    printLog(out: "JsonData : \(jsonData)")

                    let refreshToken = jsonString["refresh_token"].stringValue
                    guard !refreshToken.isEmpty else {
                        return nil
                    }

                    UserDefault().saveString(key: UserDefault.Key.APPLE_REFRESH_TOKEN, value: refreshToken)

                    return refreshToken
                    
                case .failure(let errorMessage):
                    printLog(out: "Error Message : \(errorMessage)")
                    Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                    return nil
                }
            }
            .subscribe(onNext: { refreshToken in
                Server.signUp(user: _user) { (isSuccess, value) in
                    if isSuccess {
                        let json = JSON(value)
                        if json["mb_id"].stringValue.isEmpty {
                            Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                        } else {
                            Snackbar().show(message: "로그인 성공")
                            MemberManager.shared.setData(data: json)
                            self.navigationController?.pop()
                            if let delegate = self.delegate {
                                delegate.successSignUp()
                            }
                        }
                    }
                }
            })
            .disposed(by: self.disposebag)
                        
    }
    
    private func signUp() {
        if var me = self.user {            
            if !profileImgName.isEmpty{
                me.profile_image = profileImgName
            }
            
//            me.name = tfNickname.text
//            me.email = tfEmail.text
//            me.phoneNo = tfPhone.text
//            me.ageRange = ageList[ageIndex]
//            me.gender = genderSelected
                                                        
            Server.signUp(user: me) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    if json["mb_id"].stringValue.isEmpty {
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                    } else {
                        Snackbar().show(message: "로그인 성공")
                        MemberManager.shared.setData(data: json)
                        self.navigationController?.pop()
                        if let delegate = self.delegate {
                            delegate.successSignUp()
                        }
                    }
                }
            }
        }
    }
}

extension SignUpViewController {
    
    private func createProfileImage() {
        if let profileUrl = self.user?.otherInfo?.profile_image {
            // 프로파일 이미지 이름 생성
            let memberId = MemberManager.shared.memberId
            let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
            profileImgName = memberId + "_" + "\(curTime).jpg"
            
            // 카카오 프로파일 이미지 다운로드
            Server.getData(url: profileUrl) { (isSuccess, responseData) in
                if isSuccess {
                    if let data = responseData {
                        Server.uploadImage(data: data, filename: self.profileImgName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if !isSuccess {
                                print("upload image Error : \(json)")
                            }
                        })
                    }
                }
            }
        }
    }
}
extension SignUpViewController: UITextFieldDelegate {
    private func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfPhone {
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
        } else if textField == tfNickname {
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
        if textField == tfNickname {
            tfEmail.becomeFirstResponder()
        } else if textField == tfEmail {
            tfPhone.becomeFirstResponder()
        } else {
            tfPhone.resignFirstResponder()
            view.endEditing(true)
        }
        return true
    }
}

extension SignUpViewController: BottomSheetDelegate {
    internal func onSelected(index: Int) {
        if index >= 0 {
            ageIndex = index
            lbAge.text = ageList[index]
        }
    }
}

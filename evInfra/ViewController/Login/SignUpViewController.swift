//
//  SignUpViewController.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import M13Checkbox
import SwiftyJSON

protocol SignUpViewControllerDelegate {
    func cancelSignUp()
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBOutlet weak var cbUsingTerm: M13Checkbox!
    @IBOutlet weak var cbPersonalInfo: M13Checkbox!
    @IBOutlet weak var cbLocation: M13Checkbox!
    @IBOutlet weak var cbAcceptAll: M13Checkbox!

    var delegate: SignUpViewControllerDelegate?

    var user: Login?
    
    private var profileImgName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareCheckbox()
        enableSignUpButton()
        
        if let user = self.user {
            prepareProfileImg()
            
            let mbNickname = UserDefault().readString(key: UserDefault.Key.MB_NICKNAME)
            if mbNickname.isEmpty || mbNickname.contains("GUEST") {
                tfNickname.text = user.name
            } else {
                tfNickname.text = mbNickname
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func prepareActionBar() {
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
        self.navigationController?.pop()
        if let delegate = self.delegate {
            delegate.cancelSignUp()
        }
    }
    
    func prepareCheckbox() {
        let checkboxColor = UIColor(named: "content-primary")
        
        cbUsingTerm.boxType = .square
        cbUsingTerm.checkState = .unchecked
        cbUsingTerm.tintColor = checkboxColor
        
        cbPersonalInfo.boxType = .square
        cbPersonalInfo.checkState = .unchecked
        cbPersonalInfo.tintColor = checkboxColor
        
        cbLocation.boxType = .square
        cbLocation.checkState = .unchecked
        cbLocation.tintColor = checkboxColor
        
        cbAcceptAll.boxType = .square
        cbAcceptAll.checkState = .unchecked
        cbAcceptAll.tintColor = checkboxColor
    }

    @IBAction func onValueChanged(_ sender: M13Checkbox) {
        if cbUsingTerm.checkState == .checked && cbPersonalInfo.checkState == .checked && cbLocation.checkState == .checked {
            cbAcceptAll.setCheckState(.checked, animated: true)
        } else {
            cbAcceptAll.setCheckState(.unchecked, animated: true)
        }
        enableSignUpButton()
    }
    
    @IBAction func onValueChangedAcceptAll(_ sender: M13Checkbox) {
        switch sender.checkState {
        case .unchecked:
            cbUsingTerm.setCheckState(.unchecked, animated: true)
            cbPersonalInfo.setCheckState(.unchecked, animated: true)
            cbLocation.setCheckState(.unchecked, animated: true)
            break
        case .checked:
            cbUsingTerm.setCheckState(.checked, animated: true)
            cbPersonalInfo.setCheckState(.checked, animated: true)
            cbLocation.setCheckState(.checked, animated: true)
            break
        case .mixed:
            break
        }
        enableSignUpButton()
    }
    
    @IBAction func onClickSeeUsingTerms(_ sender: Any) {
        seeTerms(index: .UsingTerms)
    }
    
    @IBAction func onClickSeePersonalInfoTerms(_ sendeer: Any) {
        seeTerms(index: .PersonalInfoTerms)
    }
    
    @IBAction func onClickSeeLocationTerms(_ sender: Any) {
        seeTerms(index: .LocationTerms)
    }
    
    func seeTerms(index: TermsViewController.Request) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsVc = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsVc.tabIndex = index;

        self.navigationController?.push(viewController: termsVc)
    }
    
    @IBAction func onClickSignUp(_ sender: Any) {
        if let me = self.user {
            if tfNickname.text?.isEmpty ?? true {
                Snackbar().show(message: "닉네임을 입력해주세요.")
                return
            }
//            showProgress(true)
            
            let userDefault = UserDefault()
            if !profileImgName.isEmpty && ivProfile.image != nil {
                let data: Data = UIImageJPEGRepresentation(self.ivProfile.image!, 1.0)!
                Server.uploadImage(data: data, filename: profileImgName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.getMbId())", completion: { (isSuccess, value) in
                    let json = JSON(value)
                    if !isSuccess {
                        print("upload image Error : \(json)")
                    }
                })
                userDefault.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: profileImgName)
            }
            
            userDefault.saveString(key: UserDefault.Key.MB_NICKNAME, value: tfNickname.text!)
            userDefault.saveString(key: UserDefault.Key.MB_USER_ID, value: me.userId!)
            
            Server.signUp(user: me) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    if json["mb_id"].stringValue.isEmpty {
                        Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                    } else {
                        MemberManager().setData(data: json)
                        self.navigationController?.pop()
                    }
                }
            }
        }
    }
    
    func enableSignUpButton() {
        switch cbAcceptAll.checkState {
        case .unchecked:
            btnSignUp.isEnabled = false
            break
        case .checked:
            btnSignUp.isEnabled = true
            break
        case .mixed:
            break
        }
    }
}

extension SignUpViewController {
    
    func prepareProfileImg() {
        ivProfile.layer.borderWidth = 1
        ivProfile.layer.masksToBounds = false
        ivProfile.layer.borderColor = UIColor.white.cgColor
        ivProfile.layer.cornerRadius = ivProfile.frame.height/2
        ivProfile.clipsToBounds = true
        
        profileImgName = UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME)
        if profileImgName.count > 10 {
            ivProfile.sd_setImage(with: URL(string:"\(Const.urlProfileImage)\(profileImgName)"), placeholderImage: UIImage(named: "ic_launcher"))
        } else {
            // 프로파일 이미지가 없는 경우 카카오 프로파일 이미지 사용. "" / "null" / "undefined"
            if let profileUrl = self.user?.profileURL {
                createProfileImage(profileImageURL: (profileUrl))
            }
        }
    }
    
    func createProfileImage(profileImageURL: URL) {
        // 프로파일 이미지 이름 생성
        let memberId = MemberManager.getMemberId()
        let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        profileImgName = memberId + "_" + "\(curTime).jpg"
        
        // 카카오 프로파일 이미지 다운로드
        Server.getData(url: profileImageURL) { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    self.ivProfile.image = UIImage(data: data)
                }
            }
        }
    }
}

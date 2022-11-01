//
//  LoginViewController.swift
//  evInfra
//
//  Created by Shin Park on 2018. 8. 6..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import AuthenticationServices // apple login

internal final class LoginViewController: UIViewController {
    
    enum LastLoginTypeMessage: String {
        case last = "마지막으로 이용한 간편 로그인"
        case new = "새로운 간편 로그인"
    }
    
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "로그인"
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    @IBOutlet weak var loginButtonStackView: UIStackView!
    @IBOutlet weak var btnKakaoLogin: KOLoginButton!
    @IBOutlet weak var btnCorpLogin: UIButton!
    @IBOutlet var kakaoLastLoginGuideLbl: UILabel!
    @IBOutlet var kakaoGuideTotalView: UIView!
    
    private lazy var appleGuideTotalView = UIView()
    
    private lazy var appleLastLoginGuideLbl = UILabel().then {
        
        $0.textAlignment = .natural
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
    }
            
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    override func loadView() {
        super.loadView()
                
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareLoginButton()
        LoginHelper.shared.delegate = self
        
        AmplitudeEvent.shared.fromViewSourceByLogEvent(eventType: .viewLogin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func prepareLoginButton() {
        // 카카오 로그인 버튼
        btnKakaoLogin.addTarget(self, action: #selector(handleKakaoButtonPress), for: .touchUpInside)
        
        btnCorpLogin.layer.borderColor = UIColor(named: "content-primary")?.cgColor
        btnCorpLogin.layer.borderWidth = 1
        btnCorpLogin.layer.cornerRadius = 8
        btnCorpLogin.addTarget(self, action: #selector(handleCorpButtonPress), for: .touchUpInside)
        
        // Apple ID 로그인 버튼
        if #available(iOS 13.0, *) {
            let btnAppleLogin = ASAuthorizationAppleIDButton()            
            btnAppleLogin.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            
            loginButtonStackView.addArrangedSubview(appleGuideTotalView)
            loginButtonStackView.addArrangedSubview(btnAppleLogin)
            
            appleGuideTotalView.addSubview(appleLastLoginGuideLbl)
            appleLastLoginGuideLbl.snp.makeConstraints {
                $0.leading.bottom.equalToSuperview()
                $0.height.equalTo(16)
            }            
        }
        
        switch MemberManager.shared.lastLoginType {
        case .apple, .kakao:
            kakaoGuideTotalView.isHidden = false
            appleGuideTotalView.isHidden = false
            kakaoLastLoginGuideLbl.text = MemberManager.shared.lastLoginType == .apple ? LastLoginTypeMessage.new.rawValue : LastLoginTypeMessage.last.rawValue
            appleLastLoginGuideLbl.text = MemberManager.shared.lastLoginType == .apple ? LastLoginTypeMessage.last.rawValue : LastLoginTypeMessage.new.rawValue
            
        default:
            kakaoGuideTotalView.isHidden = true
            appleGuideTotalView.isHidden = true
        }
    }
    
    @objc
    fileprivate func handleKakaoButtonPress() {
        LoginHelper.shared.kakaoLogin()
    }
    
    @available(iOS 13.0, *)
    @objc
    fileprivate func handleAuthorizationAppleIDButtonPress() {
        LoginHelper.shared.appleLogin()
    }
    
    @objc
    fileprivate func handleCorpButtonPress() {
        let property: [String: Any] = ["type": Login.LoginType.evinfra.value]
        LoginEvent.clickLoginButton.logEvent(property: property)
        corpLogin()
    }
}

extension LoginViewController: LoginHelperDelegate {
    var loginViewController: UIViewController {
        return self
    }
    
    func successLogin() {
        if Const.CLOSED_BETA_TEST {
            CBT.checkCBT(vc: self)
        }

        DispatchQueue.main.async {
            Snackbar().show(message: "로그인 성공")
            GlobalDefine.shared.mainNavi?.pop()
        }
    }
    
    func needSignUp(user: Login) {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let acceptTermsVc = LoginStoryboard.instantiateViewController(withIdentifier: "AcceptTermsViewController") as! AcceptTermsViewController
        acceptTermsVc.user = user
        acceptTermsVc.delegate = self
        GlobalDefine.shared.mainNavi?.push(viewController: acceptTermsVc)
    }
    
    func corpLogin() {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let signUpVc = LoginStoryboard.instantiateViewController(withIdentifier: "CorporationLoginViewController") as! CorporationLoginViewController
        signUpVc.delegate = self
        GlobalDefine.shared.mainNavi?.push(viewController: signUpVc)
    }
}

extension LoginViewController: AcceptTermsViewControllerDelegate {
    func onSignUpDone() {
        GlobalDefine.shared.mainNavi?.pop()
    }
}

extension LoginViewController: CorporationLoginViewControllerDelegate {
    func successSignUp() {
        GlobalDefine.shared.mainNavi?.pop()
    }
}

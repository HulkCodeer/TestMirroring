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
    
    @IBOutlet weak var loginButtonStackView: UIStackView!
    @IBOutlet weak var btnKakaoLogin: KOLoginButton!
    @IBOutlet weak var btnCorpLogin: UIButton!
    @IBOutlet var kakaoLastLoginGuideLbl: UILabel!
    @IBOutlet var kakaoGuideTotalView: UIView!
    
    private lazy var appleGuideTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var appleLastLoginGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
    }
            
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareLoginButton()
        LoginHelper.shared.delegate = self
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "로그인"
        self.navigationController?.isNavigationBarHidden = false
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
    fileprivate func handleBackButton() {
        GlobalDefine.shared.mainNavi?.pop()
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
        let reactor = SignUpReactor(provider: RestApi(), signUpUserData: user)        
        let viewcon = NewAcceptTermsViewController()
        viewcon.reactor = reactor
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func corpLogin() {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let signUpVc = LoginStoryboard.instantiateViewController(withIdentifier: "CorporationLoginViewController") as! CorporationLoginViewController
        signUpVc.delegate = self
        GlobalDefine.shared.mainNavi?.push(viewController: signUpVc)
    }
}

extension LoginViewController: CorporationLoginViewControllerDelegate {
    func successSignUp() {
        GlobalDefine.shared.mainNavi?.pop()
    }
}




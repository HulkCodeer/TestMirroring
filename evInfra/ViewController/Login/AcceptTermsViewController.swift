//
//  AcceptTermsViewController.swift
//  evInfra
//
//  Created by SH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import Material
import M13Checkbox
import UIKit
class AcceptTermsViewController: UIViewController {
    @IBOutlet var cbAcceptAll: M13Checkbox!
    @IBOutlet var cbUsingTerm: M13Checkbox!
    @IBOutlet var cbPersonalInfo: M13Checkbox!
    @IBOutlet var cbLocation: M13Checkbox!

    @IBOutlet var btnNext: UIButton!

    var user: Login?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareCheckbox()
        enableSignUpButton()
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

    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
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
    
    @IBAction func onClickNextBtn(_ sender: Any) {
        let LoginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let signUpVc = LoginStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpVc.delegate = self
        signUpVc.user = user
        self.navigationController?.push(viewController: signUpVc)
    }
    
    func seeTerms(index: TermsViewController.Request) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsVc = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsVc.tabIndex = index;
        self.navigationController?.push(viewController: termsVc)
    }
    
    
    func enableSignUpButton() {
        switch cbAcceptAll.checkState {
        case .unchecked:
            btnNext.isEnabled = false
            btnNext.setBackgroundColor(UIColor(named: "background-disabled")!, for: .normal)
            btnNext.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
            break
        case .checked:
            btnNext.isEnabled = true
            btnNext.setBackgroundColor(UIColor(named: "background-positive")!, for: .normal)
            btnNext.setTitleColor(UIColor(named: "content-primary"), for: .normal)
            break
        case .mixed:
            break
        }
    }
}
extension AcceptTermsViewController: SignUpViewControllerDelegate {
    func successSignUp() {
        self.navigationController?.pop()
    }
}

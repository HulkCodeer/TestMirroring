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

protocol AcceptTermsViewControllerDelegate {
    func onSignUpDone()
}

internal final class AcceptTermsViewController: BaseViewController {
    
    // MARK: UI
    
    @IBOutlet weak var cbAcceptAll: M13Checkbox!
    @IBOutlet weak var cbUsingTerm: M13Checkbox!
    @IBOutlet weak var cbPersonalInfo: M13Checkbox!
    @IBOutlet weak var cbLocation: M13Checkbox!
    @IBOutlet weak var ivNext: UIImageView!
    @IBOutlet weak var cbMarketing: M13Checkbox!
    @IBOutlet weak var cbAd: M13Checkbox!
    @IBOutlet weak var cbContents: M13Checkbox!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var policyStackView: UIStackView!
    
    // MARK: VARIABLE
    
    internal var user: Login?
    internal var delegate: AcceptTermsViewControllerDelegate?
    
    private var policyCheckboxs: [M13Checkbox] = []
        
    // MARK: SYSTEM FUNC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        policyCheckboxs.append(cbUsingTerm)
        policyCheckboxs.append(cbPersonalInfo)
        policyCheckboxs.append(cbLocation)
        policyCheckboxs.append(cbMarketing)
        policyCheckboxs.append(cbAd)
        policyCheckboxs.append(cbContents)
        
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
                
        cbMarketing.boxType = .square
        cbMarketing.checkState = .unchecked
        cbMarketing.tintColor = checkboxColor
        
        cbAd.boxType = .square
        cbAd.checkState = .unchecked
        cbAd.tintColor = checkboxColor
        
        cbContents.boxType = .square
        cbContents.checkState = .unchecked
        cbContents.tintColor = checkboxColor
    }

    
    @objc
    fileprivate func handleBackButton() {
        GlobalDefine.shared.mainNavi?.pop()
    }
    
    
    @IBAction func onValueChanged(_ sender: M13Checkbox) {
        if cbUsingTerm.checkState == .checked &&
            cbPersonalInfo.checkState == .checked &&
            cbLocation.checkState == .checked
        {
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
            cbMarketing.setCheckState(.unchecked, animated: true)
            cbAd.setCheckState(.unchecked, animated: true)
            cbContents.setCheckState(.unchecked, animated: true)
            
        case .checked:
            cbUsingTerm.setCheckState(.checked, animated: true)
            cbPersonalInfo.setCheckState(.checked, animated: true)
            cbLocation.setCheckState(.checked, animated: true)
            cbMarketing.setCheckState(.checked, animated: true)
            cbAd.setCheckState(.checked, animated: true)
            cbContents.setCheckState(.checked, animated: true)
            
        default: break
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
    
    @IBAction func onClickSeeMarketingTerms(_ sender: Any) {
        seeTerms(index: .marketing)
    }
    
    @IBAction func onClickSeeAdTerms(_ sender: Any) {
        seeTerms(index: .ad)
    }
    
    @IBAction func onClickSeeContentsTerms(_ sender: Any) {
        seeTerms(index: .contents)
    }
    
    @IBAction func onClickNextBtn(_ sender: Any) {
        let viewcon = UIStoryboard(name : "Login", bundle: nil).instantiateViewController(ofType: SignUpViewController.self)
        viewcon.delegate = self
        viewcon.user = user
        self.navigationController?.push(viewController: viewcon)
    }
    
    private func seeTerms(index: TermsViewController.Request) {
        let viewcon = UIStoryboard(name : "Info", bundle: nil).instantiateViewController(ofType: TermsViewController.self)
        viewcon.tabIndex = index;
        self.navigationController?.push(viewController: viewcon)
    }
        
    private func enableSignUpButton() {
        switch cbAcceptAll.checkState {
        case .unchecked:
            btnNext.isEnabled = false
            btnNext.setBackgroundColor(UIColor(named: "background-disabled")!, for: .normal)
            btnNext.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
            ivNext.tintColor = UIColor(named: "content-disabled")
            
        case .checked:
            btnNext.isEnabled = true
            btnNext.setBackgroundColor(UIColor(named: "background-positive")!, for: .normal)
            btnNext.setTitleColor(UIColor(named: "content-primary"), for: .normal)
            ivNext.tintColor = UIColor(named: "content-primary")
            
        case .mixed: break
        }
    }
}
extension AcceptTermsViewController: SignUpViewControllerDelegate {
    func successSignUp() {
        self.navigationController?.pop()
        if let delegate = self.delegate {
            delegate.onSignUpDone()
        }
    }
}

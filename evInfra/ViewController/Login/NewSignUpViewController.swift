//
//  NewSignUpViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import UIKit

internal final class NewSignUpViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "정보 입력"
    }
            
    private lazy var stepOneScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = false
    }
           
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음으로", for: .normal)
        $0.setTitle("다음으로", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
        $0.IBcornerRadius = 6
    }
    
    // MARK: VARIABLE
    
    private lazy var signUpStepOneViewController = SignUpStepOneViewController()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        let screenWidth = UIScreen.main.bounds.width
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }
                        
        self.contentView.addSubview(stepOneScrollView)
        stepOneScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.width.equalTo(screenWidth)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
        }
        
        self.addChildViewController(signUpStepOneViewController)
        stepOneScrollView.addSubview(signUpStepOneViewController.view)
        signUpStepOneViewController.view.frame = stepOneScrollView.bounds
        signUpStepOneViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            view.layoutIfNeeded()
//            nextBtn.snp.updateConstraints {
//                $0.bottom.equalToSuperview().offset(-keyboardHeight)
//            }
//
//            let contentsInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight / 2, right: 0)
//            totalScrollView.contentInset = contentsInset
//            totalScrollView.scrollIndicatorInsets = contentsInset
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
//        let contentsInset: UIEdgeInsets = .zero
//        totalScrollView.contentInset = contentsInset
//        totalScrollView.scrollIndicatorInsets = contentsInset
//
//        nextBtn.snp.updateConstraints {
//            $0.bottom.equalToSuperview().offset(0)
//        }
    }
    
    internal func bind(reactor: AcceptTermsReactor) {
        
    }
    
    private func createIconRequired() -> UILabel{
        return UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.backgroundPositive.color
            $0.textAlignment = .natural
            $0.text = "*"
            $0.numberOfLines = 1
            $0.sizeToFit()
        }
    }
}


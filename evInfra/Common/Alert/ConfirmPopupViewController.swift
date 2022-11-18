//
//  ConfirmPopupView.swift
//  evInfra
//
//  Created by PKH on 2022/01/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct PopupModel {
    let title: String?
    let message: String
    let confirmBtnTitle: String?
    let cancelBtnTitle: String?
    let confirmBtnAction: (() -> Void)?
    let cancelBtnAction: (() -> Void)?
    var messageTextAlignment: NSTextAlignment = .center
    let dimmedBtnAction: (() -> Void)?
    let messageAttributedText: NSAttributedString?
    var dimmedBtnEnable: Bool
    
    init(title: String? = nil, message: String = "", messageAttributedText: NSAttributedString? = nil,  confirmBtnTitle: String? = nil, cancelBtnTitle: String? = nil, confirmBtnAction: (() -> Void)? = nil, cancelBtnAction: (() -> Void)? = nil, textAlignment: NSTextAlignment = .center, dimmedBtnEnable: Bool = true,dimmedBtnAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.messageAttributedText = messageAttributedText
        self.confirmBtnTitle = confirmBtnTitle
        self.cancelBtnTitle = cancelBtnTitle
        self.confirmBtnAction = confirmBtnAction
        self.cancelBtnAction = cancelBtnAction
        self.messageTextAlignment = textAlignment
        self.dimmedBtnAction = dimmedBtnAction
        self.dimmedBtnEnable = dimmedBtnEnable
    }
}

internal final class ConfirmPopupViewController: UIViewController {
        
    // MARK: UI
    
    enum ActionBtnType {
        case ok
        case cancel
    }
    
    private lazy var dimmedBtn = UIButton().then {
        $0.backgroundColor = Colors.ntBlack.color.withAlphaComponent(0.3)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = Colors.ntWhite.color
        $0.IBcornerRadius = 8
    }
    
    private lazy var dialogView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 16
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
    }
    
    private lazy var descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = Colors.contentSecondary.color
    }
    
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    // MARK: VARIABLE
    
    internal var popupModel = PopupModel()
    
    private let disposebag = DisposeBag()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    convenience init(model: PopupModel) {
        self.init()
        
        popupModel = model
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func loadView() {
        super.loadView()
                        
        view.addSubview(dimmedBtn)
        dimmedBtn.addSubview(containerView)
        containerView.addSubview(dialogView)
        containerView.addSubview(buttonStackView)
        
        dialogView.addArrangedSubview(titleLabel)
        dialogView.addArrangedSubview(descriptionLabel)
        
        dimmedBtn.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        dialogView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(dialogView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        self.titleLabel.text = self.popupModel.title
        self.descriptionLabel.text = self.popupModel.message
        self.descriptionLabel.setTextWithLineHeight(lineHeight: 22)
        
        if let _message = self.popupModel.messageAttributedText {
            self.descriptionLabel.attributedText = _message
        }
        
                        
        if let _cancelTitle = self.popupModel.cancelBtnTitle {
            let cancelBtn = createButton(backgroundColor: Colors.backgroundPrimary.color ,
                                         buttonTitle: _cancelTitle,
                                         titleColor: Colors.contentPrimary.color)
            cancelBtn.IBborderWidth = 1
            cancelBtn.IBborderColor = Colors.borderOpaque.color
            cancelBtn.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.dismissPopup(actionBtnType: .cancel)
                })
                .disposed(by: self.disposebag)
            buttonStackView.addArrangedSubview(cancelBtn)
        }
        
        if let _confirmTitle = self.popupModel.confirmBtnTitle {
            let confirmBtn = createButton(backgroundColor: Colors.backgroundPositive.color,
                                          buttonTitle: _confirmTitle,
                                          titleColor: Colors.contentOnColor.color)
            confirmBtn.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.dismissPopup(actionBtnType: .ok)
                })
                .disposed(by: self.disposebag)
            buttonStackView.addArrangedSubview(confirmBtn)
        }
        
        descriptionLabel.textAlignment = self.popupModel.messageTextAlignment
        
        dimmedBtn.rx.tap
            .asDriver()
            .drive(with: self){ obj,_ in
                guard let _dimmedAction = self.popupModel.dimmedBtnAction else { return }
                obj.dismissPopup(actionBtnType: .cancel)
                _dimmedAction()
            }
            .disposed(by: self.disposebag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                        
    }
    
    private func createButton(backgroundColor: UIColor, buttonTitle: String, titleColor: UIColor) -> UIButton {
        UIButton().then {
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            $0.layer.cornerRadius = 6
            $0.setTitle(buttonTitle, for: .normal)
            $0.backgroundColor = backgroundColor
        }
    }
        
    private func dismissPopup(actionBtnType: ActionBtnType) {
        self.dismiss(animated: true, completion: {
            switch actionBtnType {
            case .ok:
                self.popupModel.confirmBtnAction?()
            case .cancel:
                self.popupModel.cancelBtnAction?()
            }                    
        })
    }
}

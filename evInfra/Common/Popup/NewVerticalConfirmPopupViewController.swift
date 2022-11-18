//
//  NewVerticalConfirmPopupViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/11/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class NewVerticalConfirmPopupViewController: UIViewController {
    
    enum ActionBtnType {
        case ok
        case cancel
    }
    
    // MARK: UI
    
    private lazy var dimmedBtn = UIButton().then {
        $0.backgroundColor = UIColor(named: "nt-black")?.withAlphaComponent(0.3)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = UIColor(named: "nt-white")
        $0.layer.cornerRadius = 8
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
        $0.axis = .vertical
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
        
        if let _confirmTitle = self.popupModel.confirmBtnTitle {
            let confirmBtn = createButton(backgroundColor: Colors.backgroundPositive.color,
                                          buttonTitle: _confirmTitle,
                                          titleColor: Colors.contentOnColor.color)
            confirmBtn.rx.tap
                .asDriver()
                .drive(with: self){ obj,_ in
                    obj.dismissPopup(actionBtnType: .ok)
                }
                .disposed(by: self.disposebag)
            buttonStackView.addArrangedSubview(confirmBtn)
            confirmBtn.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
                        
        if let _cancelTitle = self.popupModel.cancelBtnTitle {
            let cancelBtn = createButton(backgroundColor: Colors.backgroundPrimary.color ,
                                         buttonTitle: _cancelTitle,
                                         titleColor: Colors.contentPrimary.color)
            cancelBtn.IBborderWidth = 1
            cancelBtn.IBborderColor = Colors.borderOpaque.color
            cancelBtn.rx.tap
                .asDriver()
                .drive(with: self){ obj,_ in
                    obj.dismissPopup(actionBtnType: .cancel)
                }
                .disposed(by: self.disposebag)
            
            buttonStackView.addArrangedSubview(cancelBtn)
            cancelBtn.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
        
        dimmedBtn.isEnabled = self.popupModel.dimmedBtnEnable
        dimmedBtn.rx.tap
            .asDriver()
            .drive(with: self){ obj,_ in
                if let _dimmedAction = self.popupModel.dimmedBtnAction {
                    obj.dismissPopup(actionBtnType: .cancel)
                    _dimmedAction()
                } else {
                    obj.dismiss(animated: true)
                }
            }
            .disposed(by: self.disposebag)
        
        descriptionLabel.textAlignment = self.popupModel.messageTextAlignment
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


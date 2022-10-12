//
//  NewConfrimPopup.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

internal final class VerticalConfirmPopupViewController: UIViewController {
        
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
        
        dialogView.addArrangedSubview(titleLabel)
        dialogView.addArrangedSubview(descriptionLabel)
        dialogView.addArrangedSubview(buttonStackView)
        
        dimmedBtn.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        dialogView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.right.equalToSuperview().offset(-16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        self.titleLabel.text = self.popupModel.title
        self.descriptionLabel.text = self.popupModel.message
        
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


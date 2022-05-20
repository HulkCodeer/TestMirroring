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
    
    init(title: String? = nil, message: String = "",  confirmBtnTitle: String? = nil, cancelBtnTitle: String? = nil, confirmBtnAction: (() -> Void)? = nil, cancelBtnAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.confirmBtnTitle = confirmBtnTitle
        self.cancelBtnTitle = cancelBtnTitle
        self.confirmBtnAction = confirmBtnAction
        self.cancelBtnAction = cancelBtnAction
    }
}

internal final class ConfirmPopupViewController: UIViewController {
        
    // MARK: UI
    
    private lazy var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(named: "nt-black")?.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var containerView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(named: "nt-white")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var dialogView: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "nt-9")
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "nt-9")
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()
    
    // MARK: VARIABLE
    
    internal var popupModel = PopupModel()
    
    private let disposebag = DisposeBag()
    
    convenience init(model: PopupModel) {
        self.init()
        
        popupModel = model
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func loadView() {
        super.loadView()
                        
        view.addSubview(backgroundView)
        backgroundView.addSubview(containerView)
        containerView.addSubview(dialogView)
        
        dialogView.addArrangedSubview(titleLabel)
        dialogView.addArrangedSubview(descriptionLabel)
        dialogView.addArrangedSubview(buttonStackView)
        
        backgroundView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        dialogView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.bottom.right.equalToSuperview().offset(-16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        self.titleLabel.text = self.popupModel.title
        self.descriptionLabel.text = self.popupModel.message
                        
        if let _cancelAction = self.popupModel.cancelBtnAction, let _cancelTitle = self.popupModel.cancelBtnTitle {
            let cancelBtn = createButton(backgroundColor: UIColor(named: "gr-5") ?? .white, buttonTitle: _cancelTitle)
            cancelBtn.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    _cancelAction()
                    self.dismissPopup()
                })
                .disposed(by: self.disposebag)
            buttonStackView.addArrangedSubview(cancelBtn)
        }
        
        if let _confirmAction = self.popupModel.confirmBtnAction, let _confirmTitle = self.popupModel.confirmBtnTitle {
            let confirmBtn = createButton(backgroundColor: UIColor(named: "nt-1") ?? .white, buttonTitle: _confirmTitle)
            confirmBtn.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    _confirmAction()
                    self.dismissPopup()
                })
                .disposed(by: self.disposebag)
            buttonStackView.addArrangedSubview(confirmBtn)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
    }
    
    private func createButton(backgroundColor: UIColor, buttonTitle: String) -> UIButton {
        UIButton().then {
            $0.setTitleColor(UIColor(named: "nt-9"), for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            $0.layer.cornerRadius = 6
            $0.setTitle(buttonTitle, for: .normal)
        }
    }
        
    private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
}


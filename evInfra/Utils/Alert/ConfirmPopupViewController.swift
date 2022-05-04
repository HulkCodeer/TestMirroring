//
//  ConfirmPopupView.swift
//  evInfra
//
//  Created by PKH on 2022/01/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

enum ButtonType {
    case cancel
    case confirm
}

class ConfirmPopupViewController: UIViewController {
    
    private var titleText: String?
    private var messageText: String?
    var confirmDelegate: ((Bool) -> Void)? = nil
    var cancelDelegate: ((Bool) -> Void)? = nil
    
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
        label.text = titleText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "nt-9")
        label.translatesAutoresizingMaskIntoConstraints = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.text = messageText
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
    
    convenience init(titleText: String, messageText: String) {
        self.init()
        
        self.titleLabel.text = titleText
        self.descriptionLabel.text = messageText
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    
    func addActionToButton(title: String?,
                           buttonType: ButtonType?) {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 6
        button.setTitle(title, for: .normal)
        
        switch buttonType {
        case .cancel:
            button.backgroundColor = UIColor(named: "nt-1")
            button.addTarget(self, action: #selector(cancelPopup), for: .touchUpInside)
        case .confirm:
            button.backgroundColor = UIColor(named: "gr-5")
            button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        case .none:
            break
        }

        buttonStackView.addArrangedSubview(button)
    }
    
    @objc
    func cancelPopup() {
        cancelDelegate?(true)
        dismissPopup()
    }
    
    @objc
    func confirmAction() {
        confirmDelegate?(true)
        dismissPopup()
    }
    
    func confirmCompletion(callback: @escaping (Bool) -> Void) {
        self.confirmDelegate = callback
    }
    
    func cancelCompletion(callback: @escaping (Bool) -> Void) {
        self.cancelDelegate = callback
    }
    
    private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
}


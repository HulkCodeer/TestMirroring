//
//  ConfirmPopupView.swift
//  evInfra
//
//  Created by PKH on 2022/01/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class ConfirmPopupViewController: UIViewController {
    
    private var titleText: String?
    private var messageText: String?
    var callback: ((Bool) -> Void)?
    
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
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "nt-9")
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.text = messageText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "nt-9")
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(named: "nt-1")
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitle("취소", for: .normal)
        button.addTarget(self, action: #selector(cancelPopup), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(named: "gr-5")
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitle("삭제", for: .normal)
        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button
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
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
        
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
            $0.height.equalTo(144)
        }
        
        dialogView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.bottom.right.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(40)
        }
        
    }
    
    @objc
    func cancelPopup() {
        dismissPopup()
    }
    
    @objc
    func confirmAction() {
        callback?(true)
        dismissPopup()
    }
    
    func deleteCompletion(callback: @escaping (_ status: Bool) -> Void) {
        self.callback = callback
    }
    
    private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
}


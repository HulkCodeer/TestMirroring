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
    
    let dialogView: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 16
        return view
    }()
    
    let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "삭제 안내"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "nt-9")
        return label
    }()
    
    let descriptionLabel: UILabel = {
       let label = UILabel()
        label.text = "선택하신 사진을 삭제하시겠습니까?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "nt-9")
        return label
    }()
    
    let buttonStackView: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()
    
    let cancelButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(named: "nt-1")
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitle("취소", for: .normal)
        return button
    }()
    
    let confirmButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor(named: "gr-5")
        button.setTitleColor(UIColor(named: "nt-9"), for: .normal)
        button.setTitle("삭제", for: .normal)
        return button
    }()
    
//    convenience init(contentView: UIView) {
//        self.init()
//
//        self.backgroundView = contentView
//        modalPresentationStyle = .overFullScreen
//    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.backgroundView.transform = .identity
            self?.backgroundView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.backgroundView.transform = .identity
            self?.backgroundView.isHidden = true
        }
    }
}


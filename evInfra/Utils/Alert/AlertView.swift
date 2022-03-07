//
//  AlertView.swift
//  evInfra
//
//  Created by PKH on 2022/02/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class AlertView: UIView {

    // MARK: - Views
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Incoming Message"
        label.font = .systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor(named: "nt-white")
        return label
    }()

    private lazy var alertStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4.0
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupView() {
        backgroundColor = UIColor(named: "nt-9")
        layoutStackView()
    }

    private func layoutStackView() {
        addSubview(alertStackView)
        alertStackView.translatesAutoresizingMaskIntoConstraints = false
        
        alertStackView.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.top.left.equalToSuperview().offset(14)
            $0.bottom.right.equalToSuperview().offset(-14)
        }
    }
}

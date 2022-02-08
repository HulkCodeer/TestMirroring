//
//  AlertViewController.swift
//  evInfra
//
//  Created by PKH on 2022/02/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import PanModal
import SnapKit

class AlertViewController: UIViewController, PanModalPresentable {

    private let alertViewHeight: CGFloat = 48

    let alertView: AlertView = {
        let alertView = AlertView()
        alertView.layer.cornerRadius = 10
        return alertView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-85)
            $0.height.equalTo(alertViewHeight)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
    }

    // MARK: - PanModalPresentable

    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeight(alertViewHeight)
    }

    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }

    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.1)
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var showDragIndicator: Bool {
        return true
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var isUserInteractionEnabled: Bool {
        return true
    }
}

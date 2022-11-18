//
//  TransientAlertViewController.swift
//  evInfra
//
//  Created by PKH on 2022/02/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import CoreImage

class TransientAlertViewController: AlertViewController {

    private weak var timer: Timer?
    private var countdown: Int = 1
    var titlemessage: String? = ""
    var dismissCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        alertView.titleLabel.text = titlemessage ?? "알림"
        updateMessage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.countdown -= 1
            self?.updateMessage()
        }
    }

    @objc func updateMessage() {
        guard countdown > 0 else {
            invalidateTimer()
            dismiss(animated: true) {
                self.dismissCompletion?()
            }
            return
        }
    }

    func invalidateTimer() {
        timer?.invalidate()
    }

    deinit {
        invalidateTimer()
    }

    // MARK: - Pan Modal Presentable

    override var showDragIndicator: Bool {
        return false
    }

    override var anchorModalToLongForm: Bool {
        return false
    }

    override var panModalBackgroundColor: UIColor {
        return .clear
    }

    override var isUserInteractionEnabled: Bool {
        return false
    }
}

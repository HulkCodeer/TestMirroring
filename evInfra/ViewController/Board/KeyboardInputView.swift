//
//  KeyboardInputView.swift
//  evInfra
//
//  Created by PKH on 2022/01/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

@IBDesignable
class KeyboardInputView: UIView {
    
    @IBOutlet var inputTextView: UITextField!
    @IBOutlet var inputBorderView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var textfield: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {
        guard let view = Bundle.main.loadNibNamed("KeyboardInputView", owner: self, options: nil)?.first as? UIView else { return }
        
        view.frame = bounds
        self.addSubview(view)
        
        inputBorderView.layer.borderColor = UIColor(named: "nt-2")?.cgColor
        inputBorderView.layer.borderWidth = 1
        inputBorderView.layer.cornerRadius = 4
        
        sendButton.layer.cornerRadius = 6
//        sendButton.isEnabled = false
    }
    
    @IBAction func addMediaButtonClick(_ sender: Any) {
        print("media")
    }
    @IBAction func deleteTextField(_ sender: Any) {
        print("delete")
    }
    @IBAction func sendMessage(_ sender: Any) {
        print("send")
    }
}

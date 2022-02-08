//
//  KeyboardInputView.swift
//  evInfra
//
//  Created by PKH on 2022/01/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

protocol MediaButtonTappedDelegate {
    func presentModal()
}

@IBDesignable
class KeyboardInputView: UIView {

    @IBOutlet var inputBorderView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var placeholderTextField: UILabel!
    @IBOutlet var textViewConstraint: NSLayoutConstraint!
    @IBOutlet var keyboardInputViewBottomMargin: NSLayoutConstraint!
    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var trashButton: UIButton!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var selectedImageViewHeight: NSLayoutConstraint!
    
    private let maxHeight: CGFloat = 150
    private let minHeight: CGFloat = 20
    
    var sendButtonCompletionHandler: ((String, Bool) -> Void)?
    var delegate: MediaButtonTappedDelegate?
    var isRecomment: Bool = false
    var targetNickName: String = ""
    var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    let fontColor = UIColor(named: "gr-5") ?? UIColor.black
    var range: NSString = ""
    let font = UIFont.systemFont(ofSize: 16, weight: .bold)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setKeyboardObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
        setKeyboardObserver()
    }
    
    private func setUI() {
        guard let view = Bundle.main.loadNibNamed("KeyboardInputView", owner: self, options: nil)?.first as? UIView else { return }
        
        view.frame = bounds
        self.addSubview(view)
        
        // 키보드 입력 컨테이너 뷰
        inputBorderView.borderColor = UIColor(named: "nt-2")
        inputBorderView.layer.borderWidth = 1
        inputBorderView.layer.cornerRadius = 4
        
        // 키보드 입력 뷰
        textView.textContainerInset = .zero
        textView.delegate = self
        placeholderTextField.isHidden = false
        
        // 작성 버튼
        sendButton.backgroundColor = UIColor(named: "nt-0")
        sendButton.layer.cornerRadius = 6
        sendButton.isEnabled = false
        
        // 이미지 선택 뷰
        selectedImageView.layer.cornerRadius = 12
        selectedImageView.isHidden = true
        selectedImageViewHeight.constant = 0
        
        // 이미지 제거 버튼
        trashButton.layer.cornerRadius = trashButton.frame.height / 2
        trashButton.isHidden = true
    }
    
    private func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func addMediaButtonTapped(_ sender: Any) {
        self.endEditing(true)
        delegate?.presentModal()
    }
    
    @IBAction func deleteTextButtonTapped(_ sender: Any) {
        textView.text = ""
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let text = textView.text else { return }
        
        if attributedString.length > 0 {

        }
        
        sendButtonCompletionHandler?(text, isRecomment)
        
        textView.text = nil
        textView.endEditing(true)
        textView.attributedText = nil
        isRecomment = false
        
        hiddenSelectedView()
    }
    
    @IBAction func deleteImageButtonTapped(_ sender: Any) {
        hiddenSelectedView()
    }
    
    private func hiddenSelectedView() {
        selectedImageView.isHidden = true
        selectedImageView.image = nil
        trashButton.isHidden = true
        selectedImageViewHeight.constant = 0
    }
}

extension KeyboardInputView: UITextViewDelegate {
    func becomeResponder(targetNickName: String) {
        isRecomment = true
        textView.becomeFirstResponder()
//        placeholderTextField.isHidden = true
//        textView.text = "\(targetNickName) "
//        self.targetNickName = targetNickName
//        range = textView.text as NSString
//
//        attributedString = NSMutableAttributedString(string: "\(targetNickName) ")
//        attributedString.addAttribute(.foregroundColor, value: fontColor, range: range.range(of: "\(targetNickName )"))
//        attributedString.addAttribute(.font, value: font, range: range.range(of: "\(targetNickName )"))
//
//        textView.attributedText = attributedString
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputBorderView.borderColor = UIColor(named: "nt-9")
        inputBorderView.layer.borderWidth = 2
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !textView.text.isEmpty {
            sendButton.backgroundColor = UIColor(named: "gr-5")
        } else {
            sendButton.backgroundColor = UIColor(named: "nt-0")
        }
        
        sendButton.isEnabled = !textView.text.isEmpty
        placeholderTextField.isHidden = !textView.text.isEmpty
        inputBorderView.layer.borderWidth = 1
        inputBorderView.borderColor = UIColor(named: "nt-2")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var height = self.minHeight
        
        if textView.contentSize.height >= self.maxHeight {
            height = self.maxHeight
        } else if textView.contentSize.height <= self.minHeight {
            height = self.minHeight
        } else {
            height = textView.contentSize.height
        }
        
        inputBorderView.layer.borderWidth = 2
        inputBorderView.borderColor = UIColor(named: "nt-9")
        placeholderTextField.isHidden = !textView.text.isEmpty
        
        if !textView.text.isEmpty {
            sendButton.backgroundColor = UIColor(named: "gr-5")
        } else {
            sendButton.backgroundColor = UIColor(named: "nt-0")
        }
        sendButton.isEnabled = !textView.text.isEmpty
        
        textViewConstraint.constant = height
    }
}

// MARK: - KeyboardInputView
extension KeyboardInputView {
    @objc private func adjustInputView(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            let adjustmentHeight = keyboardFrame.height - self.safeAreaInsets.bottom
            
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = -adjustmentHeight
                self.superview?.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = 0
                self.superview?.layoutIfNeeded()
            }
        }
    }
}

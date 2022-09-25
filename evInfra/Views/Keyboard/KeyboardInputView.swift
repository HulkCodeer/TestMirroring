//
//  KeyboardInputView.swift
//  evInfra
//
//  Created by PKH on 2022/01/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

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
    
    var sendButtonCompletionHandler: ((String, Int, Bool, Bool) -> Void)?
    var delegate: MediaButtonTappedDelegate?
    var isRecomment: Bool = false
    var isModify: Bool = false
    var selectedRow: Int = 0
    var targetNickName: String = ""
    
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
        translatesAutoresizingMaskIntoConstraints = false
        // 키보드 입력 컨테이너 뷰
        inputBorderView.borderColor = UIColor(named: "nt-2")
        inputBorderView.layer.borderWidth = 1
        inputBorderView.layer.cornerRadius = 4
        
        // 키보드 입력 뷰
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = .zero
        textView.delegate = self
        placeholderTextField.isHidden = false
        
        // 작성 버튼
        sendButton.setBackgroundColor(UIColor(named: "gr-5")!, for: .normal)
        sendButton.setBackgroundColor(UIColor(named: "nt-0")!, for: .disabled)
        sendButton.layer.cornerRadius = 6
        sendButton.layer.masksToBounds = true
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
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func addMediaButtonTapped(_ sender: Any) {
        self.endEditing(true)
        delegate?.presentModal()
    }
    
    @IBAction func deleteTextButtonTapped(_ sender: Any) {
        textView.text = nil
        sendButton.isEnabled = false
        self.isRecomment = false
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let text = textView.text else { return }
        
        if isRecomment && !targetNickName.isEmpty {
            let withoutText = text.deletingPrefix(targetNickName)
            sendButtonCompletionHandler?(withoutText, selectedRow, isModify, isRecomment)
        } else {
            sendButtonCompletionHandler?(text, selectedRow, isModify, isRecomment)
        }
        
        textView.text = nil
        textView.resignFirstResponder()
        placeholderTextField.isHidden = false
        textView.attributedText = nil
        textViewConstraint.constant = minHeight
        isRecomment = false
        sendButton.isEnabled = false
        isModify = false
        selectedRow = 0
        
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
        textViewDidChange(textView)
    }
}

extension KeyboardInputView: UITextViewDelegate {
    func becomeResponder(comment: Comment, isModify: Bool, isRecomment: Bool, selectedRow: Int) {
        self.isModify = isModify
        self.isRecomment = isRecomment
        self.selectedRow = selectedRow
        self.targetNickName = comment.nick_name ?? ""
        textView.becomeFirstResponder()
        placeholderTextField.isHidden = true
        
        if isModify {
            textView.attributedText = NSMutableAttributedString()
                            .defaultStyle(with: comment.content ?? "")
            if let files = comment.files,
               !files.isEmpty {
                selectedImageView.sd_setImage(with: URL(string: files[0].uploaded_filename ?? ""))
                trashButton.isHidden = false
                selectedImageView.isHidden = false
                selectedImageViewHeight.constant = 80
            }
        } else {
            if isRecomment {
                textView.attributedText = NSMutableAttributedString()
                    .tagStyle(with: targetNickName)
            } else {
                textView.text = comment.content
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputBorderView.borderColor = UIColor(named: "nt-9")
        inputBorderView.layer.borderWidth = 2
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else {
            sendButton.isEnabled = false
            return
        }
        
        sendButton.isEnabled = !text.isEmpty ? true : false
        placeholderTextField.isHidden = !text.isEmpty
        inputBorderView.layer.borderWidth = 1
        inputBorderView.borderColor = UIColor(named: "nt-2")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let seletedRange = textView.selectedRange
        guard let text = textView.text else {
            sendButton.isEnabled = false
            return
        }
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
        placeholderTextField.isHidden = !text.isEmpty

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(named: "nt-9")!,
            .baselineOffset: 0
        ]
        let attributedString = NSMutableAttributedString(string: text, attributes: defaultAttributes)

        if isRecomment {
            if text.count > targetNickName.count {
                if text.hasPrefix(targetNickName) {
                    let tagAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                        .foregroundColor: UIColor(named: "gr-5")!,
                        .baselineOffset: 0
                    ]

                    let range = (text as NSString).range(of: targetNickName)
                    attributedString.addAttributes(tagAttributes, range: range)
                }
            } else {
                self.isRecomment = false
            }
        }
                
        textView.attributedText = attributedString
        textView.selectedRange = seletedRange                
        
        sendButton.isEnabled = !text.isEmpty ? true : false
        textViewConstraint.constant = height
    }
}

// MARK: - KeyboardInputView
extension KeyboardInputView {
    @objc private func adjustInputView(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - self.safeAreaInsets.bottom
            
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = -adjustmentHeight
                self.superview?.layoutIfNeeded()
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: animationDuration) {
                self.keyboardInputViewBottomMargin.constant = 0
                self.superview?.layoutIfNeeded()
            }
        }
    }
}

//
//  EditViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 2..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import UIImageCropper

class EditViewController: UIViewController, UITextViewDelegate {

    public static let BOARD_NEW_MODE            = 1    // 글쓰기
    public static let BOARD_EDIT_MODE           = 2    // 글수정
    public static let REPLY_NEW_MODE            = 3    // 댓글쓰기
    public static let REPLY_EDIT_MODE           = 4    // 댓글수정
    
    @IBOutlet weak var editLayer: UIView!
    @IBOutlet weak var editView: UITextView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var editPhotoLayer: UIView!

    @IBOutlet weak var editImageDelete: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!

    @IBOutlet weak var editViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var actionBarTitle: UILabel!
    @IBOutlet weak var buttonLayer: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var galleryBtn: UIButton!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var editViewDelegate: EditViewDelegate?
    
    var mode = BOARD_NEW_MODE
    
    var scrollViewHeight: CGFloat = 0.0
    var editImageHeight: CGFloat!
    
    var hasImage = 0
    var editImage = 0
    var charger: Charger? = nil

    var originBoardData: BoardData!
    var originReplyData: BoardData.ReplyData!
    var originBoardId: Int?
    
    let picker = UIImagePickerController()
    let cropper = UIImageCropper(cropRatio: 60/37)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        cropper.picker = picker
        cropper.delegate = self
        
        self.editImageView.gone()
        self.editImageDelete.gone()
        self.editView.layer.borderWidth = 1.0
        self.editView.layer.borderColor = UIColor.gray.cgColor
        self.editView.layer.cornerRadius = 10.0
        self.editView.isScrollEnabled = false
        self.editView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if mode == EditViewController.BOARD_EDIT_MODE {
            self.editView.text = originBoardData.content
            if originBoardData.content_img != nil {
                self.editImageView.visible()
                self.editImageDelete.visible()
                self.hasImage = 1
                self.editImage = 0
                self.editImageView.sd_setImage(with: URL(string: "\(Const.urlBoardImage)\(originBoardData.content_img!).jpg"), placeholderImage: UIImage(named: "AppIcon"))
            }
        } else if mode == EditViewController.REPLY_NEW_MODE {
            self.cameraBtn.gone()
            self.galleryBtn.gone()
        } else  if mode == EditViewController.REPLY_EDIT_MODE {
            self.editView.text = originReplyData.content
            self.cameraBtn.gone()
            self.galleryBtn.gone()
        }
        adjustEditViewHeight(textView: self.editView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !MemberManager().isLogin() {
            MemberManager().showLoginAlert(vc: self, completion: { (result) -> Void in
                if !result {
                    self.navigationController?.pop()
                }
            })
        }
        scrollViewUpdate()
        self.scrollView.scrollToTop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - EidtText Func
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.init(red: 192, green: 192, blue: 192, a: 144).cgColor
        scrollViewUpdate()
        self.scrollView.scrollToBottom()
    }

//    func textViewDidEndEditing(_ textView: UITextView) {
//        textView.layer.borderColor =  UIColor(argb: 0x90C0C0C0).cgColor
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustEditViewHeight(textView: textView)
    }
    
    func adjustEditViewHeight(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.editViewHeight.constant = newSize.height
        self.scrollViewUpdate()
        self.scrollView.scrollToBottom()
    }
    
    /*
    // MARK: - Click Buttons
    */
    var toggleOn = false

    @IBAction func onClickCamera(_ sender: UIButton) {
        self.openCamera()
    }
    
    @IBAction func onClickImageLib(_ sender: UIButton) {
        self.openPhotoLib()
    }
    
    @IBAction func onClickEditImageDelete(_ sender: Any) {
        if mode == EditViewController.BOARD_EDIT_MODE {
            self.editImage = 1
        }
        self.hasImage = 0
        self.editImageView.gone()
        self.editImageDelete.gone()
        scrollViewUpdate()
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.scrollViewBottom.constant = keyboardHeight
            scrollViewHeight = self.scrollView.frame.height
            scrollViewUpdate()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollViewBottom.constant = 10
//        self.scrollView.contentSize.height = scrollViewHeight
        scrollViewUpdate()
        self.scrollView.scrollToBottom()
        print("PJS BkeyboardHeight :\(self.scrollView.contentSize.height)")
    }
    
    // MARK: - Capture Camera or Image Library
    func openPhotoLib() {
        picker.sourceType = .photoLibrary
        self.present(picker, animated: false, completion: nil)
    }
    
    func openCamera() {
        picker.sourceType = .camera
        self.present(picker, animated: false, completion: nil)
    }
}

extension EditViewController {
    
    func prepareActionBar() {
        var shareButton: IconButton!
        shareButton = IconButton(image: UIImage(named: "ic_upload"))
        shareButton.tintColor = UIColor(rgb: 0x15435C)
        shareButton.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.rightViews = [shareButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        
        if mode == EditViewController.BOARD_NEW_MODE {
            navigationItem.titleLabel.text = "글쓰기"
        } else if mode == EditViewController.BOARD_EDIT_MODE {
           navigationItem.titleLabel.text = "글수정"
        } else if mode == EditViewController.REPLY_NEW_MODE {
           navigationItem.titleLabel.text = "댓글쓰기"
        } else {
            navigationItem.titleLabel.text = "댓글수정"
        }
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc
    fileprivate func handleShareButton() {
        let content = self.editView.text! as String
        var data: Data? = nil
        if self.mode == EditViewController.BOARD_NEW_MODE {
            if hasImage == 1 {
                data = UIImageJPEGRepresentation(self.editImageView.image!.resize(withWidth: 600)!, 0.8)!
            }
            self.editViewDelegate?.postBoardData(content: content, hasImage: self.hasImage, picture: data)
        } else if self.mode == EditViewController.BOARD_EDIT_MODE {
            if hasImage == 1 {
                data = UIImageJPEGRepresentation(self.editImageView.image!.resize(withWidth: 600)!, 0.8)!
            }
            self.editViewDelegate?.editBoardData(content: content, hasImage: self.hasImage, boardId: originBoardData.boardId!, editImage: self.editImage, picture: data)
        } else if self.mode == EditViewController.REPLY_NEW_MODE {
            self.editViewDelegate?.postReplyData(content: content, boardId: originBoardId!)
        } else {
            self.editViewDelegate?.editReplyData(content: content, replyId: originReplyData.replyId!)
        }
        self.navigationController?.pop()
    }
}

extension EditViewController : UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        self.editImageView.visible()
        self.editImageDelete.visible()
        self.editImageView.image = croppedImage
        if mode == EditViewController.BOARD_EDIT_MODE {
            self.editImage = 1
        }
        self.hasImage = 1
        self.editView.setNeedsLayout()
        self.editView.layoutIfNeeded()
        scrollViewUpdate()
    }
    
    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
        self.editImageDelete.gone()
        if mode == EditViewController.BOARD_EDIT_MODE {
            self.editImage = 0
            self.hasImage = (originBoardData.content_img == nil) ? 0 : 1
        } else {
            self.hasImage = 0
        }
        scrollViewUpdate()
    }
    
    func scrollViewUpdate() {
        if mode == EditViewController.BOARD_EDIT_MODE || mode == EditViewController.BOARD_NEW_MODE{
            if self.hasImage == 1 {
                self.scrollView.contentSize.height = self.editImageView.frame.height + self.editPhotoLayer.frame.height + self.editView.frame.height + 50
            } else {
                self.editImageView.gone()
                self.scrollView.contentSize.height = self.editPhotoLayer.frame.height + self.editView.frame.height + 50
            }
        } else {
            self.scrollView.contentSize.height = self.editView.frame.height + 50
        }
        self.scrollView.isScrollEnabled = true
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
    }
}

//
//  MembershipCardViewController.swift
//  evInfra
//
//  Created by bulacode on 18/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class MembershipCardViewController: UIViewController, MembershipIssuanceViewDelegate {

    var membershipIssuanceView : MembershipIssuanceView? = nil
    var membershipInfoView : MembershipInfoView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        getNoticeData()
        // Do any additional setup after loading the view.
    }

    func getNoticeData() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            Server.getInfoMembershipCard { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    if(json["code"].stringValue.elementsEqual("1101")){ // MBS_CARD_NOT_ISSUED 발급받은 회원카드가 없음
                        self.membershipIssuanceView = MembershipIssuanceView.init(frame: frame)
                        if let msView = self.membershipIssuanceView {
                            msView.membershipIssuanceDelegate = self
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
                            msView.addGestureRecognizer(tap)
                            self.view.addSubview(msView)
                            
                        }
                    } else {
                        self.membershipInfoView = MembershipInfoView.init(frame: frame)
                        if let msView = self.membershipInfoView {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
                            msView.addGestureRecognizer(tap)
                            self.view.addSubview(msView)
                            msView.setCardInfo(cardInfo: json)
                        }
                    }
                }
            }
        }
        /*
        // MARK: - Navigation
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "EV Infra"
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }

    func searchZipCode() {
        print("PJS HERE1")
        let saVC = storyboard?.instantiateViewController(withIdentifier: "SearchAddressViewController") as! SearchAddressViewController
        navigationController?.push(viewController: saVC)
    }
    

    
    func applyMembershipCard(params: [String : String]) {
        print("PJS HERE!")
    }
    
    func showValidateFailMsg(msg: String) {
        print("PJS \(msg)")
    }
    @objc
    fileprivate func handleTap(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // MARK: - KeyBoardHeight
    @objc func keyboardWillShow(_ notification: Notification) {
        print("Keyboard Show View is \(String(describing: type(of: self.membershipIssuanceView)))")
        if let msView = self.membershipIssuanceView {
            if  String(describing: type(of: msView)).elementsEqual("MembershipIssuanceView"){
                if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height + CGFloat(16.0)
                    msView.showKeyBoard(keyboardHeight: keyboardHeight)
                }
            }
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("Keyboard Hide View is \(String(describing: type(of: self.membershipIssuanceView)))")
        if let msView = self.membershipIssuanceView {
            if  String(describing: type(of: msView)).elementsEqual("MembershipIssuanceView"){
                if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    msView.hideKeyBoard()
                }
            }
            
        }
//        self.scrollViewBottom.constant = 10
//        //self.scrollView.contentSize.height = scrollViewHeight
//        scrollViewUpdate()
//        self.scrollView.scrollToBottom()
    }
}

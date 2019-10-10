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

class MembershipCardViewController: UIViewController {
    @IBOutlet weak var membershipView: UIView!
    
    var membershipIssuanceView : MembershipIssuanceView? = nil
    var membershipInfoView : MembershipInfoView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        getNoticeData()
        // Do any additional setup after loading the view.
    }
    
    func getNoticeData() {
            Server.getInfoMembershipCard { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let frame = CGRect(x: 0, y: 0, width: self.membershipView.frame.width, height: self.membershipView.frame.height)
                    if(json["code"].stringValue.elementsEqual("1101")){ // MBS_CARD_NOT_ISSUED 발급받은 회원카드가 없음
                        self.membershipIssuanceView = MembershipIssuanceView.init(frame: frame)
                        if let msView = self.membershipIssuanceView {
                            self.membershipView.addSubview(msView)
                        }
                    } else {
                        self.membershipInfoView = MembershipInfoView.init(frame: frame)
                        if let msView = self.membershipInfoView {
                            self.membershipView.addSubview(msView)
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


}

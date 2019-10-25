//
//  MembershipIssuanceView.swift
//  evInfra
//
//  Created by bulacode on 17/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

class MembershipIssuanceView: UIView {
    
    @IBOutlet weak var ivBasic: UIImageView!
    @IBOutlet weak var ivDetail: UIImageView!
    
    @IBOutlet weak var basicInfoView: UIView!
    @IBOutlet weak var detailInfoView: UIView!
    
    @IBOutlet weak var lbIssuanceMemberType: UILabel!
    @IBOutlet weak var lbIssuanceMbId: UILabel!
    @IBOutlet weak var lbIssuanceNickName: UILabel!
    
    @IBOutlet weak var tfIssuanceName: UITextField!
    @IBOutlet weak var tfIssuancePw: UITextField!
    @IBOutlet weak var tfIssuancePwRe: UITextField!
    @IBOutlet weak var tfIssuancePhone: UITextField!
    @IBOutlet weak var tfIssuanceCarNo: UITextField!
    @IBOutlet weak var tfZipCode: UITextField!
    @IBOutlet weak var tfIssuanceAddress: UITextField!
    @IBOutlet weak var tfIssuanceDetailAddress: UITextField!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmBtnBottom: NSLayoutConstraint!
    
    var membershipIssuanceDelegate: MembershipIssuanceViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("MembershipIssuanceView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.ivBasic.image = UIImage(named: "ic_menu_check")?.withRenderingMode(.alwaysTemplate)
        self.ivBasic.tintColor = UIColor(rgb: 0x585858)
        self.ivDetail.image = UIImage(named: "ic_menu_check")?.withRenderingMode(.alwaysTemplate)
        self.ivDetail.tintColor = UIColor(rgb: 0x585858)
        
        initInfoView()
        
        
    }
    
    @IBAction func onClickSearchZipCode(_ sender: Any) {
        membershipIssuanceDelegate?.searchZipCode()
    }
    
    @IBAction func onClickIssuanceConfrim(_ sender: Any) {
        var issuanceParam = [String: Any]()
        do {
            issuanceParam["mb_name"] = try tfIssuanceName.validatedText(validationType: .membername)
            issuanceParam["mb_pw"] = try tfIssuancePw.validatedText(validationType: .password)
            _ = try tfIssuancePwRe.validatedText(validationType: .repassword(password: tfIssuancePw.text ?? "0000"))
            issuanceParam["phone_no"] = try tfIssuancePhone.validatedText(validationType: .phonenumber)
            issuanceParam["car_no"] = try tfIssuanceCarNo.validatedText(validationType: .carnumber)
            issuanceParam["zip_code"] = try tfZipCode.validatedText(validationType: .zipcode)
            issuanceParam["addr_detail"] = try tfIssuanceDetailAddress.validatedText(validationType: .address)
            issuanceParam["addr"] = tfIssuanceAddress.text
            issuanceParam["mb_id"] = MemberManager.getMbId()
            membershipIssuanceDelegate?.verifyMemgberInfo(params: issuanceParam)
        } catch (let error) {
            membershipIssuanceDelegate?.showValidateFailMsg(msg: (error as! ValidationError).message)
        }
    }
    
    func showKeyBoard(keyboardHeight: CGFloat) {
        self.confirmBtnBottom.constant = keyboardHeight
        self.scrollView.isScrollEnabled = true
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
   }
    func hideKeyBoard() {
         self.confirmBtnBottom.constant = 16
         self.scrollView.isScrollEnabled = true
         self.scrollView.setNeedsLayout()
         self.scrollView.layoutIfNeeded()
    }
    
    func initInfoView(){
        basicInfoView.layer.shadowColor = UIColor.black.cgColor
        basicInfoView.layer.shadowOpacity = 0.5
        basicInfoView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        detailInfoView.layer.shadowColor = UIColor.black.cgColor
        detailInfoView.layer.shadowOpacity = 0.5
        detailInfoView.layer.shadowOffset = CGSize(width: 1, height: 1)
        
       
    }
}

protocol MembershipIssuanceViewDelegate {
    func searchZipCode()
    func verifyMemgberInfo(params: [String : Any])
    func showValidateFailMsg(msg: String)
}



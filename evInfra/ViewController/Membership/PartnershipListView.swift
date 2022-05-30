//
//  PartnershipListView.swift
//  evInfra
//
//  Created by SH on 2020/10/06.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON
import EasyTipView

protocol PartnershipListViewDelegate {
    func addNewPartnership()
    func showEvinfraMembershipInfo(info : MemberPartnershipInfo)    
    func moveMembershipUseGuideView()
    func moveReissuanceView(info: MemberPartnershipInfo)
    func paymentStatusInfo() -> PaymentStatus
}

internal final class PartnershipListView : UIView {
    
    // MARK: UI
    
    @IBOutlet var viewEvinfraList: UIView!
    @IBOutlet var labelCardStatus: UILabel!
    @IBOutlet var labelCardNum: UILabel!
    @IBOutlet var labelCarNo: UILabel!
    @IBOutlet var labelContrDate: UILabel!
    @IBOutlet var viewAddBtn: UIView!
    @IBOutlet var btnAddCard: UIImageView!
    @IBOutlet var membershipUseGuideBtn: UIButton!
    @IBOutlet var reissuanceBtn: UIButton!
    @IBOutlet var membershipUseGuideLbl: UILabel!
    @IBOutlet var reissuanceView: UIView!
    @IBOutlet var reissuanceLbl: UILabel!
    
    
    // MARK: VARIABLE
    
    internal var delegate: PartnershipListViewDelegate?
    internal var navi: UINavigationController = UINavigationController()
    
    private var evInfraInfo : MemberPartnershipInfo = MemberPartnershipInfo(JSON.null)
    private var disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        addSubview(view)
        initView()
        
        membershipUseGuideLbl.attributedText = NSAttributedString(string: "회원카드 사용방법이 궁금하신가요?", attributes:
                                                                    [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        
        membershipUseGuideBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.moveMembershipUseGuideView()
            })
            .disposed(by: self.disposebag)
        
        reissuanceBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                                
                Server.getPayRegisterStatus { (isSuccess, value) in
                    if isSuccess {
                        let json = JSON(value)
                        let payCode = json["pay_code"].intValue                        
                                            
                        switch PaymentStatus(rawValue: payCode) {
                        case .PAY_NO_CARD_USER, // 카드등록 아니된 멤버
                                .PAY_NO_VERIFY_USER, // 인증 되지 않은 멤버 *헤커 의심
                                .PAY_DELETE_FAIL_USER, // 비정상적인 삭제 멤버
                                .PAY_NO_USER :  // 유저체크
                            
                            let popupModel = PopupModel(title: "결제카드 오류 안내",
                                                        message: "현재 고객님의 결제 카드에 오류가 발생했어요. 오류 발생 시 원활한 서비스 이용을 할 수 없으니 다른 카드로 변경해주세요.",
                                                        confirmBtnTitle: "결제카드 변경하기",
                                                        confirmBtnAction: { [weak self] in
                                guard let self = self else { return }
                                let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                                let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                                self.navi.push(viewController: myPayInfoVC)
                            })

                            let popup = ConfirmPopupViewController(model: popupModel)
                                                        
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                self.navi.present(popup, animated: false, completion: nil)
                            })
                                                
                        case .PAY_DEBTOR_USER: // 돈안낸 유저
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                                self.navi.push(viewController: paymentVC)
                            })
                            
                        case .PAY_FINE_USER: // 정상 유저
                            self.delegate?.moveReissuanceView(info: self.evInfraInfo)
                            
                        case .CHARGER_STATE_CHARGING: // 충전중
                            let popupModel = PopupModel(title: "충전중 재발급 신청 불가 안내",
                                                        message: "충전중에는 재발급 신청을 할 수 없어요. 충전이 종료된 뒤 신청을 해주세요.",
                                                        confirmBtnTitle: "확인")
                            let popup = ConfirmPopupViewController(model: popupModel)
                                                                                    
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                self.navi.present(popup, animated: false, completion: nil)
                            })
                                                
                        default: break
                        }
                        
                        printLog(out: "json data : \(json)")
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                    }
                }
                
            })
            .disposed(by: self.disposebag)
        
        membershipUseGuideBtn.isExclusiveTouch = true
        reissuanceBtn.isExclusiveTouch = true
    }
    
    private func loadViewFromNib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("PartnershipListView", owner: self, options: nil)?.first as? UIView else { return UIView() }
        return view
    }
    
    func showInfoView(info : MemberPartnershipInfo) {
        evInfraInfo = info
        viewEvinfraList.isHidden = false
        labelCardStatus.text = info.displayStatusDescription        
        reissuanceBtn.isEnabled = info.isReissuance
        reissuanceLbl.textColor = info.isReissuance ? UIColor(named: "nt-9"): UIColor(named: "nt-3")
        
        guard let _cardNo = info.cardNo else { return }
        let modString = _cardNo.replaceAll(of : "(\\d{4})(?=\\d)", with : "$1-")
        labelCardNum.text = modString
                        
        if info.cardStatusType == .sipping {
            var preferences = EasyTipView.Preferences()
            preferences.drawing.backgroundColor = UIColor(named: "background-always-dark")!
            preferences.drawing.foregroundColor = UIColor(named: "content-on-color")!
            preferences.drawing.textAlignment = NSTextAlignment.natural
            
            preferences.drawing.arrowPosition = .bottom
            
            preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
            preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
            preferences.animating.showInitialAlpha = 0
            preferences.animating.showDuration = 1
            preferences.animating.dismissDuration = 1
                                 
            guard !UserDefault().readBool(key: UserDefault.Key.IS_HIDDEN_DELEVERY_COMPLETE_TOOLTIP) else { return }
            let text = "영업일 기준 3~5일 뒤에\n우편함을 확인해보세요! 📮✉️"
            EasyTipView.show(forView: self.labelCardStatus,
                             withinSuperview: self.viewEvinfraList,
                text: text,
                             preferences: preferences, delegate: self)
        }
    }
    
    private func initView() {
        let ev_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        viewEvinfraList.addGestureRecognizer(ev_touch)
        
        let add_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickAddBtn))
        btnAddCard.addGestureRecognizer(add_touch)
    }
            
    @objc func onClickEvInfra(sender: UITapGestureRecognizer) {
        delegate?.showEvinfraMembershipInfo(info : self.evInfraInfo)
    }
    
    @objc func onClickAddBtn(sender: UITapGestureRecognizer) {
        delegate?.addNewPartnership()
    }
}

extension PartnershipListView: EasyTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
    }
    
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        UserDefault().saveBool(key: UserDefault.Key.IS_HIDDEN_DELEVERY_COMPLETE_TOOLTIP, value: true)
    }
}

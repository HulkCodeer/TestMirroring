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

protocol PartnershipListViewDelegate: AnyObject {
    func addNewPartnership()
    func showEvinfraMembershipInfo(info : MembershipCardInfo)
    func moveMembershipUseGuideView()
    func moveReissuanceView(info: MembershipCardInfo)
    func paymentStatusInfo() -> PaymentStatus
    func showShipmentStatusView()
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
    @IBOutlet var evPayGuideArrow: UIView!
    
    private lazy var evPayGuideArrowView = ChevronArrow(.size20(.right)).then {
        $0.IBimageColor = Colors.contentTertiary.color
    }
    
    private lazy var shipmentStatusArrowView = ChevronArrow.init(.size20(.right)).then {
        $0.IBimageColor = Colors.backgroundAlwaysLight.color
    }
    
    private lazy var presentShipmentViewBtn = UIButton()
    
    private var cardNoTooltipView = TooltipView(configure: TooltipView.Configure(tipLeftMargin: 8, tipDirection: .bottom, maxWidth: 233)).then {
        $0.isHidden = true
    }
        
    // MARK: VARIABLE
    
    internal weak var delegate: PartnershipListViewDelegate?
    internal var fromViewType: MembershipCardViewController.FromViewType = .none
    
    private var evInfraInfo: MembershipCardInfo = MembershipCardInfo(JSON.null)
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
        
        evPayGuideArrow.addSubview(evPayGuideArrowView)
        evPayGuideArrowView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        self.addSubview(shipmentStatusArrowView)
        shipmentStatusArrowView.snp.makeConstraints {
            $0.leading.equalTo(labelCardStatus.snp.trailing)
            $0.centerY.equalTo(labelCardStatus.snp.centerY)
            $0.width.height.equalTo(20)
        }
        
        self.addSubview(presentShipmentViewBtn)
        presentShipmentViewBtn.snp.makeConstraints {
            $0.leading.equalTo(labelCardStatus.snp.leading)
            $0.height.equalTo(labelCardStatus.snp.height)
            $0.trailing.equalTo(shipmentStatusArrowView.snp.trailing)
            $0.centerY.equalTo(labelCardStatus.snp.centerY)
        }
        
        presentShipmentViewBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                obj.delegate?.showShipmentStatusView()
            }
            .disposed(by: self.disposebag)
                        
        membershipUseGuideBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                obj.delegate?.moveMembershipUseGuideView()
            }
            .disposed(by: self.disposebag)
        
        reissuanceBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                if !self.evInfraInfo.isReissuance {
                    let popupModel = PopupModel(title: "업데이트 준비중입니다.",
                                                message:"빠른 시일 내에 업데이트 예정이며, 재발급 신청이 필요한 경우 고객센터로 연락주시기 바랍니다. ",
                                                confirmBtnTitle: "확인",
                                                cancelBtnTitle: "고객센터 연결",                                                
                                                cancelBtnAction: {
                        guard let number = URL(string: "tel://070-8633-9009") else { return }
                        UIApplication.shared.open(number)
                    })
                    
                    let popup = ConfirmPopupViewController(model: popupModel)
                    
                    GlobalDefine.shared.mainNavi?.present(popup, animated: true, completion: nil)
                } else {
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
                                                            confirmBtnAction: {                                     
                                    AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "EVI Pay카드 관리 결제카드 등록 오류")
                                    let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                                    let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                                    GlobalDefine.shared.mainNavi?.push(viewController: myPayInfoVC)
                                })

                                let popup = ConfirmPopupViewController(model: popupModel)
                                                            
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                                })
                                                    
                            case .PAY_DEBTOR_USER: // 돈안낸 유저
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                                    GlobalDefine.shared.mainNavi?.push(viewController: paymentVC)
                                })
                                
                            case .PAY_FINE_USER: // 정상 유저
                                self.delegate?.moveReissuanceView(info: self.evInfraInfo)
                                
                            case .CHARGER_STATE_CHARGING: // 충전중
                                let popupModel = PopupModel(title: "충전중 재발급 신청 불가 안내",
                                                            message: "충전중에는 재발급 신청을 할 수 없어요. 충전이 종료된 뒤 신청을 해주세요.",
                                                            confirmBtnTitle: "확인")
                                let popup = ConfirmPopupViewController(model: popupModel)
                                                                                        
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                                })
                                                    
                            default: break
                            }
                            
                            printLog(out: "json data : \(json)")
                        } else {
                            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                        }
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
    
    func showInfoView(info : MembershipCardInfo) {
        evInfraInfo = info
        viewEvinfraList.isHidden = false
        labelCardStatus.text = info.condition.convertStatusType.toString
        reissuanceLbl.textColor = info.isReissuance ? Colors.nt9.color: Colors.nt3.color                        
        labelCardNum.text = info.displayCardNo
        
        
        
//        if info.condition.convertStatusType == .sendReady, !MemberManager.shared.isShowMembershipCardCompleteTooltip {
            cardNoTooltipView.isHidden = false
            
            self.addSubview(cardNoTooltipView)
            cardNoTooltipView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.width.equalTo(233)
                $0.bottom.equalToSuperview().offset(-50)
                $0.height.equalTo(69)
            }
        
        cardNoTooltipView.show(message: "GS, 환경부 제외 충전소에서\n카드 번호로 바로 충전할 수 있어요!")
            
//            MemberManager.shared.isShowMembershipCardCompleteTooltip = true
//        }
                                
        if info.condition.convertStatusType == .sending {
            _ = viewEvinfraList.subviews.compactMap { $0 as? EasyTipView }.first?.removeFromSuperview()
                                    
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

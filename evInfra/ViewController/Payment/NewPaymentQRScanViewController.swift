//
//  NewPaymentQRScanViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/19.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import ReactorKit

internal final class NewPaymentQRScanViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: QR Scanner UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "QR 코드 스캔"
    }
    
    private lazy var qrReaderView = QRReaderView()
    
    private lazy var guideLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.text = "QR 코드를 비추면 자동으로 스캔되어요"
        $0.textColor = .white
    }
    
    private lazy var qrBoxImgView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "qr_box")
    }
    
    private lazy var tcTotalView = UIView()
    private lazy var tcTf = UITextField().then {
        $0.clearButtonMode = .always
    }
    private lazy var tcBtn = UIButton().then {
        $0.setTitle("적용", for: .normal)
    }
                
    // MARK: VARIABLE
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(qrReaderView)
        qrReaderView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(qrBoxImgView)
        qrBoxImgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(216)
        }
        
        self.contentView.addSubview(guideLbl)
        guideLbl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(qrBoxImgView.snp.bottom).offset(46)
        }
        
        self.contentView.addSubview(tcTotalView)
        tcTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        tcTotalView.addSubview(tcTf)
        tcTf.snp.makeConstraints {
            $0.leading.top.bottom.height.equalToSuperview()
            $0.width.equalTo(200)
        }
        
        tcTotalView.addSubview(tcBtn)
        tcBtn.snp.makeConstraints {
            $0.leading.equalTo(tcTf).offset(20)
            $0.top.bottom.height.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QR Scan 화면"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCharging()
    }
                    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrReaderView.stop()
    }
    
    init(reactor: PaymentQRScanReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func bind(reactor: PaymentQRScanReactor) {
        qrReaderView.bind(reactor)
        
        switch (MemberManager.shared.hasPayment, MemberManager.shared.hasMembership) {
        case (false, false) :
            let popupModel = PopupModel(title: "회원카드 발급이 필요해요",
                                        message: "회원카드를 발급 해야 한국전력, GS칼텍스의 QR 충전을 이용할 수 있어요.",
                                        confirmBtnTitle: "회원카드 발급하기", cancelBtnTitle: "닫기",
                                        confirmBtnAction: {
                let viewcon = UIStoryboard(name : "Membership", bundle: nil).instantiateViewController(ofType: MembershipCardViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }
            }, textAlignment: .center)
            
            let popup = VerticalConfirmPopupViewController(model: popupModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
            })
        }
        
        Observable.just(PaymentQRScanReactor.Action.loadPaymentStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isPaymentFineUser }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj,_ in
                obj.qrReaderView.makeUIWithStart()
            }
            .disposed(by: self.disposeBag)
    }
          
    private func startCharging() {
        let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: PaymentStatusViewController.self)
//        viewcon.cpId = self.cpId!
//        viewcon.connectorId = self.connectorId!
        
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon, transitionType: kCATransitionReveal, subtype: kCATransitionFromBottom)
    }
}

extension NewPaymentQRScanViewController: RepaymentListDelegate {
    func onRepaySuccess() {
        qrReaderView.stop()
    }
    
    func onRepayFail(){
        GlobalDefine.shared.mainNavi?.pop()
    }
}

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
import EasyTipView

internal final class NewPaymentQRScanViewController: CommonBaseViewController, StoryboardView {
        
    // MARK: QR Scanner UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        
        $0.naviTitleLbl.text = "QR 코드 스캔"
    }
    
    private lazy var stationGuideLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .semibold)
        $0.text = "현재 GS칼텍스에서\nQR 충전을 할 수 있어요"
        $0.textColor = Colors.backgroundPrimary.color
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var stationSubGuideLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.text = "한국전력 충전소에서도 QR충전하고 싶다면?"
        $0.textColor = Colors.nt2.color
        $0.setUnderline()
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }
    
    private lazy var stationSubGuideBtn = UIButton()
    
    private lazy var qrReaderView = QRReaderView()
    
    private lazy var dimmedView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
    }
    
    private lazy var holeView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var guideLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.text = "QR 코드를 비추면 자동으로 스캔되어요"
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var qrBoxImgView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "qr_box")
    }
            
    private lazy var tcTotalView = UIView()
    private lazy var tcTf = UITextField().then {
        $0.backgroundColor = .white
        $0.clearButtonMode = .always
        $0.addLeftPadding(padding: 20)
    }
    private lazy var tcBtn = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("적용", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
                
    // MARK: VARIABLE
    private var timer = Timer()
    private var tipView = EasyTipView(text: "")
    
    // MARK: SYSTEM FUNC
    
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
                
        self.contentView.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(qrBoxImgView)
        qrBoxImgView.snp.makeConstraints {
            $0.center.equalTo(dimmedView.snp.center)
            $0.width.height.equalTo(189)
        }
                
        self.contentView.addSubview(holeView)
        holeView.snp.makeConstraints {
            $0.center.equalTo(qrBoxImgView.snp.center)
            $0.width.equalTo(265)
            $0.height.equalTo(264)
        }
        
        self.contentView.addSubview(guideLbl)
        guideLbl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(holeView.snp.bottom).offset(9)
        }
        
        self.contentView.addSubview(stationGuideLbl)
        stationGuideLbl.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(47)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(stationSubGuideLbl)
        stationSubGuideLbl.snp.makeConstraints {
            $0.top.equalTo(stationGuideLbl.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(stationSubGuideBtn)
        stationSubGuideBtn.snp.makeConstraints {
            $0.center.equalTo(stationSubGuideLbl.snp.center)
            $0.width.equalTo(stationSubGuideLbl.snp.width)
            $0.height.equalTo(44)
        }
                        
        #if DEBUG
        self.contentView.addSubview(tcTotalView)
        tcTotalView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        tcTotalView.addSubview(tcTf)
        tcTf.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.bottom.height.equalToSuperview()
            $0.width.equalTo(200)
        }
        
        tcTotalView.addSubview(tcBtn)
        tcBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerY.equalTo(tcTf.snp.centerY)
            $0.leading.equalTo(tcTf.snp.trailing).offset(20)
            $0.bottom.height.equalToSuperview()
        }
        #else
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QR Scan 화면"
    }
                    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrReaderView.start()
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
        GlobalDefine.shared.mainNavi?.interactivePopGestureRecognizer?.isEnabled = false
        
        guard let _reactor = self.reactor else { return }
        self.changeStationGuideWithPaymentStatusCheck(reactor: _reactor)
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
        
        tcBtn.rx.tap
            .do(onNext: { self.view.endEditing(true) }) // TEST CODE
            .map { PaymentQRScanReactor.Action.loadTestChargingQR(self.tcTf.text ?? "" ) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
                                                              
        reactor.state.compactMap { $0.isPaymentFineUser }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj,_ in
                let shapeLayer = CAShapeLayer()
                shapeLayer.frame = obj.dimmedView.bounds
                shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
                
                let path = UIBezierPath(rect: obj.dimmedView.bounds)
                path.append(UIBezierPath(rect: CGRect(x: obj.holeView.frame.origin.x, y: obj.holeView.frame.origin.y - 56, width: obj.holeView.bounds.width, height: obj.holeView.bounds.height)))
                shapeLayer.path = path.cgPath

                obj.dimmedView.layer.mask = shapeLayer
                
                obj.qrReaderView.makeUI()
                obj.qrReaderView.start()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isQRScanRunning }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isQRScanRunning in
                guard !isQRScanRunning else { return }
                obj.qrReaderView.start()
            }
            .disposed(by: self.disposeBag)
                        
        reactor.state.compactMap { $0.qrOutletTypeModel }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { obj, qrOutletTypeModel in
                let rowVC = NewBottomSheetViewController()
                rowVC.items = qrOutletTypeModel.map { $0.title }
                rowVC.headerTitleStr = "충전 타입 선택"
                rowVC.nextBtnCompletion = { [weak self] index in
                    guard let self = self else { return }
                    Observable.just(PaymentQRScanReactor.Action.loadChargingQR(reactor.qrCode, qrOutletTypeModel[index].id))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                    rowVC.view.removeFromSuperview()
                    rowVC.removeFromParent()
                }
                
                rowVC.dimmedViewBtnCompletion = { [weak self] in
                    guard let self = self else { return }
                    self.qrReaderView.start()
                }
                
                rowVC.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
                self.addChild(rowVC)
                self.view.addSubview(rowVC.view)
            }
            .disposed(by: self.disposeBag)
        
    }
    
    private func changeStationGuideWithPaymentStatusCheck(reactor: PaymentQRScanReactor) {
        stationSubGuideLbl.isHidden = true
        stationSubGuideBtn.isHidden = true
        
        switch (MemberManager.shared.hasPayment, MemberManager.shared.hasMembership) {
        case (false, false): // 신규유저, 피그마 CASE 1
            let tempText = "한국 전력과 GS칼텍스에서\nQR 충전을 할 수 있어요"
            let attributeText = NSMutableAttributedString(string: tempText)
            let allRange = NSMakeRange(0, attributeText.length)
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPrimary.color], range: allRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: allRange)
            var chageRange = (attributeText.string as NSString).range(of: "GS칼텍스")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.gr4.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            
            chageRange = (attributeText.string as NSString).range(of: "한국 전력")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            
            stationGuideLbl.attributedText = attributeText
            guideLbl.text = "QR 코드를 비추면 자동으로 스캔되어요"
            
            stationSubGuideLbl.isHidden = false
            stationSubGuideBtn.isHidden = false
            stationSubGuideLbl.text = "한국 전력 QR충전 시 주의사항"
            
            stationSubGuideBtn.rx.tap
                .filter { [weak self] _ in
                    guard let self = self else { return false }
                    return !self.timer.isValid
                }
                .asDriver(onErrorJustReturn: ())
                .drive(with: self) { obj, _ in
                    var preferences = EasyTipView.Preferences()
                            
                    preferences.drawing.backgroundColor = Colors.backgroundAlwaysDark.color
                    preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
                    preferences.drawing.textAlignment = NSTextAlignment.center
        
                    preferences.drawing.arrowPosition = .top
                    preferences.animating.showInitialAlpha = 1
                    preferences.animating.showDuration = 1
                    preferences.animating.dismissDuration = 1
                    preferences.positioning.maxWidth = 294
        
                    let text = "충전기에 따라 QR코드 이미지 화질 저하로\nQR스캔까지 시간이 걸릴 수 있어요.\n번호 입력 및 카드 태깅으로도 충전 가능해요."
                    obj.tipView = EasyTipView(text: text, preferences: preferences)
                    obj.tipView.show(forView: self.stationSubGuideLbl)
                    
                    obj.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
                        obj.tipView.dismiss()
                        timer.invalidate()
                    }
                }
                .disposed(by: self.disposeBag)
            
            let popupModel = PopupModel(title: "EV Pay카드 발급이 필요해요",
                                        message: "EV Pay카드를 발급 해야 한국전력, GS칼텍스의 QR 충전을 이용할 수 있어요.",
                                        confirmBtnTitle: "EV Pay 발급하기", cancelBtnTitle: "닫기",
                                        confirmBtnAction: {
                AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "QR 팝업")
                let viewcon = MembershipGuideViewController()
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }, cancelBtnAction: {
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
            }, textAlignment: .center, dimmedBtnAction: {
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
            })
            
            let popup = VerticalConfirmPopupViewController(model: popupModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
            })
            
            Observable.just(PaymentQRScanReactor.Action.loadPaymentStatus)
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
        case (false, true): // 오류 유저(미수금), 피그마 CASE 2
            let tempText = "한국 전력과 GS칼텍스에서\nQR 충전을 할 수 있어요"
            let attributeText = NSMutableAttributedString(string: tempText)
            let allRange = NSMakeRange(0, attributeText.length)
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPrimary.color], range: allRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: allRange)
            var chageRange = (attributeText.string as NSString).range(of: "GS칼텍스")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.gr4.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            
            chageRange = (attributeText.string as NSString).range(of: "한국 전력")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            
            stationGuideLbl.attributedText = attributeText
                        
            stationSubGuideLbl.isHidden = false
            stationSubGuideBtn.isHidden = false
            stationSubGuideLbl.text = "한국 전력 QR충전 시 주의사항"
            
            stationSubGuideBtn.rx.tap
                .filter { [weak self] _ in
                    guard let self = self else { return false }
                    return !self.timer.isValid
                }
                .asDriver(onErrorJustReturn: ())
                .drive(with: self) { obj, _ in
                    var preferences = EasyTipView.Preferences()
                            
                    preferences.drawing.backgroundColor = Colors.backgroundAlwaysDark.color
                    preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
                    preferences.drawing.textAlignment = NSTextAlignment.center
        
                    preferences.drawing.arrowPosition = .top
                    preferences.animating.showInitialAlpha = 1
                    preferences.animating.showDuration = 1
                    preferences.animating.dismissDuration = 1
                    preferences.positioning.maxWidth = 294
        
                    let text = "충전기에 따라 QR코드 이미지 화질 저하로\nQR스캔까지 시간이 걸릴 수 있어요.\n번호 입력 및 카드 태깅으로도 충전 가능해요."
                    obj.tipView = EasyTipView(text: text, preferences: preferences)
                    obj.tipView.show(forView: self.stationSubGuideLbl)
                    
                    obj.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
                        obj.tipView.dismiss()
                        timer.invalidate()
                    }
                }
                .disposed(by: self.disposeBag)
            
            Observable.just(PaymentQRScanReactor.Action.loadPaymentStatus)
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
        case (true, false): // GS 사용자, 피그마 CASE 3
            let tempText = "현재 GS칼텍스에서\nQR 충전을 할 수 있어요"
            let attributeText = NSMutableAttributedString(string: tempText)
            let allRange = NSMakeRange(0, attributeText.length)
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPrimary.color], range: allRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: allRange)
            
            let chageRange = (attributeText.string as NSString).range(of: "GS칼텍스")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.gr4.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            stationGuideLbl.attributedText = attributeText
            
            stationSubGuideLbl.isHidden = false
            stationSubGuideBtn.isHidden = false
            stationSubGuideLbl.text = "한국전력 충전소에서도 QR충전하고 싶다면?"
            
            stationSubGuideBtn.rx.tap
                .asDriver()
                .drive(onNext: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        AmplitudeEvent.shared.setFromViewDesc(fromViewDesc: "QR 팝업")
                        let viewcon = MembershipGuideViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    })
                })
                .disposed(by: self.disposeBag)
                                                            
            Observable.just(PaymentQRScanReactor.Action.loadPaymentStatus)
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
                                
        case (true, true): // 아무 이상 없는 유저, 피그마 CASE 4
            let tempText = "한국 전력과 GS칼텍스에서\nQR 충전을 할 수 있어요"
            let attributeText = NSMutableAttributedString(string: tempText)
            let allRange = NSMakeRange(0, attributeText.length)
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPrimary.color], range: allRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: allRange)
            var chageRange = (attributeText.string as NSString).range(of: "GS칼텍스")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.gr4.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            chageRange = (attributeText.string as NSString).range(of: "한국 전력")
            attributeText.addAttributes([NSAttributedString.Key.foregroundColor: Colors.backgroundPositive.color], range: chageRange)
            attributeText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)], range: chageRange)
            stationGuideLbl.attributedText = attributeText
            
            stationSubGuideLbl.isHidden = false
            stationSubGuideBtn.isHidden = false
            stationSubGuideLbl.text = "한국 전력 QR충전 시 주의사항"
            
            stationSubGuideBtn.rx.tap
                .filter { [weak self] _ in
                    guard let self = self else { return false }
                    return !self.timer.isValid
                }
                .asDriver(onErrorJustReturn: ())
                .drive(with: self) { obj, _ in
                    var preferences = EasyTipView.Preferences()
                            
                    preferences.drawing.backgroundColor = Colors.backgroundAlwaysDark.color
                    preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
                    preferences.drawing.textAlignment = NSTextAlignment.center
        
                    preferences.drawing.arrowPosition = .top
                    preferences.animating.showInitialAlpha = 1
                    preferences.animating.showDuration = 1
                    preferences.animating.dismissDuration = 1
                    preferences.positioning.maxWidth = 294
        
                    let text = "충전기에 따라 QR코드 이미지 화질 저하로\nQR스캔까지 시간이 걸릴 수 있어요.\n번호 입력 및 카드 태깅으로도 충전 가능해요."
                    obj.tipView = EasyTipView(text: text, preferences: preferences)
                    obj.tipView.show(forView: self.stationSubGuideLbl)
                    
                    obj.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
                        obj.tipView.dismiss()
                        timer.invalidate()
                    }
                }
                .disposed(by: self.disposeBag)
                        
            Observable.just(PaymentQRScanReactor.Action.loadPaymentStatus)
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate()
        self.tipView.dismiss()
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

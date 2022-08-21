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
        $0.naviTitleLbl.text = "충전하기"
    }
    
    private lazy var qrReaderView = QRReaderView()
    
    private lazy var guideLbl = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.text = "QR 코드를 비춰주세요."
        $0.textColor = .white
    }
    
    private lazy var qrBoxImgView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "qr_box")
    }
                
    // MARK: VARIABLE
    
    private var mConnectorList = [Connector]()
    private var mMyPoint: Int = 0
    private var cpId: String? = ""
    private var connectorId: String? = ""
    
    //MARK: SYSTEM FUNC
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QR Scan 화면"
                                
        //테스트 하거나 UI 확인시 아래 주석을 풀어주시기 바랍니다.
//        self.onResultScan(scanInfo: "{ \"cp_id\": \"GS00002101\", \"connector_id\": \"1\" }")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermission()
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
  
    func responseGetChargerInfo(response: Any) {
//        let json = JSON(response)
//        if json["code"].stringValue.elementsEqual("1000") {
//            self.mConnectorList.removeAll()
//            let jsonArray = json["connector"].arrayValue
//            for connectorJson in jsonArray {
//                let connectorId = connectorJson["id"].stringValue
//                let status = connectorJson["status"].stringValue
//                let typeId = connectorJson["type_id"].stringValue
//                let name = connectorJson["type_name"].stringValue
//
//                self.mConnectorList.append(Connector.init(id: connectorId, typeId: typeId, typeName: name, status: status))
//
//                // 서버에서 cp id 검사 후 사용가능한 cp id로 변환 후 내려보내줌
//                self.cpId = connectorJson["cp_id"].stringValue
//            }
//
//            if let conId = self.connectorId, !conId.isEmpty {
//                self.guideLbl.text = "결제 가능한 충전기입니다."
//                self.verifySelectedCharger()
//            } else {
//                Snackbar().show(message: "현재 GS칼텍스 충전기에서만 QR결제기능이 사용가능합니다.\n타 사업자 추가 후 공지드리겠습니다.")
//            }
//        } else {
//            self.showUnsupportedChargerDialog()
//        }
    }
    
    func verifySelectedCharger() {
//        for (index, connector) in mConnectorList.enumerated() {
//            if self.connectorId!.elementsEqual(connector.mId!) {
//                if let status = mConnectorList[index].mStatus {
//                    if status.elementsEqual("2") { // 대기중. Const.CHARGER_STATE_WAITING
//                        startCharging()
//                    } else if status.elementsEqual("7") { // 시범운영중. 무료 충전 가능. Const.CHARGER_STATE_PILOT
//                        showAlertDialogByMessage(message: "시범운영중입니다. 무료로 이용가능합니다.")
//                    } else {
//                        showAlertDialogByMessage(message: "현재 충전기가 사용 가능하지 않습니다.")
//                    }
//                }
//                break
//            }
//        }
    }
    
    func getTypeUIImage(typeId: String) -> UIImage? {
        switch typeId {
        case "1":
            return UIImage(named: "type_demo")
        case "4":
            return UIImage(named: "type_combo")
        case "7":
            return UIImage(named: "type_ac3")
        default:
            return UIImage(named: "ic_question")
        }
    }
    
    private func startCharging() {
        let paymentStatusVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
        paymentStatusVc.cpId = self.cpId!
        paymentStatusVc.connectorId = self.connectorId!
        
        var vcArray = GlobalDefine.shared.mainNavi?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(paymentStatusVc)
        GlobalDefine.shared.mainNavi?.setViewControllers(vcArray!, animated: true)
    }
        
    private func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined || status == .denied {
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { grated in
                if grated {
                } else {
                    self.showAuthAlert()
                }
            }
        }
    }
    
    private func showAuthAlert() {
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            Snackbar().show(message: "카메라 기능이 활성화되지 않아 QR충전을 실행 할 수 없습니다.")
            GlobalDefine.shared.mainNavi?.pop()
        }
        
        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        var actions = Array<UIAlertAction>()
        actions.append(cancelAction)
        actions.append(openAction)
        UIAlertController.showAlert(title: "카메라 기능이 활성화되지 않았습니다", message: "QR충전을 위해 카메라 권한이 필요합니다", actions: actions)
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

//
//  PaymentQRScanViewController.swift
//  evInfra
//
//  Created by bulacode on 27/06/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Material

class PaymentQRScanViewController: UIViewController {
    
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView?

    var cpId: String? = ""
    var connectorId: String? = ""
    
    //QR Scanner
    @IBOutlet weak var scannerViewLayer: UIView!
    @IBOutlet weak var lbExplainScanner: UILabel!
    
    @IBOutlet weak var btnStartCharge: UIButton!
    
    var mConnectorList = [Connector]()
    
    var mMyPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareView()
        prepareQRScanner()
        preparePaymentCardStatus()
        //테스트 하거나 UI 확인시 아래 주석을 풀어주시기 바랍니다.
//        self.onResultScan(scanInfo: "{ \"cp_id\": \"994\", \"connector_id\": \"1\" }")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickStartCharging(_ sender: UIButton) {
        self.startCharging()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "충전하기"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        self.btnStartCharge.isEnabled = false
    }
    
    func preparePaymentCardStatus() {
        Server.getPayRegisterStatus{ (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let payCode = json["pay_code"].intValue
                
                switch (payCode) {
                case PaymentStatus.PAY_NO_USER, PaymentStatus.PAY_NO_CARD_USER:
                    self.showRegisterCardDialog()
                    
                case PaymentStatus.PAY_DEBTOR_USER, PaymentStatus.PAY_NO_VERIFY_USER, PaymentStatus.PAY_DELETE_FAIL_USER:
                    let resultMessage = json["ResultMsg"].stringValue
                    let message = resultMessage.replacingOccurrences(of: "\\n", with: "\n")
                    self.showAlertDialogByMessage(message: message)
                    
                case PaymentStatus.PAY_REGISTER_FAIL_PG:
                    self.showAlertDialogByMessage(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                    
                default:
                    break
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
}

extension PaymentQRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let qrString = metadataObj.stringValue {
                self.onResultScan(scanInfo: qrString)
                self.captureSession.stopRunning()
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
    
    func prepareQRScanner() {
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        captureSession = AVCaptureSession ()
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = scannerViewLayer.layer.bounds
        scannerViewLayer.layer.addSublayer(videoPreviewLayer!)
        scannerViewLayer.bringSubview(toFront: lbExplainScanner)
        
        // Start video capture.
        captureSession.startRunning()
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            scannerViewLayer.addSubview(qrCodeFrameView)
            scannerViewLayer.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    func onResultScan(scanInfo: String?) {
        self.cpId = nil
        self.connectorId = nil
        
        if let resultQR = scanInfo {
            if resultQR.count > 0 {
                let qrJson = JSON.init(parseJSON: resultQR)
                self.cpId = qrJson["cp_id"].stringValue
                if let cpid = self.cpId {
                    if cpid.count > 8 {
                        let index = cpid.index(cpid.startIndex, offsetBy: 8)
                        self.cpId = String(cpid[..<index])
                    }
                }
                self.connectorId = qrJson["connector_id"].stringValue
            }
        }
        
        if let cpid = self.cpId {
            Server.getChargerInfo(cpId: cpid, completion: {(isSuccess, value) in
                if isSuccess {
                    self.responseGetChargerInfo(response: value)
                } else {
                    self.showUnsupportedChargerDialog()
                }
            })
        } else {
            self.showUnsupportedChargerDialog()
        }
    }
}

extension PaymentQRScanViewController {

    func responseGetChargerInfo(response: Any) {
        let json = JSON(response)
        if json["code"].stringValue.elementsEqual("1000") {
            self.mConnectorList.removeAll()
            let jsonArray = json["connector"].arrayValue
            for connectorJson in jsonArray {
                let connectorId = connectorJson["id"].stringValue
                let status = connectorJson["status"].stringValue
                let typeId = connectorJson["type_id"].stringValue
                let name = connectorJson["type_name"].stringValue

                self.mConnectorList.append(Connector.init(id: connectorId, typeId: typeId, typeName: name, status: status))
            }
            
            if let conId = self.connectorId, !conId.isEmpty {
                self.lbExplainScanner.text = "결제 가능한 충전기입니다."
                self.verifySelectedCharger()
            } else {
                Snackbar().show(message: "현재 GS칼텍스 충전기에서만 QR결제기능이 사용가능합니다.\n타 사업자 추가 후 공지드리겠습니다.")
            }
        } else {
            self.showUnsupportedChargerDialog()
        }
    }
    
    func verifySelectedCharger() {
        for (index, connector) in mConnectorList.enumerated() {
            if self.connectorId!.elementsEqual(connector.mId!) {
                if let status = mConnectorList[index].mStatus {
                    if status.elementsEqual("2") { // 대기중. Const.CHARGER_STATE_WAITING
                        self.btnStartCharge.isEnabled = true
                    } else if status.elementsEqual("7") { // 시범운영중. 무료 충전 가능. Const.CHARGER_STATE_PILOT
                        showAlertDialogByMessage(message: "시범운영중입니다. 무료로 이용가능합니다.")
                    } else {
                        showAlertDialogByMessage(message: "현재 충전기가 사용 가능하지 않습니다.")
                    }
                }
                break
            }
        }
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
    
    func startCharging() {
        let paymentStatusVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
        paymentStatusVc.cpId = self.cpId!
        paymentStatusVc.connectorId = self.connectorId!
        
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(paymentStatusVc)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    }
    
    func showUnsupportedChargerDialog() {
        let dialogMessage = UIAlertController(title: "미지원 충전기", message: "결제 가능 충전소가 아니거나, 등록 되지않은 QR 코드입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showAlertDialogByMessage(message: String) {
        let dialogMessage = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showRegisterCardDialog() {
        let dialogMessage = UIAlertController(title: "카드 등록 필요", message: "결제카드 등록 후 사용 가능합니다. \n카드를 등록하시려면 확인 버튼을 누르세요.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            let myPayInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPayinfoViewController") as! MyPayinfoViewController
            var vcArray = self.navigationController?.viewControllers
            vcArray!.removeLast()
            vcArray!.append(myPayInfoVC)
            self.navigationController?.setViewControllers(vcArray!, animated: true)
//            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.pushViewController(myPayInfoVC, animated: false)
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}

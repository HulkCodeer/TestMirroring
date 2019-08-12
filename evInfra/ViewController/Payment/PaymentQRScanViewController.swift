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
    var qrString: String = ""
    var cpId: String? = ""
    var connectorId: String? = ""
    //QR Scanner
    @IBOutlet weak var scannerViewLayer: UIView!
    @IBOutlet weak var lbExplainScanner: UILabel!
    
    
    @IBOutlet weak var ivType: UIImageView!
    @IBOutlet weak var lbTypeTitle: UILabel!
    @IBOutlet weak var lbQrScanChargerType: UILabel!
    @IBOutlet weak var svQrScanChargerType: UIStackView!
    
    @IBOutlet weak var ivPoint: UIImageView!
    @IBOutlet weak var lbPointTitle: UILabel!
    @IBOutlet weak var lbMyPointTitle: UILabel!
    @IBOutlet weak var lbMyPoint: UILabel!
    @IBOutlet weak var lbMyPointPeriod: UILabel!
    
    @IBOutlet weak var lbUserPointTitle: UILabel!
    @IBOutlet weak var tfUsePoint: UITextField!
    @IBOutlet weak var lbUsePointPeriod: UILabel!
    
    @IBOutlet weak var btnStartCharge: UIButton!
    
    var mConnectorList = [Connector]()
    var mButtonTypeList = [UIButton]()
    var mIsPayableCharger = false
    
    var mMyPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareView()
        prepareQRScanner()
        prepareMyPoint()
        preparePaymentCardStatus()
        //테스트 하거나 UI 확인시 아래 주석을 풀어주시기 바랍니다.
//        self.onResultScan(scanInfo: "{ \"cp_id\": \"GS00000801\", \"connector_id\": \"1\" }")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func onClickChargerType(_ sender:UIButton){
        if (!availableChargerType(index: sender.tag)){
            Snackbar().show(message: "사용할 수 없는 커넥터입니다.")
            return;
        }
        let isSelected = sender.isSelected
        for button in self.mButtonTypeList {
            button.isSelected = false
        }
        sender.isSelected = !isSelected
        enableStartButton()
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    
    @IBAction func onClickStartCharging(_ sender: UIButton) {
        self.startCharging()
    }
    
}

extension PaymentQRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            qrString = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                qrString = metadataObj.stringValue ?? "nil"
            }
            
            
            self.onResultScan(scanInfo: qrString)
        }
    }
    func prepareView(){
        self.ivType.image = UIImage(named: "ic_menu_plug_type")?.withRenderingMode(.alwaysTemplate)
        self.ivType.tintColor = UIColor(rgb: 0x585858)
        self.lbTypeTitle.textColor = UIColor(rgb: 0x585858)
        self.lbTypeTitle.text = "TYPE"
        self.lbQrScanChargerType.textColor = UIColor(rgb: 0x909090)
        
        self.ivPoint.image = UIImage(named: "ic_menu_point")?.withRenderingMode(.alwaysTemplate)
        self.ivPoint.tintColor = UIColor(rgb: 0x585858)
        self.lbPointTitle.textColor = UIColor(rgb: 0x585858)
        self.lbPointTitle.text = "POINT"
        
        self.lbMyPointTitle.textColor = UIColor(rgb: 0x909090)
        self.lbMyPointTitle.text = "내 포인트"
        self.lbMyPoint.textColor = UIColor(rgb: 0x909090)
        self.lbMyPointPeriod.textColor = UIColor(rgb: 0x909090)
        self.lbMyPointPeriod.text = "점"
        
        self.lbUserPointTitle.textColor = UIColor(rgb: 0x909090)
        self.lbUserPointTitle.text = "포인트사용"
        self.tfUsePoint.textColor = UIColor(rgb: 0x909090)
        self.lbUsePointPeriod.textColor = UIColor(rgb: 0x909090)
        self.lbUsePointPeriod.text = "점"
        
        self.btnStartCharge.isEnabled = false
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
    
    func prepareQRScanner(){
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
            print("PJS qrCodeFrameView")
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            scannerViewLayer.addSubview(qrCodeFrameView)
            scannerViewLayer.bringSubview(toFront: qrCodeFrameView)
        }
    
    }
    
    func onlyDcComboCharger() -> Bool {
        if self.mConnectorList.count == 2 {
            return mConnectorList[0].mTypeId == "4" && mConnectorList[0].mTypeId == mConnectorList[1].mTypeId;
        }
        return false;
    }
}

extension PaymentQRScanViewController {
    
    func onResultScan(scanInfo: String?){
        self.cpId = nil
        self.connectorId = nil
        
        if let resultQR = scanInfo {
            if(resultQR.count > 0){
                var qrJson = JSON.init(parseJSON: resultQR)
                self.cpId = qrJson["cp_id"].stringValue
                if let cpid = self.cpId{
                    if(cpid.count > 8){
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
                }else{
                    self.showUnsupportedChargerDialog()
                }
            })
        } else{
            self.showUnsupportedChargerDialog()
        }
    }
    
    func responseGetChargerInfo(response: Any) {
        let json = JSON(response)
        if json["code"].stringValue.elementsEqual("1000") {
            self.lbExplainScanner.text = "결제 가능한 충전기입니다."
            self.mIsPayableCharger = true
            self.mConnectorList.removeAll()
            let jsonArray = json["connector"].arrayValue
            for connectorJson in jsonArray {
                let connectorId = connectorJson["id"].stringValue
                let status = connectorJson["status"].stringValue
                let typeId = connectorJson["type_id"].stringValue
                let name = connectorJson["type_name"].stringValue
                print("PJS HERE FOR CHARGER = \(name)")
                self.mConnectorList.append(Connector.init(id: connectorId, typeId: typeId, typeName: name, status: status))
            }
            guard let conId = self.connectorId, !conId.isEmpty else{
                self.updateChargerTypeButton(isShow: true)
                self.selectChargerTypeByMyCar()
                return
            }
            self.verifySelectedCharger()
            self.updateChargerTypeButton(isShow: false)
        } else {
            self.showUnsupportedChargerDialog()
        }
    }
    
    func verifySelectedCharger(){
        for (index, connector) in mConnectorList.enumerated() {
            if (self.connectorId!.elementsEqual(connector.mId!)){
                if availableChargerType(index: index){
                    
                }else {
                    let message = "현재 충전기가 사용 가능하지 않습니다."
                    showAlertDialogByMessage(message: message)
                }
            }
        }
        
    }
    
    func availableChargerType(index: Int) -> Bool{
        switch (mConnectorList[index].mStatus) {
            case "0", // 알 수 없음
                "1", // 통신 이상
                "3", // 충전중
                "4", // 운영중지
                "5", // 점검중
                "6": // 예약중
                return false
        case "2": // 대기중
                return true
            default :
                return false
        }
    }
    
    func getTypeUIImage(typeId: String) -> UIImage? {
        switch(typeId){
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
    
    func updateChargerTypeButton(isShow : Bool){
        if !isShow {
            self.lbQrScanChargerType.isHidden = false
            self.svQrScanChargerType.isHidden = true
            self.lbQrScanChargerType.text = "충전기에서 커넥터를 선택하였습니다."
        } else {
            self.lbQrScanChargerType.isHidden = true
            self.svQrScanChargerType.isHidden = false
            addChargerTypeButton()
        }
    }
    func addChargerTypeButton(){
        if onlyDcComboCharger() {
            let connector_1 = self.mConnectorList[0]
            let connector_2 = self.mConnectorList[1]
            if (connector_1.mId == "1"){
                connector_1.mTypeName = "DC콤보 (좌)";
                connector_2.mTypeName = "DC콤보 (우)";
            }else{
                connector_2.mTypeName = "DC콤보 (좌)";
                connector_1.mTypeName = "DC콤보 (우)";
            }
        }
        self.mButtonTypeList.removeAll()
        var btnIndex = 0;
        for connector in mConnectorList {
            let btnChargerType = UIButton.init()
            btnChargerType.setImage(self.getTypeUIImage(typeId: connector.mTypeId!), for: .normal)
            btnChargerType.setTitle(connector.mTypeName, for: .normal)
            btnChargerType.tag = btnIndex
            btnChargerType.setBackgroundColor(UIColor.init(rgb: 0x64b5f6, alpha: 0x90), for: .normal)
            btnChargerType.setBackgroundColor(UIColor.init(rgb: 0x64b5f6, alpha: 0x90), for: .disabled)
            btnChargerType.setBackgroundColor(UIColor.init(rgb: 0x64b5f6), for: .selected)
            btnChargerType.layer.shadowColor = UIColor.black.cgColor
            btnChargerType.layer.shadowOpacity = 0.5
            btnChargerType.layer.shadowOffset = CGSize(width: 0, height: -1)
            btnChargerType.layer.cornerRadius = 8.0
            btnChargerType.clipsToBounds = true
            btnChargerType.addTarget(self, action: #selector(self.onClickChargerType(_:)), for: .touchUpInside)
            svQrScanChargerType.addArrangedSubview(btnChargerType)
            mButtonTypeList.append(btnChargerType)
            btnIndex = btnIndex + 1
        }
        
        self.svQrScanChargerType.distribution = .fillEqually
        self.svQrScanChargerType.spacing = 8.0
    }
    
    func enableStartButton(){
        if self.getSelectedConnectorId() != nil{
            if (self.mIsPayableCharger) {
                self.btnStartCharge.isEnabled = true
            } else {
                self.btnStartCharge.isEnabled = false
            }
            
        }else{
           self.btnStartCharge.isEnabled = false
        }
    }
    func startCharging() {
        let connectorId = self.getSelectedConnectorId()
        if connectorId == nil {
            Snackbar().show(message: "충전 타입을 선택해 주세요.")
            return
        }
        
        var point: Int = 0;
        if let pointStr = tfUsePoint.text{
            if !pointStr.isEmpty {
                point = Int(pointStr) ?? 0;
            }
        }
        let paymentStatusVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
        if let conId = connectorId {
            paymentStatusVc.connectorId = conId
        }
        paymentStatusVc.point = point
        paymentStatusVc.cpId = self.cpId!
        
        var vcArray = self.navigationController?.viewControllers
        vcArray!.removeLast()
        vcArray!.append(paymentStatusVc)
        self.navigationController?.setViewControllers(vcArray!, animated: true)
    }

    

    func getSelectedConnectorId() -> String? {
        for btnChargerType in mButtonTypeList {
            if (btnChargerType.isSelected) {
            let index = Int(btnChargerType.tag)
                return self.mConnectorList[index].mId
            }
        }
        return nil
    }

    func selectChargerTypeByMyCar(){
        if (!onlyDcComboCharger()) {
            let myCarType = String(UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE))
            for btnChargerType in mButtonTypeList {
                let index = btnChargerType.tag;
                if (availableChargerType(index: index)) {
                    if myCarType == mConnectorList[index].mTypeId {
                        btnChargerType.isSelected = true
                    }
                }
            }
        }
    }
}

extension PaymentQRScanViewController {
    
    func showUnsupportedChargerDialog(){
        let dialogMessage = UIAlertController(title: "미지원 충전기", message: "결제 가능 충전소가 아니거나, 등록 되지않은 QR 코드입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showAlertDialogByMessage(message: String){
        let dialogMessage = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showRegisterCardDialog(){
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

extension PaymentQRScanViewController {
    
    func preparePaymentCardStatus(){
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
                        self.showAlertDialogByMessage(message: message);
                    case PaymentStatus.PAY_REGISTER_FAIL_PG:
                        self.showAlertDialogByMessage(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.");
                    default:
                        break
                }
                
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func prepareMyPoint(){
        Server.getPoint{ (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].stringValue == "1000"{
                    self.mMyPoint = json["point"].intValue
                    self.lbMyPoint.text = "\(self.mMyPoint)"
                }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    //Swift 복붙용 소스
//    Server.getPoint{ (isSuccess, value) in
//        if isSuccess {
//        let json = JSON(value)
//        let payCode = json["pay_code"].intValue
//
//
//        } else {
//        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
//        }
//    }
}




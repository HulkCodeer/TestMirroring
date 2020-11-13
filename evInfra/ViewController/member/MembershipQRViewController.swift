//
//  MembershipQRViewController.swift
//  evInfra
//
//  Created by SH on 2020/10/07.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Material

class MembershipQRViewController: UIViewController,
        RegisterResultDelegate {
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView?

    @IBOutlet var scannerViewLayer: UIView!
    @IBOutlet var lbExplainScanner: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareView()
        prepareQRScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func prepareActionBar() {
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "SK Rent Car 카드 연동"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        self.scannerViewLayer.frame.size.width = self.view.frame.width
    }
    
    func showInvalidQrResultDialog() {
        let dialogMessage = UIAlertController(title: "잘못된 QR입니다", message: "다시 시도하십시오", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            self.navigationController?.pop()
        })
        
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func showResultView(code : Int, imgType : String, retry : Bool, callBtn : Bool, msg : String){
        let resultVC = storyboard?.instantiateViewController(withIdentifier: "RegisterResultViewController") as! RegisterResultViewController
        resultVC.requestCode = code
        resultVC.imgType = imgType
        resultVC.showRetry = retry
        resultVC.showCallBtn = callBtn
        resultVC.message = msg
        resultVC.delegate = self
        self.navigationController?.push(viewController: resultVC)
    }
    
    func onConfirmBtnPressed(code : Int){
        self.navigationController?.pop()
    }
}

extension MembershipQRViewController: AVCaptureMetadataOutputObjectsDelegate {
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
        if let resultQR = scanInfo {
            if resultQR.count > 0 {
                var carNo : String = ""
                var cardNo : String = ""
                let resultArr = resultQR.components(separatedBy: ",")
                if resultArr.count == 2 {
                    carNo = getCarNo(data: resultArr[0])
                    cardNo = getCardNo(data: resultArr[1])
                }
                if !carNo.isEmpty && !cardNo.isEmpty {
                    let validator = VaildatorFactory.validatorFor(type: ValidatorType.carnumber)
                    do {
                        let carValidNum = try validator.validated(carNo)
                        Server.registerSKMembershipCard(carNo : carValidNum, cardNo : cardNo, completion: { (isSuccess, value) in
                            if isSuccess {
                                let json = JSON(value)
                                switch json["code"].intValue {
                                case 1000:
                                    MemberManager.setSKRentConfig()
                                    self.showResultView(code : 0, imgType : "SUCCESS", retry : false, callBtn : false, msg : "정보가 확인되었습니다.")
                                    break
                                case 1104 :
                                    self.showResultView(code : 0, imgType : "QUESTION", retry : true, callBtn : true, msg : "기존에 등록된 회원 정보입니다.\nsk renter 멤버쉽 카드는\n기기당 한 계정만 등록 가능합니다.\n분실 및 재발급에 대한 문의는\n아래로 전화 주시기 바랍니다.")
                                    break
                                case 1105 :
                                    self.showResultView(code : 0, imgType : "ERROR", retry : true, callBtn : true, msg : "일치하는 정보가 없습니다.\n재스캔 이후에도 조회되지 않는 경우,\n아래 번호롤 전화주시기 바랍니다.")
                                    break
                                default :
                                    break
                                }
                            } else {
                                
                            }
                        })
                    } catch {
                        print("validation error")
                        self.showInvalidQrResultDialog()
                    }
                } else {
                    self.showInvalidQrResultDialog()
                }
            }
        }
    }

    func getCarNo(data: String) -> String {
        var carNo = ""
        if !data.isEmpty {
            let carNumber = data.components(separatedBy: "-")
            var useSymbol = carNumber[1]
            switch (useSymbol) {
                case "01":
                    useSymbol = "하"
                break
                case "02":
                    useSymbol = "허"
                break
                case "03":
                    useSymbol = "호"
                break
                default :
                    break
            }

            let tempCarNo = carNumber[0] + useSymbol + carNumber[2]
            let validator = VaildatorFactory.validatorFor(type: ValidatorType.carnumber)
            do {
                carNo = try validator.validated(tempCarNo)
            } catch {
                print("validation error")
                self.showInvalidQrResultDialog()
            }
        }
        return carNo;
    }
    
    func getCardNo(data: String) -> String {
        if !data.isEmpty, data.count == 8, StringUtils.isNumber(data) {
            return data
        }
        return ""
    }
}

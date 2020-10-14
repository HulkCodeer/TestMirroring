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

class MembershipQRViewController: UIViewController {
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
        //테스트 하거나 UI 확인시 아래 주석을 풀어주시기 바랍니다.
        self.onResultScan(scanInfo: "{ \"cp_id\": \"994\", \"connector_id\": \"1\" }")
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
        var carNo = ""
        var cardNo = ""
        if let resultQR = scanInfo {
            if resultQR.count > 0 {
                let qrJson = JSON.init(parseJSON: resultQR)
                carNo = qrJson["qrCarNo"].stringValue
                cardNo = qrJson["qrCardNo"].stringValue
            }
        }
        
        if !carNo.isEmpty && !cardNo.isEmpty {

        } else {
            self.showInvalidQrResultDialog()
        }
    }
}

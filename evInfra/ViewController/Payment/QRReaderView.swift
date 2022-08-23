//
//  QRReaderView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

internal final class QRReaderView: UIView {    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private let metadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr]
    private var disposeBag = DisposeBag()
    private weak var reactor: PaymentQRScanReactor?
    
    private var isRunning: Bool {
        guard let captureSession = self.captureSession else {
            return false
        }

        return captureSession.isRunning
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func initialSetupView() {
        self.clipsToBounds = true
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            printLog(out: error.localizedDescription)
            return
        }

        guard let captureSession = self.captureSession else {
            self.fail()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            self.fail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self.metadataObjectTypes
        } else {
            self.fail()
            return
        }
        
        self.setPreviewLayer()
    }

    private func setPreviewLayer() {
        guard let captureSession = self.captureSession else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.layer.bounds        

        self.layer.addSublayer(previewLayer)

        self.previewLayer = previewLayer
    }
    
    internal func bind(_ reactor: PaymentQRScanReactor) {
        self.reactor = reactor
    }
}

extension QRReaderView {
    func makeUIWithStart() {
        self.initialSetupView()
        self.start()
    }
    
    func start() {
        captureSession?.startRunning()
    }
    
    func stop() {
        captureSession?.stopRunning()
    }
    
    func fail() {
        guard let _reactor = self.reactor else { return }
        captureSession = nil
        Observable.just(PaymentQRScanReactor.Action.loadChargingQR(""))
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    func found(qrData: String) {
        guard let _reactor = self.reactor else { return }
        Observable.just(PaymentQRScanReactor.Action.loadChargingQR(qrData))
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
    }
}

extension QRReaderView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {        
        stop()
        if let _metadataObject = metadataObjects.first, _metadataObject.type == .qr {
            guard let readableObject = _metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(qrData: stringValue)
        }
    }
}

//
//  BaseViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import SnapKit
import Then
import Material
import AVFoundation
import RxSwift

internal class BaseViewController: UIViewController {
    
    // MARK: VARIABLE
    
    internal var disposeBag = DisposeBag()
    internal let picker = UIImagePickerController()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
       let activitiIndicator = UIActivityIndicatorView()
        activitiIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activitiIndicator.center = self.view.center
        
        
        activitiIndicator.color = UIColor(named: "nt-5")
        activitiIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activitiIndicator.style = .large
        } else {
            // Fallback on earlier versions
        }
        
        activitiIndicator.stopAnimating()
        
        return activitiIndicator
    }()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // MARK: FUNC
    
    // 공통
    internal func openPhotoLib() {
        picker.sourceType = .photoLibrary
        self.present(picker, animated: false, completion: nil)
    }
    
    // 공통
    internal func openCamera() {        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined || status == .denied {
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { grated in
                if !grated {
                    self.showAuthAlert()
                }
            }
        } else if status == .authorized {
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // 공통
    private func showAuthAlert() {
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            Snackbar().show(message: "카메라 기능이 활성화되지 않았습니다.")
            self.navigationController?.pop()
        }
        
        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertAction.Style.default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        var actions = Array<UIAlertAction>()
        actions.append(cancelAction)
        actions.append(openAction)
        
        UIAlertController.showAlert(title: "카메라 기능이 활성화되지 않았습니다.", message: "사진추가를 위해 카메라 권한이 필요합니다.", actions: actions)
    }
    
    internal func prepareActionBar(with title: String) {
        navigationController?.isNavigationBarHidden = false
        
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "nt-9")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.text = title
    }
    
    @objc
    internal func backButtonTapped() {
        self.navigationController?.pop()
    }
}

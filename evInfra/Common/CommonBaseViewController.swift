//
//  CommonBaseViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import SnapKit
import Then

internal class CommonBaseViewController: UIViewController {
    // MARK: UI
    
    internal lazy var contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview($0)
        $0.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
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
            activitiIndicator.activityIndicatorViewStyle = .large
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
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
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            Snackbar().show(message: "카메라 기능이 활성화되지 않았습니다.")
            self.navigationController?.pop()
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
        
        UIAlertController.showAlert(title: "카메라 기능이 활성화되지 않았습니다.", message: "사진추가를 위해 카메라 권한이 필요합니다.", actions: actions)
    }       
}

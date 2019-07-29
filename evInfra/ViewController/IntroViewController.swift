//
//  IntroViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 13..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import Motion


class IntroViewController: UIViewController {

    @IBOutlet weak var progressLayer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var maxCount = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isNewBoardList = Array<Bool>()
    let fcmManager = FCMManager.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProgressLayer(isShow: false)
        prepareCompanyIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension IntroViewController: CompanyInfoCheckerDelegate {
    func prepareCompanyIcon() {
        let icChecker = CompanyIconChecker.init(delegate: self)
        icChecker.checkCompanyInfo()
    }
    
    func finishDownloadCompanyImage() {
        registerId()
    }
    
    func processDownloadFileSize(size: Int) {
        self.setProgressMaxCount(maxCount: size)
    }
    
    func processOnDownloadCompanyImage(count: Int) {
        self.setProgress(progressCount: count)
    }
    
    internal func setProgressMaxCount(maxCount: Int) {
        self.maxCount = maxCount
        if(self.maxCount == 0) {
            showProgressLayer(isShow: false)
        } else {
            showProgressLayer(isShow: true)
        }
    }
    
    internal func setProgress(progressCount: Int) {
        let rate = Float(progressCount) / Float(self.maxCount)
        self.progressBar.setProgress(rate, animated: true)
        self.progressLabel.text = "(\(progressCount)/\(self.maxCount))"
    }
    
    internal func showProgressLayer(isShow: Bool) {
        self.progressLayer.isHidden = !isShow
        self.progressBar.isHidden = !isShow
        self.progressLabel.isHidden = !isShow
    }
}

extension IntroViewController: NewArticleCheckDelegate {
    
    internal func checkLastBoardId() {
        let articleChecker = NewArticleChecker.sharedInstance
        articleChecker.delegate = self
        articleChecker.checkLastBoardId()
    }
    
    func finishCheckArticleFromServer() {
        self.finishedServerInit()
    }
}

extension IntroViewController {
    internal func registerId() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let modelName = UIDevice.current.modelName
        var uid: String? = nil
        if let dUid = KeyChainManager.get(key: KeyChainManager.KEY_DEVICE_UUID), !dUid.isEmpty {
            uid = dUid
        } else {
            uid = UIDevice.current.identifierForVendor!.uuidString
            KeyChainManager.set(value: uid!, forKey: KeyChainManager.KEY_DEVICE_UUID)
        }

        Server.registerUser(version: version, model: modelName, uid: uid!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let defaults = UserDefault()
                defaults.saveString(key: UserDefault.Key.MEMBER_ID, value: json["member_id"].stringValue)
                defaults.saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: json["receive_push"].boolValue)
                self.fcmManager.updateFCMInfo()
                self.checkLastBoardId()
            }
        }
    }
    
    internal func finishedServerInit() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        appDelegate.appToolbarController = AppToolbarController(rootViewController: mainViewController)
        appDelegate.appToolbarController.delegate = mainViewController
        let ndController = AppNavigationDrawerController(rootViewController: appDelegate.appToolbarController, leftViewController: leftViewController)
        self.navigationController?.setViewControllers([ndController], animated: true)
    }
}

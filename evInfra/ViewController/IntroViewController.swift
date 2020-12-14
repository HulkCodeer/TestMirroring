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
import FLAnimatedImage

class IntroViewController: UIViewController {

    @IBOutlet weak var progressLayer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet var imgIntroBackground: UIImageView!
    @IBOutlet var imgIntroFLAnimated: FLAnimatedImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let fcmManager = FCMManager.sharedInstance
    
    var isNewBoardList = Array<Bool>()
    var maxCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProgressLayer(isShow: false)
        if MemberManager.isPartnershipClient(clientId: MemberManager.RENT_CLIENT_SKR){
            imgIntroBackground.image = UIImage(named: "intro_skr_bg.jpg")
        } else {
            let currentMonth = Calendar.current.component(.month, from: Date())
            let monthOfWinter = Array(arrayLiteral: 1,2,12)
            if(monthOfWinter.contains(currentMonth)){
                imgIntroFLAnimated.animatedImage = FLAnimatedImage(gifResource: "evinfra_snow.gif")
                imgIntroBackground.isHidden = true
            }
        }
        ChargerManager.sharedInstance.getChargerCompanyInfo(listener: {
            
            class chargerManagerListener: ChargerManagerListener {

                var controller: IntroViewController?
                
                func onComplete() {
                    controller?.checkCompanyInfo()
                }
                
                func onError(errorMsg: String) {
                }
                
                required init(_ controller : IntroViewController) {
                    self.controller = controller
                }
            }
            
            return chargerManagerListener(self)
        } ())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FLAnimatedImage {
    convenience init(gifResource: String) {
        self.init(animatedGIFData: NSData(contentsOfFile: Bundle.main.path(forResource: gifResource, ofType: "")!) as Data?)
    }
}

extension IntroViewController: CompanyInfoCheckerDelegate {
    
    func checkCompanyInfo() {
        let icChecker = CompanyInfoChecker.init(delegate: self)
        icChecker.checkCompanyInfo()
    }
    
    func finishDownloadCompanyImage() {
        ImageMarker.loadMarkers()
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
        if self.maxCount == 0 {
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
                UserDefault().saveString(key: UserDefault.Key.MEMBER_ID, value: json["member_id"].stringValue)
                UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: json["receive_push"].boolValue)
                UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: json["receive_jeju_push"].boolValue)
                self.fcmManager.updateFCMInfo()
                self.checkLastBoardId()
            }
        }
    }
}

extension IntroViewController: NewArticleCheckDelegate {
    func finishCheckArticleFromServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.finishedServerInit()
        }
    }
    
    internal func checkLastBoardId() {
        let articleChecker = NewArticleChecker.sharedInstance
        articleChecker.delegate = self
        articleChecker.checkLastBoardId()
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

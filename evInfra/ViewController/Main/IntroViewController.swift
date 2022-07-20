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
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProgressLayer(isShow: false)
        showIntro()
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

extension IntroViewController: IntroImageCheckerDelegate {
    func showIntro(){
        if MemberManager.shared.isPartnershipClient(clientId: RentClientType.skr.rawValue){
            imgIntroBackground.image = UIImage(named: "intro_skr_bg.jpg")
        } else {
            let checker = IntroImageChecker.init(delegate: self)
            checker.getIntroImage()
        }
    }
    
    func finishCheckIntro(imgName : String, path : String){
        print(imgName)
        if imgName.hasSuffix(".gif"){
            let gifData = NSData(contentsOfFile: path)
            DispatchQueue.main.async {
                self.imgIntroFLAnimated.animatedImage = FLAnimatedImage(animatedGIFData: gifData as Data?)
                self.imgIntroBackground.isHidden = true
            }
        } else if imgName.hasSuffix(".jpg") {
            imgIntroBackground.image = UIImage(contentsOfFile: path)
        }
    }
    
    func showDefaultImage(){
        imgIntroBackground.image = UIImage(named: "intro_bg.jpg")
    }
}

extension IntroViewController: CompanyInfoCheckerDelegate {
    
    func checkCompanyInfo() {
        let icChecker = CompanyInfoChecker.init(delegate: self)
        icChecker.checkCompanyInfo()
    }
    
    func finishDownloadCompanyImage() {
        ImageMarker.loadMarkers()
        checkLastBoardId()
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
}

extension IntroViewController: BoardDelegate {
    func complete() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.finishedServerInit()
        }
    }
    
    internal func checkLastBoardId() {
        let articleChecker = Board.sharedInstance
        articleChecker.delegate = self
        articleChecker.checkLastBoardId()
    }
    
    internal func finishedServerInit() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(ofType: MainViewController.self)
        let leftViewController = storyboard.instantiateViewController(ofType: LeftViewController.self)
        appDelegate.appToolbarController = AppToolbarController(rootViewController: mainViewController)
        appDelegate.appToolbarController.delegate = mainViewController
        let ndController = AppNavigationDrawerController(rootViewController: appDelegate.appToolbarController, leftViewController: leftViewController)
        GlobalDefine.shared.mainNavi?.setViewControllers([ndController], animated: true)        
    }
}

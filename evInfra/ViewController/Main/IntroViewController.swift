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
import RxSwift
import RxCocoa

internal final class IntroViewController: UIViewController {

    // MARK: UI
    
    @IBOutlet weak var progressLayer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet var imgIntroBackground: UIImageView!
    @IBOutlet var imgIntroFLAnimated: FLAnimatedImageView!
        
    // MARK: VARIABLE
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let fcmManager = FCMManager.sharedInstance
    
    var isNewBoardList = Array<Bool>()
    var maxCount = 0
    
    private let disposeBag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just(GlobalAdsReactor.Action.loadStartBanner)
            .bind(to: GlobalAdsReactor.sharedInstance.action)
            .disposed(by: disposeBag)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "인트로 화면"
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
        printLog(out: "\(imgName)")
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
    
    private func checkLastBoardId() {
        Server.getBoardData { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    printLog(out: "\(json)")
                    let latestId = JSON(json["latest_id"])
                    
                    Board.sharedInstance.latestBoardIds.removeAll()
                    
                    Board.sharedInstance.freeBoardId = latestId["free"].intValue
                    Board.sharedInstance.chargeBoardId = latestId["charger"].intValue
                    
                    Board.sharedInstance.latestBoardIds[Board.KEY_NOTICE] = latestId["notice"].intValue
                    Board.sharedInstance.latestBoardIds[Board.KEY_FREE_BOARD] = Board.sharedInstance.freeBoardId
                    Board.sharedInstance.latestBoardIds[Board.KEY_CHARGER_BOARD] = Board.sharedInstance.chargeBoardId
                    Board.sharedInstance.latestBoardIds[Board.KEY_EVENT] = latestId["event"].intValue
                    
                    let companyArr = JSON(json["company_list"]).arrayValue
                    for company in companyArr {
                        let boardNewInfo = BoardInfo()
                        
                        let bmId = company["bm_id"].intValue
                        let boardTitle = company["title"].stringValue
                        let shardKey = company["key"].stringValue
                        let brdId = company["brd_id"].intValue
                        
                        boardNewInfo.bmId = bmId
                        boardNewInfo.boardTitle = boardTitle
                        boardNewInfo.shardKey = shardKey
                        boardNewInfo.brdId = brdId
                        
                        Board.sharedInstance.brdNewInfo.append(boardNewInfo)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainViewController = storyboard.instantiateViewController(ofType: MainViewController.self)
                        let leftViewController = storyboard.instantiateViewController(ofType: LeftViewController.self)
                        self.appDelegate.appToolbarController = AppToolbarController(rootViewController: mainViewController)
                        self.appDelegate.appToolbarController.delegate = mainViewController
                        let ndController = AppNavigationDrawerController(rootViewController: self.appDelegate.appToolbarController, leftViewController: leftViewController)
                        GlobalDefine.shared.mainNavi?.setViewControllers([ndController], animated: true)
                    }
                }
                
            }
        }
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

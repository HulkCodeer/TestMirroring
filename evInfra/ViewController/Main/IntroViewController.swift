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
import Alamofire

internal final class IntroViewController: UIViewController {

    // MARK: UI
    
    @IBOutlet weak var progressLayer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet var imgIntroBackground: UIImageView!
    @IBOutlet var imgIntroFLAnimated: FLAnimatedImageView!
        
    // MARK: VARIABLE
                    
    private var maxCount = 0
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
    
    // MARK: FUNC
    
    func showIntro(){
        if MemberManager.shared.isPartnershipClient(clientId: RentClientType.skr.rawValue){
            imgIntroBackground.image = UIImage(named: "intro_skr_bg.jpg")
        } else {
            self.getIntroImage()
        }
    }
    
    func getIntroImage() {
        let imgName = UserDefault().readString(key: UserDefault.Key.APP_INTRO_IMAGE)
        let endDate = UserDefault().readString(key: UserDefault.Key.APP_INTRO_END_DATE)
        if !imgName.isEmpty , !Date().isPassedDate(date: endDate){
            if EVFileManager.sharedInstance.isFileExist(named : imgName){
                let path = EVFileManager.sharedInstance.getFilePath(named: imgName)
                self.finishCheckIntro(imgName: imgName, path : path)
            } else {
                self.finishCheckIntro()
            }
        } else {
            self.finishCheckIntro()
        }
    }
                
    private func finishCheckIntro(imgName : String, path : String){
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
    
    private func finishCheckIntro(){
        imgIntroBackground.image = UIImage(named: "intro_bg.jpg")
    }
    
    private func checkLastBoardId() {
        Server.getBoardData { [weak self] (isSuccess, value) in
            guard let self = self else { return }
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
                }
            }
            
            CLLocationManager().rx.isEnabled
                .subscribe(with: self) { obj, isEnable in
                    guard !isEnable else { return }
                    CLLocationManager().requestWhenInUseAuthorization()
                }
                .disposed(by: self.disposeBag)
            
            if FCMManager.sharedInstance.originalMemberId.isEmpty {
                self.movePerminssonsGuideView()                
            } else {
                self.moveMainView()
            }
        }        
    }
    
    private func moveMainView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reactor = MainReactor(provider: RestApi())
        let mainViewcon = storyboard.instantiateViewController(ofType: MainViewController.self)
        mainViewcon.reactor = reactor
        let letfViewcon = storyboard.instantiateViewController(ofType: LeftViewController.self)
        
        let appToolbarController = AppToolbarController(rootViewController: mainViewcon)
        appToolbarController.delegate = mainViewcon
        let ndController = AppNavigationDrawerController(rootViewController: appToolbarController, leftViewController: letfViewcon)
        GlobalDefine.shared.mainNavi?.setViewControllers([ndController], animated: true)
    }
    
    private func movePerminssonsGuideView() {
        let reactor = PermissionsGuideReactor(provider: RestApi())
        let viewcon = PermissionsGuideViewController(reactor: reactor)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
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

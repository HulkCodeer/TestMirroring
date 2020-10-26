//
//  OfferwallViewController.swift
//  evInfra
//
//  Created by Michael Lee on 2020/01/30.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit
import Material
import GoogleMobileAds
import SwiftyJSON
import MoPub

class OfferwallViewController: UIViewController, MPRewardedVideoDelegate {
    
    @IBOutlet var lbMyBerryTitle: UILabel!
    @IBOutlet var guideTableView: UITableView!
    //  expandable
    @IBOutlet var expandInfoBtn: UIView!                    // 베리란?(btn)
    @IBOutlet var expandInfoView: UIView!                   // 베리설명(view)
    @IBOutlet var expandInfoHeight: NSLayoutConstraint!     // 베리설명(height)
    @IBOutlet var expandHowToBtn: UIView!                   // 베리사용방법(btn)
    @IBOutlet var expandHowToView: UIView!                  // 베리사용설명(view)
    @IBOutlet var expandHowToHeight: NSLayoutConstraint!    // 베리사용설명(height)
    @IBOutlet var expandNoticeBtn: UIView!                  // 유의사항(btn)
    @IBOutlet var expandNoticeView: UIView!                 // 유의사항(view)
    @IBOutlet var expandNoticeHeight: NSLayoutConstraint!   // 유의사항(height)
    
    @IBOutlet var infoBtnImg: UIImageView!
    @IBOutlet var howToBtnImg: UIImageView!
    @IBOutlet var noticBtnImg: UIImageView!
    
    @IBOutlet var expandInfoLb: UILabel!
    @IBOutlet var expandHowToLb: UILabel!
    @IBOutlet var expandNoticeLb: UILabel!
    
    
    @IBOutlet var infoViewHeight: NSLayoutConstraint!
    @IBOutlet var howToHeight: NSLayoutConstraint!
    @IBOutlet var noticeHeight: NSLayoutConstraint!
    
    @IBOutlet var scrollView: UIScrollView!
    
    private let appID = "ca-app-pub-4857867142176465~5053865371";   // admob app id
    private let placeID = "ca-app-pub-4857867142176465/5258173998"; // admob reward id
    private let testID = "ca-app-pub-3940256099942544/1712485313";  // admob test id
    
    private let kAdUnitId = "657d0a18465e49868563a4cd2ed266bf"
    
    /**
     * Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil
    
    //
    var sumHeight:CGFloat = 0
    var willHide: Bool = false
    var viewName:String = ""
    
    override func viewDidLoad() {
        prepareActionBar()
        prepareView()
        self.scrollView.delegate = self
    }
    
    deinit {
        MPRewardedVideo.removeDelegate(forAdUnitId: self.kAdUnitId)
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "베리충전소"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        
        MPRewardedVideo.setDelegate(self, forAdUnitId: self.kAdUnitId)
        checkAndInitializeSdk()

        lbMyBerryTitle.roundCorners(.allCorners, radius: 9)
        
        setExpandViewConstant()
        prepareExpandView()
    }
    
    func setExpandViewConstant() {
        self.expandInfoHeight.constant = scrollView.expandableView(view: self.expandInfoView, btnHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
        
        self.expandHowToHeight.constant = scrollView.expandableView(view: self.expandHowToView, btnHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
        
        self.expandNoticeHeight.constant = scrollView.expandableView(view: self.expandNoticeView, btnHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
    }
    
    func prepareExpandView() {
        // view clickEvent
        let infoGesture = UITapGestureRecognizer(target: self, action: #selector(onClickInfoExpand(sender:)))
        let howToGesture = UITapGestureRecognizer(target: self, action: #selector(onClickHowToExpand(sender:)))
        let noticeGesture = UITapGestureRecognizer(target: self, action: #selector(onClickNoticeExpand(sender:)))
        self.expandInfoBtn.addGestureRecognizer(infoGesture)
        self.expandHowToBtn.addGestureRecognizer(howToGesture)
        self.expandNoticeBtn.addGestureRecognizer(noticeGesture)
        
        // view setText
        let info =
            "Ev Infra의 운영사인 (주)소프트베리에서 따온 이름으로, \n사용자 여러분께 충전의 즐거움을 만족시켜 드릴 수 있도록 \n사용되는 포인트 단위를 말합니다. \n앱 내 동영상 광고, 또는 충전 시 \n적립(한전운영 충전기에 한함)가능하며 \n사용도 바로 하실 수 있습니다."
        let howTo =
            "1) 충전 진행화면 하단의 '베리 사용하기' 버튼을 클릭"
        let notice =
            "1) 이용 가능한 충전소 - 한전, GS칼텍스 \n위의 운영기관에서 운영중인 충전소에서만 \n베리 사용이 가능합니다.\n2) 베리는 충전 하는 중에 사용해야 합니다. (충전 이전 이나 충전 후 사용 불가)\n3) 사용하신 베리의 환불은 불가합니다. \n4) 충전중 베리사용시 최종 충전금액에서 사용하신 베리만큼 차감 후 결제됩니다. \n5) 기타 문의사항은 Ev Infra 고객센터 070-8633-9009로 문의주시기 바랍니다."
        self.expandInfoLb.text = info
        self.expandHowToLb.text = howTo
        self.expandNoticeLb.text = notice
    }
    
    @objc func onClickInfoExpand(sender: UITapGestureRecognizer) {
        if !self.expandInfoView.isHidden{
            // close
            self.willHide = true
            self.viewName = "info"
            sumHeight -= self.expandInfoHeight.constant
            
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if self.expandNoticeView.isHidden == true && self.expandHowToView.isHidden == true && self.expandInfoView.isHidden == true {
                sumHeight = 0
                scrollView.setContentOffset(bottomOffset, animated: true)
            }else{
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }else{
            self.willHide = false
            self.expandInfoHeight.constant = scrollView.expandableView(view: self.expandInfoView, btnHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
            // open
            sumHeight += self.expandInfoHeight.constant
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @objc func onClickHowToExpand(sender: UITapGestureRecognizer){
        if !self.expandHowToView.isHidden{
            self.willHide = true
            self.viewName = "howTo"
            // close
            sumHeight -= self.expandHowToHeight.constant
            
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if self.expandNoticeView.isHidden == true && self.expandHowToView.isHidden == true && self.expandInfoView.isHidden == true {
                sumHeight = 0
                scrollView.setContentOffset(bottomOffset, animated: true)
            }else{
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }else{
            self.willHide = false
            self.expandHowToHeight.constant = scrollView.expandableView(view: self.expandHowToView, btnHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
            // open
            sumHeight += self.expandHowToHeight.constant
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @objc func onClickNoticeExpand(sender: UITapGestureRecognizer){
        var noticeSumHeight:CGFloat = 0
        if !self.expandNoticeView.isHidden{
            self.willHide = true
            self.viewName = "notice"
            // close
            sumHeight -= self.expandNoticeHeight.constant
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if self.expandNoticeView.isHidden == true && self.expandHowToView.isHidden == true && self.expandInfoView.isHidden == true {
                sumHeight = 0
                scrollView.setContentOffset(bottomOffset, animated: true)
            }else{
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
            sumHeight -= noticeSumHeight
        }else{
            self.willHide = false
            self.expandNoticeHeight.constant = scrollView.expandableView(view: self.expandNoticeView, btnHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
            
            // open
            if sumHeight <= 0 {
                noticeSumHeight += self.expandNoticeBtn.layer.height+16
            }
            noticeSumHeight += self.expandNoticeHeight.constant
            sumHeight += noticeSumHeight
            
            let bottomOffset = CGPoint(x: 0, y: sumHeight)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @IBAction func onClickAdmobAd(_ sender: Any) {
        
        Server.postCheckRewardVideoAvailable { (isSuccess, value) in
            
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    if MPRewardedVideo.hasAdAvailable(forAdUnitID: self.kAdUnitId) {
                        guard let reward: MPRewardedVideoReward = MPRewardedVideo.selectedReward(forAdUnitID: self.kAdUnitId) else {
                            self.selectedReward = nil
                            return
                        }
                        
                        self.selectedReward = reward
                        MPRewardedVideo.presentAd(forAdUnitID: self.kAdUnitId, from: self, with: self.selectedReward, customData: String(MemberManager.getMbId()))
                    } else {
                        Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
                    }
                } else {
                    Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
                }
            } else {
                Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
            }
        }
    }
    
    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        
        let amount = reward.amount
        let type = reward.type
 
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        Server.postRewardVideo(type: type, amount: Int(truncating: amount)){ (isSuccess, value) in
            //sendNotification(amount)
        }
    }
    
    /**
    Check if the Canary app has a cached ad unit ID for consent. If not, the app will present an alert dialog allowing custom ad unit ID entry.
    - Parameter containerViewController: the main container view controller
    - Parameter userDefaults: the target `UserDefaults` instance
    */
    func checkAndInitializeSdk(mopub: MoPub = .sharedInstance()) {
        // Production should only use the default ad unit ID.
        if (mopub.isSdkInitialized){
            self.loadRewardedVideo()
        }else{
            self.initializeMoPubSdk(adUnitIdForConsent: self.kAdUnitId)
        }
    }

    /**
    Initializes the MoPub SDK with the given ad unit ID used for consent management.
    - Parameter adUnitIdForConsent: This value must be a valid ad unit ID associated with your app.
    - Parameter containerViewController: the main container view controller
    - Parameter mopub: the target `MoPub` instance
    */
    func initializeMoPubSdk(adUnitIdForConsent: String,
                            mopub: MoPub = .sharedInstance()) {
        // MoPub SDK initialization
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForConsent)
        sdkConfig.globalMediationSettings = []
        sdkConfig.loggingLevel = .info
            
        mopub.initializeSdk(with: sdkConfig) {
            // Update the state of the menu now that the SDK has completed initialization.
            self.loadRewardedVideo()
        }
    }
    
    func loadRewardedVideo() {
        DispatchQueue.main.async {
            MPRewardedVideo.loadAd(withAdUnitID: self.kAdUnitId, withMediationSettings: nil)
        }
    }
    
    // mopub delegate
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        print("Loading Succeeded")
    }
    
    func rewardedVideoAdDidAppear(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdDidAppear")
    }
    
    func rewardedVideoAdDidExpire(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdDidExpire")
    }
    
    func rewardedVideoAdWillAppear(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdWillAppear")
    }
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdDidDisappear")
        loadRewardedVideo()
    }
    
    func rewardedVideoAdWillDisappear(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdWillDisappear")
    }
    
    func rewardedVideoAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdDidReceiveTapEvent")
    }
    
    func rewardedVideoAdWillLeaveApplication(forAdUnitID adUnitID: String!) {
        print("rewardedVideoAdWillLeaveApplication")
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedVideoAdDidFailToLoad")
    }
    
    func rewardedVideoAdDidFailToPlay(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedVideoAdDidFailToPlay")
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        print("rewardedVideoAdShouldReward")
    }
}

extension OfferwallViewController: UIScrollViewDelegate{
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.willHide {
            switch self.viewName {
            case "info":
                self.expandInfoHeight.constant = scrollView.expandableView(view: self.expandInfoView, btnHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
//                self.infoViewHeight.constant = scrollView.expandableView(view: self.expandInfoView, btnHeight: self.infoViewHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
                break
            case "howTo":
                self.expandHowToHeight.constant = scrollView.expandableView(view: self.expandHowToView, btnHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
//                self.infoViewHeight.constant = scrollView.expandableView(view: self.expandInfoView, btnHeight: self.howToHeight.constant, viewHeight: self.howToHeight.constant, imgView: infoBtnImg)
                break
            case "notice":
                self.expandNoticeHeight.constant = scrollView.expandableView(view: self.expandNoticeView, btnHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
                break
            default:
                break
            }
        }
    }
}

//extension OfferwallViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func prepareTableView() {
//        guideTableView.delegate = self
//        guideTableView.dataSource = self
//        
//        guideTableView.autoresizingMask = UIViewAutoresizing.flexibleHeight
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        print("parkshin numberOfSections")
//        return 3
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }
//    
//    // Set tableView height, scrollView heigth
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        print("parkshin estimatedHeightForRowAt")
//        return 60
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print("parkshin heightForRowAt")
//        return UITableViewAutomaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("parkshin numberOfRowsInSection")
//        return 11
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("parkshin cellForRowAt")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferwallTableViewCell")!
////        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferwallTableViewCell") as! OfferwallTableViewCell
//        
//        return cell
//    }
//}

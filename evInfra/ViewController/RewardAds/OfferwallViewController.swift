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

class OfferwallViewController: UIViewController, MPRewardedVideoDelegate{
    
    let appID = "ca-app-pub-4857867142176465~5053865371";   // admob app id
    let placeID = "ca-app-pub-4857867142176465/5258173998"; // admob reward id
    let testID = "ca-app-pub-3940256099942544/1712485313";  // admob test id
    
    private let kAdUnitId = "657d0a18465e49868563a4cd2ed266bf"
    
    /**
     Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil

    
    @IBOutlet weak var offerwallContainer: UIView!
    //var mRewardedAd: GADRewardedAd?
    
    @IBOutlet weak var mBtnRewardAdmob: UIButton!
    override func viewDidLoad() {
    
        prepareActionBar();
        prepareView();
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
        navigationItem.titleLabel.text = "베리 충전"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        mBtnRewardAdmob.isHidden = true
        MPRewardedVideo.setDelegate(self, forAdUnitId: self.kAdUnitId)
        checkAndInitializeSdk()
        
        //mRewardedAd = createAndLoadRewardedAd();
        //initOfferwall();
    }
    
    func initOfferwall(){
//
//        // 오퍼월 테마 색상 변경
//        AdPopcornStyle.sharedInstance().adPopcornCustomThemeColor = UIColor(hexString:"#472a2bff");
//
//        // 오퍼월 로고 변경
//        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleLogoPath = nil
//
//        // 오퍼월 타이틀 변경
//        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitle = "베리 충전소";
//
//        // 오퍼월 타이틀 색상 변경
//        AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleColor = UIColor.red;
//
//        // 오퍼월 Top/bottom bar 색상 변경
//        //AdPopcornStyle.sharedInstance().adPopcornCustomOfferwallTitleBackgroundColor = UIColor.white;
//
//        let adPopcornVC:AdPopcornAdListViewController = AdPopcornAdListViewController();
//        adPopcornVC.setViewModeWidthSize(self.offerwallContainer.bounds.width);
//        adPopcornVC.setViewModeHeightSize(self.offerwallContainer.bounds.height);
//
//        let navigationController = UINavigationController()
//        navigationController.addChildViewController(adPopcornVC)
//
//        self.addChildViewController(navigationController);
//        self.offerwallContainer.addSubview(navigationController.view);
//
//        //adPopcornVC.didMove(toParentViewController: self)
//
//        adPopcornVC.setViewModeImpression();
//        AdPopcornOfferwall.shared()?.delegate = self
    }
    
     // load admob
//    func createAndLoadRewardedAd() -> GADRewardedAd{
//        let rewardedAd = GADRewardedAd(adUnitID: testID)
//
//        mBtnRewardAdmob.isHidden = true
//
//        rewardedAd.load(GADRequest()) { error in
//            if let error = error {
//                print("Loading failed: \(error)")
//            } else {
//                print("Loading Succeeded")
//                if self.mRewardedAd?.isReady == true {
//                    self.mBtnRewardAdmob.isHidden = false
//                }
//            }
//        }
//        return rewardedAd
//    }
    
    @IBAction func onClickAdmobAd(_ sender: Any) {
        if (MPRewardedVideo.hasAdAvailable(forAdUnitID: self.kAdUnitId)){
            guard let reward: MPRewardedVideoReward = MPRewardedVideo.selectedReward(forAdUnitID: self.kAdUnitId) else {
                selectedReward = nil
                return
            }
            
            selectedReward = reward
            MPRewardedVideo.presentAd(forAdUnitID: self.kAdUnitId, from: self, with: self.selectedReward, customData: String(MemberManager.getMbId()))
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
    
    
    // admob delegate
    /// Tells the delegate that the rewarded ad was presented.
//    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
//      print("Rewarded ad presented.")
//    }
//    /// Tells the delegate that the rewarded ad was dismissed.
//    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
//        mRewardedAd = createAndLoadRewardedAd();
//      print("Rewarded ad dismissed.")
//    }
//    /// Tells the delegate that the rewarded ad failed to present.
//    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
//      print("Rewarded ad failed to present.")
//    }
    
//    // adpopcorn delegate
//    func offerwallTotalRewardInfo(_ queryResult: Bool, totalCount count: Int, totalReward reward: String!) {
//        print("Offerwall : " + reward + " : \(count) : \(queryResult)")
//    }
    
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
    
    
    func loadRewardedVideo(){
        DispatchQueue.main.async {
            MPRewardedVideo.loadAd(withAdUnitID: self.kAdUnitId, withMediationSettings: nil)
        }
    }
    
    // mopub delegate
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        print("Loading Succeeded")
        self.mBtnRewardAdmob.isHidden = false
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
        self.mBtnRewardAdmob.isHidden = true
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

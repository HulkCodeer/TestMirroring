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
    
    @IBOutlet var scrollView: UIScrollView!
    
    //  expandable
    @IBOutlet var expandInfoBtn: UIView!                    // 베리란?(btn)
    @IBOutlet var expandInfoView: UIView!                   // 베리설명(view)
    @IBOutlet var expandInfoLb: UILabel!                    // 베리설명(lb)
    @IBOutlet var expandInfoHeight: NSLayoutConstraint!     // 베리설명(view 전체 높이)
    @IBOutlet var infoViewHeight: NSLayoutConstraint!       // 베리설명(inner view 높이)
    
    @IBOutlet var expandHowToBtn: UIView!                   // 베리사용방법(btn)
    @IBOutlet var expandHowToView: UIView!                  // 베리사용설명(view)
    @IBOutlet var howToStackView: UIStackView!              // 베리사용설명(inner view)
    @IBOutlet var howToView1: UIStackView!                  // 베리사용설명(1)
    @IBOutlet var howToView2: UIStackView!                  // 베리사용설명(2)
    @IBOutlet var howToView3: UIStackView!                  // 베리사용설명(3)
    @IBOutlet var expandHowToHeight: NSLayoutConstraint!    // 베리사용설명(view 전체 높이)
    @IBOutlet var howToHeight: NSLayoutConstraint!          // 베리사용설명(inner view 높이)
    
    @IBOutlet var expandNoticeBtn: UIView!                  // 유의사항(btn)
    @IBOutlet var expandNoticeView: UIView!                 // 유의사항(view)
    @IBOutlet var expandNoticeLb: UILabel!                  // 유의사항(lb)
    @IBOutlet var expandNoticeHeight: NSLayoutConstraint!   // 유의사항(view 전체 높이)
    @IBOutlet var noticeHeight: NSLayoutConstraint!         // 유의사항(inner view 높이)
    
    @IBOutlet var infoBtnImg: UIImageView!
    @IBOutlet var howToBtnImg: UIImageView!
    @IBOutlet var noticBtnImg: UIImageView!
    
    @IBOutlet var useTitleLb: UILabel!
    
    private let appID = "ca-app-pub-4857867142176465~5053865371";   // admob app id
    private let placeID = "ca-app-pub-4857867142176465/5258173998"; // admob reward id
    private let testID = "ca-app-pub-3940256099942544/1712485313";  // admob test id
    
    private let kAdUnitId = "657d0a18465e49868563a4cd2ed266bf"
    
    /**
     * Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil
    
    var scrollYPosition:CGFloat = 0
    var scrollIsTop:Bool = false
    var isOpen: Bool = false
    var viewName:String = ""
    let screenHeight:CGFloat = UIScreen.main.bounds.size.height
    let screenWidth:CGFloat = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        prepareActionBar()
        prepareView()
        self.scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        prepareStackView()
    }
    
    func setExpandViewConstant() {
        self.expandInfoHeight.constant = scrollView.showOrHideView(view: self.expandInfoView, expandHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
        
        self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
        
        self.expandNoticeHeight.constant = scrollView.showOrHideView(view: self.expandNoticeView, expandHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
    }
    
    func prepareExpandView() {
        // ClickEvent
        let infoGesture = UITapGestureRecognizer(target: self, action: #selector(onClickInfoExpand(sender:)))
        let howToGesture = UITapGestureRecognizer(target: self, action: #selector(onClickHowToExpand(sender:)))
        let noticeGesture = UITapGestureRecognizer(target: self, action: #selector(onClickNoticeExpand(sender:)))
        self.expandInfoBtn.addGestureRecognizer(infoGesture)
        self.expandHowToBtn.addGestureRecognizer(howToGesture)
        self.expandNoticeBtn.addGestureRecognizer(noticeGesture)
        
        // SetText
        let info =
            "Ev Infra의 운영사인 (주)소프트베리에서 따온 이름으로, \n사용자 여러분께 충전의 즐거움을 만족시켜 드릴 수 있도록 \n사용되는 포인트 단위를 말합니다. \n앱 내 동영상 광고, 또는 충전 시 \n적립(한전운영 충전기에 한함)가능하며 \n사용도 바로 하실 수 있습니다."
        let notice =
            "1) 이용 가능한 충전소 - 한전, GS칼텍스 \n위의 운영기관에서 운영중인 충전소에서만 \n베리 사용이 가능합니다.\n2) 베리는 충전 하는 중에 사용해야 합니다. (충전 이전 이나 충전 후 사용 불가)\n3) 사용하신 베리의 환불은 불가합니다. \n4) 충전중 베리사용시 최종 충전금액에서 사용하신 베리만큼 차감 후 결제됩니다. \n5) 기타 문의사항은 Ev Infra 고객센터 070-8633-9009로 문의주시기 바랍니다."
        self.expandInfoLb.text = info
        self.expandNoticeLb.text = notice
    }
    
    func prepareStackView() {
        // prepare expandView(howTo_stackView "베리 사용방법")
        
        // Lb)
        let howToLb = UILabel()
        howToLb.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        howToLb.heightAnchor.constraint(equalToConstant: 20).isActive = true
        howToLb.text = "1) 충전 진행화면 하단의 '베리 사용하기' 버튼을 클릭"
        howToLb.fontSize = 16
        howToLb.textColor = UIColor(hex: "#333333")
        
        // Image) 340 * 472
        let howToImgView1 = UIImageView()
        
        howToImgView1.heightAnchor.constraint(equalToConstant: UIImage(named: "howtouse_point")?.size.height ?? 472).isActive = true
        howToImgView1.widthAnchor.constraint(equalToConstant: UIImage(named: "howtouse_point")?.size.width ?? 340).isActive = true
        howToImgView1.image = UIImage(named: "howtouse_point")
        
        // Lb)
        let howToLb1 = UILabel()
        howToLb1.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        howToLb1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        howToLb1.text = "2) 사용하실 베리를 작성"
        howToLb1.fontSize = 16
        howToLb1.textColor = UIColor(hex: "#333333")
    
        
        // Image) 340 * 472
        let howToImgView2 = UIImageView()
        howToImgView2.heightAnchor.constraint(equalToConstant: UIImage(named: "howtouse_point_1")?.size.height ?? 472).isActive = true
        howToImgView2.widthAnchor.constraint(equalToConstant: UIImage(named: "howtouse_point_1")?.size.width ?? 340).isActive = true
        howToImgView2.image = UIImage(named: "howtouse_point_1")
        
        // Lb)
        let howToLb2 = UILabel()
        howToLb2.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        howToLb2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        howToLb2.text = "3) 팝업창의 베리사용하기 버튼을 누르면 사용 완료!"
        howToLb2.fontSize = 16
        howToLb2.textColor = UIColor(hex: "#333333")
        
        // Image) 340 * 472
        let howToImgView3 = UIImageView()
        howToImgView3.heightAnchor.constraint(equalToConstant:  UIImage(named: "howtouse_point_2")?.size.height ?? 504).isActive = true
        howToImgView3.widthAnchor.constraint(equalToConstant: UIImage(named: "howtouse_point_2")?.size.width ?? 340).isActive = true
        howToImgView3.image = UIImage(named: "howtouse_point_2")
        
        // Lb)
        let howToLb3 = UILabel()
        howToLb3.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        howToLb3.heightAnchor.constraint(equalToConstant: 50).isActive = true
        howToLb3.text = "4) 이후 베리와 관련된 내역은 메인메뉴 > 마이페이지 \n> PAY > 베리 조회에서 확인하실 수 있습니다. "
        howToLb3.numberOfLines = 0
        howToLb3.fontSize = 16
        howToLb3.textColor = UIColor(hex: "#333333")
        
        // AddView to stackview
        howToView1.addArrangedSubview(howToLb)
        howToView1.addArrangedSubview(howToImgView1)
        howToView2.addArrangedSubview(howToLb1)
        howToView2.addArrangedSubview(howToImgView2)
        howToView3.addArrangedSubview(howToLb2)
        howToView3.addArrangedSubview(howToImgView3)
        howToView3.addArrangedSubview(howToLb3)
        
        howToView1.translatesAutoresizingMaskIntoConstraints = false
        howToView2.translatesAutoresizingMaskIntoConstraints = false
        howToView3.translatesAutoresizingMaskIntoConstraints = false
    
        var height = UIImage(named: "howtouse_point")?.size.height ?? 0
        height += UIImage(named: "howtouse_point_1")?.size.height ?? 0
        height += UIImage(named: "howtouse_point_2")?.size.height ?? 0
        height += 110 //lb
        // For constant test_1900
//        self.howToHeight.constant = expandHowToView.bounds.height*3+300
//        self.expandHowToHeight.constant = 1900
        self.howToHeight.constant = 1900
    }
    
    @objc func onClickInfoExpand(sender: UITapGestureRecognizer) {
        if !self.expandInfoView.isHidden{
            // Close
            self.isOpen = true
            self.viewName = "info"
            if self.expandNoticeView.isHidden == true && self.expandHowToView.isHidden == true || self.scrollYPosition == 0{
                if scrollYPosition == 0 {
                    scrollYPosition = self.expandNoticeBtn.layer.height+16
                    self.expandInfoHeight.constant = scrollView.showOrHideView(view: self.expandInfoView, expandHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
                }else{
                    // Scroll to top
                    scrollYPosition = self.expandNoticeBtn.layer.height+16
                }
            }else{
                // Gone howToView
                scrollYPosition -= self.expandInfoHeight.constant
            }
            let bottomOffset = CGPoint(x: 0, y: scrollYPosition)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }else{
            // Open
            self.isOpen = false
            self.expandInfoHeight.constant = scrollView.showOrHideView(view: self.expandInfoView, expandHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)
            // Scroll to bottom
            scrollYPosition += self.expandInfoHeight.constant
            let bottomOffset = CGPoint(x: 0, y: scrollYPosition)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @objc func onClickHowToExpand(sender: UITapGestureRecognizer){
        if !self.expandHowToView.isHidden{
            // Close
            self.isOpen = true
            self.viewName = "howTo"
            if self.expandNoticeView.isHidden == true && self.expandInfoView.isHidden == true || self.scrollYPosition == 0{
                if scrollIsTop {
                    self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
                }else{
                    // Scroll to top
//                    scrollYPosition = 0
//                    scrollYPosition = self.expandNoticeBtn.layer.height+16

//                    self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
                    
                    self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
                    
                    self.scrollView.contentSize = CGSize(width: 200.0, height: self.useTitleLb.frame.origin.y)
                    
                    // Scroll to bottom
                    scrollView.scrollToView(view: self.useTitleLb)
                    
                }
            }else{
                // Gone howToView
//                scrollYPosition -= self.expandHowToHeight.constant
            }

        }else{
            // Open
            self.isOpen = false
            // View show
            self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
            
            self.scrollView.contentSize = CGSize(width: 200.0, height: self.expandHowToView.frame.origin.y + self.expandHowToHeight.constant)
            
            // Scroll to bottom
            scrollView.scrollToView(view: self.useTitleLb)
        }
    }
    
    @objc func onClickNoticeExpand(sender: UITapGestureRecognizer){
        var noticeSumHeight:CGFloat = 0
        if !self.expandNoticeView.isHidden{
            // Close
            self.isOpen = true
            self.viewName = "notice"
            if self.expandHowToView.isHidden == true && self.expandInfoView.isHidden == true || self.scrollYPosition == 0{
                if scrollYPosition == 0 {
                    scrollYPosition = self.expandNoticeBtn.layer.height+16
                    self.expandNoticeHeight.constant = scrollView.showOrHideView(view: self.expandNoticeView, expandHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
                }else{
                    // Scroll to top
//                    scrollYPosition = 0
                    scrollYPosition = self.expandNoticeBtn.layer.height+16
                }
            }else{
                // Gone howToView
                scrollYPosition -= self.expandNoticeHeight.constant
            }
            let bottomOffset = CGPoint(x: 0, y: scrollYPosition)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }else{
            // Open
            self.isOpen = false
            self.expandNoticeHeight.constant = scrollView.showOrHideView(view: self.expandNoticeView, expandHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
            // Scroll to bottom
            if scrollYPosition <= 0 {
                noticeSumHeight += self.expandNoticeBtn.layer.height+16
            }
            noticeSumHeight += self.expandNoticeHeight.constant
            scrollYPosition += noticeSumHeight
            
            let bottomOffset = CGPoint(x: 0, y: scrollYPosition)
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
        if self.isOpen {
            // Close
            switch self.viewName {
            case "info":
                self.expandInfoHeight.constant = scrollView.showOrHideView(view: self.expandInfoView, expandHeight: self.expandInfoHeight.constant, viewHeight: self.infoViewHeight.constant, imgView: infoBtnImg)

                break
            case "howTo":
                
//                self.expandHowToHeight.constant = scrollView.showOrHideView(view: self.expandHowToView, expandHeight: self.expandHowToHeight.constant, viewHeight: self.howToHeight.constant, imgView: howToBtnImg)
                
//                scrollView.scrollToView(view: self.useTitleLb)
//
//                self.scrollView.contentSize = CGSize(width: 200.0, height: -self.expandHowToHeight.constant)
//
//                // Scroll to bottom
//                scrollView.scrollToView(view: self.useTitleLb)

                break
            case "notice":
                self.expandNoticeHeight.constant = scrollView.showOrHideView(view: self.expandNoticeView, expandHeight: self.expandNoticeHeight.constant, viewHeight: self.noticeHeight.constant, imgView: noticBtnImg)
                break
            default:
                break
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 {
            self.scrollYPosition = 0
            self.scrollIsTop = true
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

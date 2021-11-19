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
import ExpyTableView

class OfferwallViewController: UIViewController, MPRewardedVideoDelegate {
    
    @IBOutlet var lbMyBerryTitle: UILabel!
    @IBOutlet var lbMyBerryPoint: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var useTitleLb: UILabel!
    
    @IBOutlet var btnVideoAds: UIControl!
    
    // change stackView into TableView
    @IBOutlet var expyTableView: ExpyTableView!
    
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    
    private let appID = "ca-app-pub-4857867142176465~5053865371";   // admob app id
    private let placeID = "ca-app-pub-4857867142176465/5258173998"; // admob reward id
    private let testID = "ca-app-pub-3940256099942544/1712485313";  // admob test id
    
    private let kAdUnitId = "657d0a18465e49868563a4cd2ed266bf"
    
    /**
     * Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil
    
    typealias contentArr = Array<String>
    
    let screenHeight:CGFloat = UIScreen.main.bounds.size.height
    let screenWidth:CGFloat = UIScreen.main.bounds.size.width
    var isInfoOpen:Bool = false
    var isHowToOpen:Bool = false
    var isNoticeOpen:Bool = false
    
    let closeImg:UIImage = UIImage.init(named: "list_close_btn")!
    let openImg:UIImage = UIImage.init(named: "list_open_btn")!
    
    var infoStrArr:contentArr = []
    // [string: AnyObject]
    // AnyObject = String, UIImage
    var howToDict:[[String:Any]] = [[:]]
    
    var noticeStrArr:contentArr = []
    
    override func viewDidLoad() {
        scrollView.delegate = self
        expyTableView.delegate = self
        expyTableView.dataSource = self
        
        prepareActionBar()
        prepareView()
        prepareTableView()
        initializeArr()
        
        updateMyPoint()
    }
    
    deinit {
        MPRewardedVideo.removeDelegate(forAdUnitId: self.kAdUnitId)
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "베리충전소"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        MPRewardedVideo.setDelegate(self, forAdUnitId: self.kAdUnitId)
        btnVideoAds.isEnabled = false
        checkAndInitializeSdk()

        lbMyBerryTitle.roundCorners(.allCorners, radius: 9)
    }
    
    func prepareTableView() {
        // row의 높이가 바뀔수 있음
        expyTableView.rowHeight = UITableViewAutomaticDimension
        expyTableView.estimatedRowHeight = UITableViewAutomaticDimension
        expyTableView.separatorStyle = .none
        expyTableView.separatorInset = .zero
    }
    
    func initializeArr() {
        self.infoStrArr = ["베리란?",
                                 "EV Infra의 운영사인 (주)소프트베리에서 따온 이름으로, 사용자 여러분께 충전의 즐거움을 만족시켜 드릴 수 있도록 사용되는 포인트 단위를 말합니다. \n앱 내 동영상 광고, 또는 충전 시 적립(한전운영 충전기에 한함)가능하며 바로 사용하실 수 있습니다."]
        // [string: AnyObject]
        self.howToDict = [
            ["text":"베리 사용방법"],
            ["text":"1) 충전 진행화면 하단의 '베리 사용하기' 버튼을 클릭"],
            ["image":UIImage(named: "howtouse_point")!],
            ["text":"2) 사용하실 베리를 작성"],
            ["image":UIImage(named: "howtouse_point_1")!],
            ["text":"3) 팝업창의 베리사용하기 버튼을 누르면 사용 완료!"],
            ["image":UIImage(named: "howtouse_point_2")!],
            ["text":"4) 이후 베리와 관련된 내역은 메인메뉴 > 마이페이지 > PAY > 베리 조회에서 확인하실 수 있습니다."]
        ]
        
        self.noticeStrArr = ["베리 사용 유의사항", "1) 이용 가능한 충전소 - 한전, GS칼텍스 위의 운영기관에서 운영중인 충전소에서만 베리 사용이 가능합니다","2) 베리는 충전 하는 중에 사용해야 합니다. (충전 이전 이나 충전 후 사용 불가)","3) 사용하신 베리의 환불은 불가합니다. ","4) 충전중 베리사용시 최종 충전금액에서 사용하신 베리만큼 차감 후 결제됩니다.","5) 기타 문의사항은 EV Infra 고객센터 070-8633-9009로 문의주시기 바랍니다."]
    }
    
    func adjustTableview() {
        if self.expyTableView.contentSize.height > 0.0{
            self.tableViewHeight.constant = self.expyTableView.contentSize.height
            //TEST CODE
            expyTableView.layoutIfNeeded()
            expyTableView.setNeedsLayout()
        }
    }
    
//    @IBAction func onClickAdmobAd(_ sender: Any) {
//
//        Server.postCheckRewardVideoAvailable { (isSuccess, value) in
//
//            if isSuccess {
//                let json = JSON(value)
//                if json["code"].intValue == 1000 {
//                    if MPRewardedVideo.hasAdAvailable(forAdUnitID: self.kAdUnitId) {
//                        guard let reward: MPRewardedVideoReward = MPRewardedVideo.selectedReward(forAdUnitID: self.kAdUnitId) else {
//                            self.selectedReward = nil
//                            return
//                        }
//
//                        self.selectedReward = reward
//                        MPRewardedVideo.presentAd(forAdUnitID: self.kAdUnitId, from: self, with: self.selectedReward, customData: String(MemberManager.getMbId()))
//                    } else {
//                        Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
//                    }
//                } else {
//                    Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
//                }
//            } else {
//                Snackbar().show(message: "현재 시청 가능한 광고가 없습니다. 잠시 후 다시 시도해 주세요.")
//            }
//        }
//    }
    
    func updateMyPoint() {
        
        Server.getPoint { [self] (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].intValue == 1000 {
                    let berryPoint = json["point"].intValue
                    if (berryPoint > -1) {
                        self.lbMyBerryPoint.text = String(berryPoint).currency()
                    }
                    
                } else {
                   
                }
            } else {
                
            }
        }
    }
    
    
    @IBAction func onClickBtnVideoAds(_ sender: Any) {
        
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
    
    @IBAction func onClickMyberryBtn(_ sender: Any) {
        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
        let pointVC = chargeStoryboard.instantiateViewController(withIdentifier: "PointViewController") as! PointViewController
        self.navigationController?.push(viewController: pointVC)
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
        if (mopub.isSdkInitialized) {
            self.loadRewardedVideo()
        } else {
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
        btnVideoAds.isEnabled = true
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
        updateMyPoint()
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

extension OfferwallViewController:ExpyTableViewDelegate, ExpyTableViewDataSource, ExpyTableViewHeaderCell{
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        switch state {
        case .willExpand:
            break
        case .willCollapse:
            break
        case .didExpand:
            break
        case .didCollapse:
            break
        }
    }
    
    
    // cell이 열리고 닫힐때 확인
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        switch state {
        case .willExpand:
            break
        case .willCollapse:
            break
        case .didExpand:
            adjustTableview()
            break
        case .didCollapse:
            adjustTableview()
            break
        }
    }
    
    // canExpanSection = 확장가능 활성화 여부 (true = 가능)
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    // 섹션 내용
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("OfferwallTableViewCell", owner: self, options: nil)?.first as! OfferwallTableViewCell

        cell.selectionStyle = .none // 선택시 색 변경 제거
        cell.backgroundColor = .none
        cell.contentTitle.isHidden = false
        cell.contentStateImg.isHidden = false
        cell.content.isHidden = true
        cell.contentImg.isHidden = true
        
        if section == 0 {
            self.expyTableView.separatorColor = UIColor(hex: "#C8C8C8")
            cell.contentTitle.text = self.infoStrArr[0]
            cell.contentStateImg.image = openImg
        }else if section == 1{
            self.expyTableView.separatorColor = UIColor(hex: "#C8C8C8")
            cell.contentTitle.text = "베리 사용방법"
            cell.contentStateImg.image = openImg
        }else if section == 2{
            self.expyTableView.separatorColor = UIColor(hex: "#C8C8C8")
            cell.contentTitle.text = self.noticeStrArr[0]
            cell.contentStateImg.image = openImg
        }
        return cell
    }
    
    
    
    // numberOfRowsInSection = row 갯수 return
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.infoStrArr.count
        }else if section == 1{
            return self.howToDict.count
        }else {
            return self.noticeStrArr.count
        }
    }
    
    // row 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("OfferwallTableViewCell", owner: self, options: nil)?.first as! OfferwallTableViewCell
        cell.contentStateImg.isHidden = true
        cell.contentTitle.isHidden = true
        cell.content.isHidden = false
        
        switch indexPath.section {
        case 0:
            cell.content.text = self.infoStrArr[indexPath.row]
        case 1:
            let dictionary = self.howToDict[(indexPath as NSIndexPath).row]
            cell.contentImg.isHidden = false
            
            cell.content.text = dictionary["text"] as? String
            cell.contentImg.image = dictionary["image"] as? UIImage
        case 2:
            cell.content.text = self.noticeStrArr[indexPath.row]
        default:
            break
        }
    
        cell.content.numberOfLines = 0
        cell.content.textColor = UIColor(hex: "#333333")
        cell.content.fontSize = 16
        return cell
    }

    // 섹션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // cellForRowAt = cell 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        adjustTableview()
    }
}



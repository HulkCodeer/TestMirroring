//
//  FCMManager.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 30..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON
import UserNotifications
import UIKit

internal final class FCMManager {
    static let sharedInstance = FCMManager()

    // target id
    static let TARGET_NONE = "00"
    static let TARGET_CHARGING = "01"
    static let TARGET_BOARD = "02"
    static let TARGET_FAVORITE = "03"
    static let TARGET_REPORT = "04"
    static let TARGET_CHARGING_STATUS = "05"
    static let TARGET_CHARGING_STATUS_FIX = "06"
    static let TARGET_COUPON = "07"
    static let TARGET_POINT  = "08"
    static let TARGET_MEMBERSHIP = "09"
    static let TARGET_COMMUNITY = "10"
    static let TARGET_REPAYMENT = "11"
    static let TARGET_EVENT = "12"
    
    static let FCM_REQUEST_PAYMENT_STATUS = "fcm_request_payment_status"
    
    let defaults = UserDefault()
    
    private init() {}
    
    var registerId: String? = nil
    var nfcNoti: UNNotification? = nil
    var fcmNotification: [AnyHashable: Any]? = nil
    var isReady: Bool = false
    
    func getFCMRegisterId() -> String? {
        if let id = registerId {
            return id
        } else {
            return nil
        }
    }
    
    func getFCMMessageData() -> UNNotification? {
        if let noticfication = nfcNoti {
            return noticfication
        } else {
            return nil
        }
    }
    
    func alertFCMMessage() {
        if let notification = getFCMMessageData(), let _mainNavi = GlobalDefine.shared.mainNavi {
            
            let targetId = notification.request.content.userInfo[AnyHashable("target_id")] as! String?
            
            let dialogMessage = UIAlertController(title: notification.request.content.title, message: notification.request.content.body, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
                self.alertMessage(data: notification.request.content.userInfo)//notification.request.content.userInfo
                                
                if let viewController = _mainNavi.visibleViewController {
                    viewController.dismiss(animated: true)
                }
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
                print("Cancel button tapped")
            })
            
            dialogMessage.addAction(ok)
            
            if (targetId == nil){
                dialogMessage.addAction(cancel)
            }
            
            if let navigation = GlobalDefine.shared.mainNavi {
                if let viewController = navigation.visibleViewController {
                    // 여기다가 뷰컨트롤러가 이거일 경우... 저거일 경우... 고고씡
                    if  (targetId != nil) {
                        if targetId == FCMManager.TARGET_CHARGING && String(describing: viewController).contains("PaymentStatusViewController") {
                            let center = NotificationCenter.default
                            center.post(name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: self, userInfo: notification.request.content.userInfo)
                        } else {
                            if viewController.isKind(of: UIAlertController.self) {
                                if let vc = viewController.presentingViewController {
                                    viewController.dismiss(animated: true, completion: nil)
                                    vc.present(dialogMessage, animated: true, completion: nil)
                                }
                            } else {
                                viewController.present(dialogMessage, animated: true, completion: nil)
                            }
                        }
                    } else {
                        if viewController.isKind(of: UIAlertController.self) {
                            if let vc = viewController.presentingViewController {
                                viewController.dismiss(animated: true, completion: nil)
                                vc.present(dialogMessage, animated: true, completion: nil)
                            }
                        } else {
                            viewController.present(dialogMessage, animated: true, completion: nil)
                        }
                    }
                }
            }
            fcmNotification = nil
        }
    }
    
    func alertMessage(data: [AnyHashable: Any]?) {
        if !isReady {
            return
        }
        if let notification = data {
            if let targetId = notification[AnyHashable("target_id")] as! String? {
                switch targetId {
                case FCMManager.TARGET_NONE: // NONE
                    print("alertMessage() FCMManager.TARGET_NONE")
                    
                case FCMManager.TARGET_CHARGING: // 충전
                    startTagetCharging(data: notification)
                    
                case FCMManager.TARGET_BOARD: // 게시판
                    if let category = notification[AnyHashable("category")] as! String? {
                        if let board_id = Int((notification[AnyHashable("board_id")] as! String)) {
                            if category == "boardNotice" {
                                getNoticeData(noticeId: board_id)
                            } else {
                                getBoardData(boardId: board_id, category: category)
                            }
                        }
                    }

                case FCMManager.TARGET_FAVORITE: // 즐겨찾기
                    print("alertMessage() FCMManager.TARGET_FAVORITE")
                    if let charger_id = notification[AnyHashable("charger_id")] as! String? {
                        NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": charger_id])
                    }
                    
                case FCMManager.TARGET_REPORT: // 제보하기
                    getBoardReportData()
                    
                case FCMManager.TARGET_CHARGING_STATUS: // 충전상태
                    print("alertMessage() FCMManager.TARGET_CHARGING_STATUS")
                    
                case FCMManager.TARGET_CHARGING_STATUS_FIX: // ????
                    print("alertMessage() FCMManager.TARGET_CHARGING_STATUS_FIX")
                    
                case FCMManager.TARGET_COUPON:  // 쿠폰 알림
                    getCouponIssueData()
                    
                case FCMManager.TARGET_POINT:  // 포인트 적립
                    if let cmd = notification[AnyHashable("cmd")] as? String {
                        getPointCmdData(cmd: cmd)
                    } else {
                        getPointData()
                    }
                    
                case FCMManager.TARGET_MEMBERSHIP:  // 제휴 서비스
                    if let cmd = notification[AnyHashable("cmd")] as? String {
                        getMembershipData(cmd: cmd)
                    }
                    
                case FCMManager.TARGET_REPAYMENT:  // 미수금 정산
                    getRepaymentData()
                    
                case FCMManager.TARGET_COMMUNITY: // 커뮤니티 게시판
                    if let category = notification[AnyHashable("mid")] as? String,
                    let documentSrl = notification[AnyHashable("document_srl")] as? String {
                        getCommunityBoardDetailData(boardId: documentSrl, category: category)
                    }
                    
                case FCMManager.TARGET_EVENT: // 이벤트
                    if let eventId = notification[AnyHashable("event_id")] as? String {
                        getEventDetailData(eventId: Int(eventId)!)
                    } else {
                        getEventData()
                    }
                    
                default:
                    print("alertMessage() default")
                }
            }
        }
    }
    
    func getBoardReportData() {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if _visibleViewcon.isKind(of: ReportBoardViewController.self) {
            _visibleViewcon.viewDidLoad()
            return
        } else {
            let vc: ReportBoardViewController =  UIStoryboard(name: "Report", bundle: nil).instantiateViewController(ofType: ReportBoardViewController.self)
            _mainNavi.push(viewController: vc)            
        }
    }
    
    func getCommunityBoardDetailData(boardId: String, category: String) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        let viewcon = UIStoryboard(name: "BoardDetailViewController", bundle: nil).instantiateViewController(ofType: BoardDetailViewController.self)
        if _visibleViewcon.isKind(of: BoardDetailViewController.self) {
            viewcon.document_srl = boardId
            viewcon.category = category
            viewcon.viewDidLoad()
            return
        } else {
            viewcon.document_srl = boardId
            viewcon.category = category
            _mainNavi.push(viewController: viewcon)
        }
    }
    
    func getBoardData(boardId: Int, category: String) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        let maVC: MyArticleViewController =  UIStoryboard(name: "Board", bundle: nil).instantiateViewController(ofType: MyArticleViewController.self)
        if _visibleViewcon.isKind(of: MyArticleViewController.self) {
            maVC.boardId = boardId
            maVC.category = category
            maVC.viewDidLoad()
        } else {
            maVC.boardId = boardId
            maVC.category = category
            _mainNavi.push(viewController: maVC)
        }
    }
    
    func getCouponIssueData() {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if _visibleViewcon.isKind(of: ReportBoardViewController.self) {
            _visibleViewcon.viewDidLoad()
            return
        } else {
            if MemberManager.shared.isLogin {
                let vc:MyCouponViewController =  UIStoryboard(name: "Coupon", bundle: nil).instantiateViewController(ofType: MyCouponViewController.self)
                _mainNavi.push(viewController: vc)
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    func getNoticeData(noticeId: Int) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi else { return }
        if let visableControll = _mainNavi.visibleViewController {
            if visableControll.isKind(of: NoticeContentViewController.self) {
                let vc = visableControll as! NoticeContentViewController
                vc.boardId = noticeId
                vc.viewDidLoad()
            } else {
                let ndVC = UIStoryboard(name: "Board", bundle: nil).instantiateViewController(ofType: NoticeContentViewController.self)
                ndVC.boardId = noticeId
                _mainNavi.push(viewController: ndVC)
            }
        }
    }
    
    func getPointData() {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if _visibleViewcon.isKind(of: PointViewController.self) {
            _visibleViewcon.viewDidLoad()
            return
        } else {
            let pointVC = UIStoryboard(name: "Charge", bundle: nil).instantiateViewController(ofType: PointViewController.self)
            _mainNavi.push(viewController: pointVC)
        }
    }
    
    func getPointCmdData(cmd: String) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if (cmd.equals("pre_set_point")) {
            if _visibleViewcon.isKind(of: PreUsePointViewController.self) {
                _visibleViewcon.viewDidLoad()
                return
            } else {
                let preUseVC = UIStoryboard(name: "Charge", bundle: nil).instantiateViewController(ofType: PreUsePointViewController.self)
                _mainNavi.push(viewController: preUseVC)
            }
        } else if (cmd.equals("show_point_info")) {
            let viewcon = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(ofType: PointUseGuideViewController.self)
            if _visibleViewcon.isKind(of: PointUseGuideViewController.self) {
                viewcon.viewDidLoad()
            } else {
                _mainNavi.push(viewController: viewcon)
            }
        }
    }
    
    func getMembershipData(cmd: String) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if (cmd.equals("lotte_rent_point")){ // lotte
            if _visibleViewcon.isKind(of: LotteRentInfoViewController.self) {
                _visibleViewcon.viewDidLoad()
                return
            } else {
                let membershipVC = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(ofType: LotteRentInfoViewController.self)
                _mainNavi.push(viewController: membershipVC)
            }
        } else if (cmd.equals("move_to_membership")) {
            if _visibleViewcon.isKind(of: MembershipCardViewController.self) {
                _visibleViewcon.viewDidLoad()
                return
            } else {
                let membershipVC = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(ofType: MembershipCardViewController.self)
                _mainNavi.push(viewController: membershipVC)
            }
        } else if (cmd.equals("show_membership_info")) {
            let viewcon = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(ofType: MembershipUseGuideViewController.self)
            if _visibleViewcon.isKind(of: MembershipUseGuideViewController.self) {
                _visibleViewcon.viewDidLoad()
                return
            } else {
                _mainNavi.push(viewController: viewcon)
            }
        }
    }
    
    func getEventData() {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if _visibleViewcon.isKind(of: EventViewController.self) {
            _visibleViewcon.viewDidLoad()
            return
        } else {
            let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventViewController.self)
            _mainNavi.push(viewController: viewcon)
        }
    }
    
    func getEventDetailData(eventId: Int) {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        let eventVC = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
        if _visibleViewcon.isKind(of: EventContentsViewController.self) {
            eventVC.eventId = eventId
            eventVC.viewDidLoad()
        } else {
            eventVC.eventId = eventId
            _mainNavi.push(viewController: eventVC)
        }
    }
    
    func getRepaymentData() {
        guard let _mainNavi = GlobalDefine.shared.mainNavi, let _visibleViewcon = _mainNavi.visibleViewController else { return }
        if _visibleViewcon.isKind(of: RepayListViewController.self) {
            _visibleViewcon.viewDidLoad()            
        } else {
            let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
            _mainNavi.push(viewController: paymentVC)
        }
    }
    
    func startTagetCharging(data: [AnyHashable: Any]){
        guard MemberManager.shared.isLogin else { return }
        var chargingId = defaults.readString(key: UserDefault.Key.CHARGING_ID)
        var cmd = ""
        var cpId = ""
        var connectorId = ""

        if chargingId.isEmpty {
            if let notiChargingId =  data[AnyHashable("charging_id")] as! String? {
                chargingId = notiChargingId
                defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: chargingId)
            }
        }
        
        if let notiCmd =  data[AnyHashable("cmd")] as! String? {
            cmd = notiCmd
        }
        if let notiCpId = data[AnyHashable("cp_id")] as! String? {
            cpId = notiCpId
        }
        
        if let notiConId = data[AnyHashable("connector_id")] as! String? {
            connectorId = notiConId
        }

        guard let _mainNavi = GlobalDefine.shared.mainNavi else { return }
        let center = NotificationCenter.default
        if cmd.elementsEqual("charging_end") {
            let paymentResultVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: PaymentResultViewController.self)
            paymentResultVC.chargingId = chargingId
            _mainNavi.push(viewController: paymentResultVC)
        } else {
            if let viewController = _mainNavi.visibleViewController {
                if !String(describing: viewController).contains("PaymentStatusViewController") {
                    let paymentStatusVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: PaymentStatusViewController.self)
                    paymentStatusVC.cpId = cpId
                    paymentStatusVC.connectorId = connectorId
                    
                    _mainNavi.push(viewController: paymentStatusVC)
                } else {
                    center.post(name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: self, userInfo: data)
                }
            } else {
                let paymentStatusVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: PaymentStatusViewController.self)
                _mainNavi.push(viewController: paymentStatusVC)
            }
        }
    }
    
    func registerUser() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let modelName = UIDevice.current.modelName
        var uid: String? = nil
        if let dUid = KeyChainManager.get(key: KeyChainManager.KEY_DEVICE_UUID), !dUid.isEmpty {
            uid = dUid
        } else {
            uid = UIDevice.current.identifierForVendor!.uuidString
            KeyChainManager.set(value: uid!, forKey: KeyChainManager.KEY_DEVICE_UUID)
        }

        Server.registerUser(version: version, model: modelName, uid: uid!, fcmId: getFCMRegisterId()) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                UserDefault().saveString(key: UserDefault.Key.MEMBER_ID, value: json["member_id"].stringValue)
                UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_NOTIFICATION, value: json["receive_push"].boolValue)
                UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_JEJU_NOTIFICATION, value: json["receive_jeju_push"].boolValue)
                UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION, value: json["receive_marketing_push"].boolValue)
                self.updateFCMInfo()
            }
        }
    }
    
    func updateFCMInfo() {
        var uid: String? = nil
        if let dUid = KeyChainManager.get(key: KeyChainManager.KEY_DEVICE_UUID), !dUid.isEmpty {
            uid = dUid
        } else {
            uid = UIDevice.current.identifierForVendor!.uuidString
            KeyChainManager.set(value: uid!, forKey: KeyChainManager.KEY_DEVICE_UUID)
        }
        
        if let fcmId = self.getFCMRegisterId() {
            Server.registerFCM(fcmId: fcmId, uid: uid!) { (isSuccess, value) in
                if isSuccess {
                    print("Register FCM SUCCESS")
                }
            }
        }
    }
}

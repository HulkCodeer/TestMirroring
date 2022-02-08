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

class FCMManager {

    // target id
    static let TARGET_NONE = "00"
    static let TARGET_CHARGING = "01"
    static let TARGET_BOARD = "02"
    static let TARGET_FAVORITE = "03"
    static let TARGET_REPORT = "04"
    static let TARGET_CHARGING_STATUS = "05"
    static let TARGET_CHARGING_STATUS_FIX = "06"
    static let TARGET_COUPON = "07"
    static let TARGET_POINT  = "08";
    static let TARGET_MEMBERSHIP = "09";
//    static let TARGET_COMMUNITY = "10";
    static let TARGET_REPAYMENT = "11";
    
    static let FCM_REQUEST_PAYMENT_STATUS = "fcm_request_payment_status"
    static let sharedInstance = FCMManager()
    let defaults = UserDefault()
    
    private init() {
    }
    
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
    
    func alertFCMMessage(navigationController: UINavigationController?) {
        if let notification = getFCMMessageData() {
            
            let targetId = notification.request.content.userInfo[AnyHashable("target_id")] as! String?
            
            let dialogMessage = UIAlertController(title: notification.request.content.title, message: notification.request.content.body, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
                self.alertMessage(navigationController: navigationController, data: notification.request.content.userInfo)//notification.request.content.userInfo
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
                print("Cancel button tapped")
            })
            
            dialogMessage.addAction(ok)
            
            if (targetId == nil || targetId != FCMManager.TARGET_POINT){
                dialogMessage.addAction(cancel)
            }
            
            if let navigation = navigationController {
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
    
    func alertMessage(navigationController: UINavigationController?, data: [AnyHashable: Any]?) {
        if !isReady {
            return
        }
        if let notification = data {
            if let targetId = notification[AnyHashable("target_id")] as! String? {
                switch targetId {
                case FCMManager.TARGET_NONE: // NONE
                    print("alertMessage() FCMManager.TARGET_NONE")
                    
                case FCMManager.TARGET_CHARGING: // 충전
                    startTagetCharging(navigationController: navigationController, data: notification)
                    
                case FCMManager.TARGET_BOARD: // 게시판
                    if let category = notification[AnyHashable("category")] as! String? {
                        if let board_id = Int((notification[AnyHashable("board_id")] as! String)) {
                            if category == "boardNotice" {
                                getNoticeData(navigationController: navigationController, noticeId: board_id)
                            } else {
                                getBoardData(navigationController: navigationController, boardId: board_id, category: category)
                            }
                        }
                    }

                case FCMManager.TARGET_FAVORITE: // 즐겨찾기
                    print("alertMessage() FCMManager.TARGET_FAVORITE")
                    if let charger_id = notification[AnyHashable("charger_id")] as! String? {
                        NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": charger_id])
                    }
                    
                case FCMManager.TARGET_REPORT: // 제보하기
                    getBoardReportData(navigationController: navigationController)
                    
                case FCMManager.TARGET_CHARGING_STATUS: // 충전상태
                    print("alertMessage() FCMManager.TARGET_CHARGING_STATUS")
                    
                case FCMManager.TARGET_CHARGING_STATUS_FIX: // ????
                    print("alertMessage() FCMManager.TARGET_CHARGING_STATUS_FIX")
                    
                case FCMManager.TARGET_COUPON:  // 쿠폰 알림
                    getCouponIssueData(navigationController: navigationController)
                    
                case FCMManager.TARGET_POINT:  // 포인트 적립
                    getPointData(navigationController: navigationController)
                    
                case FCMManager.TARGET_MEMBERSHIP:  // 제휴 서비스
                    getMembershipData(navigationController: navigationController)
                    
                case FCMManager.TARGET_REPAYMENT:  // 미수금 정산
                    getRepaymentData(navigationController: navigationController)
                default:
                    print("alertMessage() default")
                }
            }
        }
    }
    
    func getBoardReportData(navigationController: UINavigationController?) {
        if let visableControll = navigationController?.visibleViewController {
            if visableControll.isKind(of: ReportBoardViewController.self) {
                visableControll.viewDidLoad()
                return
            } else {
                if MemberManager().isLogin() {
                    if let navigation = navigationController {
                        let vc:ReportBoardViewController =  UIStoryboard(name: "Report", bundle: nil).instantiateViewController(withIdentifier: "ReportBoardViewController") as! ReportBoardViewController
                        
                        navigation.push(viewController: vc)
                    }
                } else {
                    MemberManager().showLoginAlert(vc: visableControll)
                }
            }
        }
    }

    
    func getBoardData(navigationController: UINavigationController?, boardId: Int, category: String) {
        if let navigation = navigationController {
            if let visableControll = navigation.visibleViewController {
                if visableControll.isKind(of: MyArticleViewController.self) {
                    let vc:MyArticleViewController = visableControll as! MyArticleViewController
                    vc.boardId = boardId
                    vc.category = category
                    vc.viewDidLoad()
                    return
                } else {
                    let maVC:MyArticleViewController =  UIStoryboard(name: "Board", bundle: nil).instantiateViewController(withIdentifier: "MyArticleViewController") as! MyArticleViewController
                    maVC.boardId = boardId
                    maVC.category = category
                    
                    navigation.push(viewController: maVC)
                }
            }
        }
    }
    
    func getCouponIssueData(navigationController: UINavigationController?) {
        if let visableControll = navigationController?.visibleViewController {
            if visableControll.isKind(of: ReportBoardViewController.self) {
                visableControll.viewDidLoad()
                return
            } else {
                if MemberManager().isLogin() {
                    if let navigation = navigationController {
                        let vc:MyCouponViewController =  UIStoryboard(name: "Coupon", bundle: nil).instantiateViewController(withIdentifier: "MyCouponViewController") as! MyCouponViewController
                        
                        navigation.push(viewController: vc)
                    }
                } else {
                    MemberManager().showLoginAlert(vc: visableControll)
                }
            }
        }
    }
    
    func getNoticeData(navigationController: UINavigationController?, noticeId: Int) {
        if let navigation = navigationController {
            if let visableControll = navigation.visibleViewController {
                if visableControll.isKind(of: NoticeContentViewController.self) {
                    let vc = visableControll as! NoticeContentViewController
                    vc.boardId = noticeId
                    vc.viewDidLoad()
                } else {
                    let ndVC = UIStoryboard(name: "Board", bundle: nil).instantiateViewController(withIdentifier: "NoticeContentViewController") as! NoticeContentViewController
                    ndVC.boardId = noticeId
                    navigation.push(viewController: ndVC)
                }
            }
        }
    }
    
    func getPointData(navigationController: UINavigationController?) {
        if let visableControll = navigationController?.visibleViewController {
            if visableControll.isKind(of: PointViewController.self) {
                visableControll.viewDidLoad()
                return
            } else {
                if MemberManager().isLogin() {
                    if let navigation = navigationController {
                        let pointVC = UIStoryboard(name: "Charge", bundle: nil).instantiateViewController(withIdentifier: "PointViewController") as! PointViewController
                        navigation.push(viewController: pointVC)
                    }
                } else {
                    MemberManager().showLoginAlert(vc: visableControll)
                }
            }
        }
    }
    
    func getMembershipData(navigationController: UINavigationController?) {
        if let visableControll = navigationController?.visibleViewController {
            if visableControll.isKind(of: LotteRentInfoViewController.self) {
                visableControll.viewDidLoad()
                return
            } else {
                if MemberManager().isLogin() {
                    if let navigation = navigationController {
                        let membershipVC = UIStoryboard(name: "Membership", bundle: nil).instantiateViewController(withIdentifier: "LotteRentInfoViewController") as! LotteRentInfoViewController
                        navigation.push(viewController: membershipVC)
                    }
                } else {
                    MemberManager().showLoginAlert(vc: visableControll)
                }
            }
        }
    }
    
    func getRepaymentData(navigationController: UINavigationController?) {
        if let visableControll = navigationController?.visibleViewController {
            if visableControll.isKind(of: RepayListViewController.self) {
                visableControll.viewDidLoad()
                return
            } else {
                if MemberManager().isLogin() {
                    if let navigation = navigationController {
                        let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "RepayListViewController") as! RepayListViewController
                        navigation.push(viewController: paymentVC)
                    }
                } else {
                    MemberManager().showLoginAlert(vc: visableControll)
                }
            }
        }
    }
    
    func startTagetCharging(navigationController: UINavigationController?, data: [AnyHashable: Any]){
        if MemberManager().isLogin() {
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

            if let navigation = navigationController {
                 let center = NotificationCenter.default
                if cmd.elementsEqual("charging_end") {
                    let paymentResultVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentResultViewController") as! PaymentResultViewController
                    navigation.push(viewController: paymentResultVC)
                } else {
                    if let viewController = navigation.visibleViewController {
                        if !String(describing: viewController).contains("PaymentStatusViewController") {
                            let paymentStatusVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
                            paymentStatusVC.cpId = cpId
                            paymentStatusVC.connectorId = connectorId
                            
                            navigation.push(viewController: paymentStatusVC)
                        } else {
                            center.post(name: Notification.Name(FCMManager.FCM_REQUEST_PAYMENT_STATUS), object: self, userInfo: data)
                        }
                    } else {
                        let paymentStatusVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
                        navigation.push(viewController: paymentStatusVC)
                    }
                }
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

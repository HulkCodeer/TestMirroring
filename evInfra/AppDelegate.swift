//
//  AppDelegate.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import CoreData
import Material
import Firebase
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseDynamicLinks
import UserNotifications
import AuthenticationServices
import NMapsMap
import MiniPlengi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.message_id"
    let fcmManager = FCMManager.sharedInstance
    var chargingStatusPayload: [AnyHashable: Any]? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        printLog(out: "application:didFinishLaunchingWithOptions:options")
        FirebaseApp.configure()
        NMFAuthManager.shared().clientId = Const.NAVER_MAP_KEY

        AmplitudeManager.shared.configure(Const.AMPLITUDE_API_KEY)
                
        setupPushNotification(application, didFinishLaunchingWithOptions: launchOptions)
                                        
        // 로플랫 관련 코드
        if Plengi.initialize(clientID: "zeroone",
                       clientSecret: "zeroone)Q@Eh(4",
                             echoCode: "\(MemberManager.shared.mbId)") == .SUCCESS {
            _ = Plengi.setDelegate(self)            
        }
                                
        if Plengi.getEngineStatus() == .STARTED {
            _ = Plengi.start()
        }
                                        
        // 앰플리튜드 설정
        UIViewController.swizzleMethod()
                        
        #if DEBUG
        // PodFile에 TEST-MiniPlengi를 설치해서 테스트
//        Plengi.isDebug = true
        
        // terminating with uncaught exception of type NSException 에러시 CallStack을 찍어준다.
        NSSetUncaughtExceptionHandler { exception in
            let exceptionStr = exception.callStackSymbols.reduce("\n\(exception)\n") { exceptionStr, callStackSymbol -> String in
                "\(exceptionStr)\(callStackSymbol)\n"
            }
            printLog(out: exceptionStr)
        }
        #endif
        
        return true
    }
            
    func setupPushNotification(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            fcmManager.fcmNotification = notification
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard url.scheme != nil else { return true }
        
        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme != nil else { return true }
                
        if let shareChargerId = url.valueOf("charger_id") {
            NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": shareChargerId])
        }

        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            return KOSession.handleOpen(url)
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate!!!")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "evInfra")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
        
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.

        // 앱이 켜져 있을 경우에는 여기로 메세지가 들어옴
        fcmManager.nfcNoti = notification
        print("Notification Title: \(notification.request.content.title)")
        print("Notification body: \(notification.request.content.body)")
        
        
        if #available(iOS 13.0, *) { // SceneDelegate의 navigationController 사용
            fcmManager.alertFCMMessage()
        } else {
            fcmManager.alertFCMMessage()
        }
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // 노티바에서는 여기로 메세지가 들어옴
        fcmManager.nfcNoti = response.notification
        fcmManager.fcmNotification = response.notification.request.content.userInfo
        
        // 메인 실행이 완료되지 않으면 실행하지 않고 메인에서 끝날때 호출        
        fcmManager.alertMessage(data: response.notification.request.content.userInfo)
        
        // 로플랫 관련 코드
        _ = Plengi.processLoplatAdvertisement(center,
                                              didReceive: response,
                                              withCompletionHandler: completionHandler)
        
        completionHandler()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 로플랫 관련 코드
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "processAdvertisement"), object: nil) // SDK 내부 이벤트 호출 (정확한 처리를 위해 권장)
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        printLog(out: "Firebase registration token: \(fcmToken ?? "")")
        fcmManager.registerId = fcmToken
        fcmManager.registerUser()
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//         print("ApFirebase Firebase Received data message: \(remoteMessage.appData)")
//    }
    // [END ios_10_data_message]
}

extension AppDelegate {
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("didReceiveRemoteNotification \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("didReceiveRemoteNotification  fetchCompletionHandler \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("_ APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNs token retrieved: \(deviceToken)")
    }
}

extension Notification.Name {
    public static let pr = NSNotification.Name("plengiResponse")
}

extension AppDelegate: PlaceDelegate {
    func responsePlaceEvent(_ plengiResponse: PlengiResponse) {        
        let plengiResponseData = NSKeyedArchiver.archivedData(withRootObject: plengiResponse)
        UserDefaults.standard.set(plengiResponseData, forKey: "plengiResponse")
        NotificationCenter.default.post(name: .pr, object: nil)
    }
}

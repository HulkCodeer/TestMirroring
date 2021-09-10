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
import UserNotifications
import AuthenticationServices
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appToolbarController: AppToolbarController!
    var navigationController: AppNavigationController?

    let gcmMessageIDKey = "gcm.message_id"
    let fcmManager = FCMManager.sharedInstance
    var chargingStatusPayload: [AnyHashable: Any]? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setupEntryController()
        setupPushNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // SNS 로그인
        LoginHelper.shared.prepareLogin()
        
        return true
    }
    
    fileprivate func setupEntryController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let introViewController = storyboard.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        
        window = UIWindow(frame: Screen.bounds)
        navigationController = AppNavigationController(rootViewController: introViewController)//
        navigationController?.navigationBar.isHidden = true
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
    }
    
    func setupPushNotification(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
//        Messaging.messaging().shouldEstablishDirectChannel = true
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
                fcmManager.fcmNotification = notification
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
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
        
        if let partnershipUrl = url.valueOf("partnership"){
            if partnershipUrl == "true" {
                NotificationCenter.default.post(name: Notification.Name("partnershipScheme"), object: nil)
            }
        }
        
        if let shareChargerId = url.valueOf("charger_id") {
            NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": shareChargerId])
        }

        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            return KOSession.handleOpen(url)
        }
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        print("applicationDidFinishLaunching()")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
//        let appToolbarController = AppToolbarController(rootViewController: mainViewController)
//        appToolbarController.delegate = mainViewController
//        
//        window = UIWindow(frame: Screen.bounds)
//        window!.rootViewController = AppNavigationDrawerController(rootViewController: appToolbarController, leftViewController: leftViewController)
//        window!.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive()")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
         print("applicationDidEnterBackground()")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground()")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive()")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

    func showStatusBar() {
        appToolbarController.showStatusBar()
    }
    
    func hideStatusBar() {
        appToolbarController.hideStatusBar()
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
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
        // Change this to your preferred presentation option
        completionHandler([])
        fcmManager.alertFCMMessage(navigationController: navigationController)
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
//        fcmManager.alertMessage(navigationController: navigationController, data: response.notification.request.content.userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        fcmManager.registerId = fcmToken
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
    
    // MARK: - FCM Messages
//    func getMessageFromUserInfo(userInfo: [AnyHashable: Any]) {
//        userInfo["aps"]
//    }
}

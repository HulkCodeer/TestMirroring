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
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appToolbarController: AppToolbarController!
    var navigationController: AppNavigationController?

    let gcmMessageIDKey = "gcm.message_id"
    let fcmManager = FCMManager.sharedInstance
    var chargingStatusPayload: [AnyHashable: Any]? = nil
	
	var notificationCenter: UNUserNotificationCenter?
	
	//geo
	private var locationManager:CLLocationManager = CLLocationManager.init()
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		print("LEJ 작업 추가..")
		completionHandler(UIBackgroundFetchResult.newData)
	}
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		print("LEJ 시작 프로세스가 거의 완료되었으며 앱을 실행할 준비가 거의 완료되었음을 대리인에게 알립니다.")
			
        setupEntryController()
        setupPushNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        // 카카오 - 로그인,로그아웃 상태 변경 받기
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.kakaoSessionDidChangeWithNotification), name: NSNotification.Name.KOSessionDidChange, object: nil)
        
        // 카카오 - 클라이언트 시크릿 설정
        KOSession.shared().clientSecret = Const.KAKAO_CLIENT_SECRET;
        
        // Apple 로그인 상태 확인
//        if #available(iOS 13.0, *) {
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
//                switch credentialState {
//                case .authorized:
//                    break // The Apple ID credential is valid.
//
//                case .revoked, .notFound:
//                    // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//                    break
//
//                default:
//                    break
//                }
//            }
//        }
        
		initGeo()
		
        return true
    }
    
	func application(_ application: UIApplication,willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)-> Bool {
		print("LEJ 시작 프로세스가 시작되었지만 상태 복원이 아직 발생하지 않았음을 대리인에게 알립니다.")
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
        Messaging.messaging().shouldEstablishDirectChannel = true
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
    
    @objc func kakaoSessionDidChangeWithNotification() {
        MemberManager().login()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let shareChargerId = url.valueOf("charger_id") {
            NotificationCenter.default.post(name: Notification.Name("kakaoScheme"), object: nil, userInfo: ["sharedid": shareChargerId])
        }

        if KOSession.handleOpen(url) {
            return true
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
		print("LEJ 포그라운드에서 백그라운드로 상태 이동")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
         print("applicationDidEnterBackground()")
		 print("LEJ 앱이 백그라운드에 진입")
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
        // Print full message.
        fcmManager.nfcNoti = response.notification
        fcmManager.fcmNotification = response.notification.request.content.userInfo
//        fcmManager.alertMessage(navigationController: navigationController, data: response.notification.request.content.userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        fcmManager.registerId = fcmToken
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
         print("ApFirebase Firebase Received data message: \(remoteMessage.appData)")
    }
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

extension AppDelegate : CLLocationManagerDelegate {
	 func initGeo() {
		self.locationManager.requestAlwaysAuthorization()
		print("LEJ set RegionCenter")

		//geo location manager
		locationManager.delegate = self                         // 델리게이트 넣어줌.
		locationManager.requestAlwaysAuthorization()            // 위치 권한 받아옴.

		locationManager.startUpdatingLocation()                 // 위치 업데이트 시작
		locationManager.allowsBackgroundLocationUpdates = true  // 백그라운드에서도 위치를 체크할 것인지에 대한 여부. 필요없으면 false로 처리하자.
		locationManager.pausesLocationUpdatesAutomatically = false  // 이걸 써줘야 백그라운드에서 멈추지 않고 돈다

		// Your coordinates go here (lat, lon)
		let geofenceRegionCenter = CLLocationCoordinate2D(
			latitude: 37.490709,
			longitude: 127.030566
		)

		/* Create a region centered on desired location,
		 choose a radius for the region (in meters)
		 choose a unique identifier for that region */
		let geofenceRegion = CLCircularRegion(
			center: geofenceRegionCenter,
			radius: 100,
			identifier: "UniqueIdentifier"
		)

		geofenceRegion.notifyOnEntry = true
		geofenceRegion.notifyOnExit = true
		
		//지정된 지역 모니터링 시작
		self.locationManager.startMonitoring(for: geofenceRegion)
		//self.locationManager.startMonitoringSignificantLocationChanges()
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		 print("LEJ locationManager exit")
        if region is CLCircularRegion {
			updateGeo(status:false)
        }
    }

    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		print("LEJ locationManager enter")
        if region is CLCircularRegion {
			updateGeo(status:true)
        }
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	   if let error = error as? CLError, error.code == .denied {
		  // Location updates are not authorized.
		  manager.stopMonitoringSignificantLocationChanges()
		  return
	   }
	   // Notify the user of any errors.
	}
	
	func updateGeo(status:Bool){
		Server.updateGeofence(status:status){ (isSuccess, value) in
		  if isSuccess {
			let json = JSON(value)
			if json["code"] == 1000 {
				print("LEJ GEO UPDATE SUCCESS")
			}else{
				print("LEJ GEO UPDATE code FAILED..")
			}
		  }else{
			print("LEJ GEO UPDATE isSuccess FAILED..")
		  }
		}
	}
}

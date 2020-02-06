//
//  AppDelegate.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-18.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import CoreData
import Firebase

import SDWebImage
import ChameleonFramework
import Purchases
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
// swiftlint:disable vertical_whitespace line_length unused_closure_parameter
    var window: UIWindow?
    var gcmMessageIDKey = "gcm.message_id"
    
    
    //MARK:- Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //  Register.
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString: \(deviceTokenString)")
       // self.apnsToken = deviceTokenString
        
        //set apns token in messaging
        Messaging.messaging().apnsToken = deviceToken
        
        //get FCM token
        if let token = Messaging.messaging().fcmToken {
            //self.fcmToken = token
            print("FCM token: \(token)")
        }
        
        //subscribe to topic to send message to multiple device
      //  self.subscribeToTopic()
    }
    

    
     func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

         ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
      

             if #available(iOS 10.0, *) {
                 // For iOS 10 display notification (sent via APNS)
                 UNUserNotificationCenter.current().delegate = self
                 
                 let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                 UNUserNotificationCenter.current().requestAuthorization(
                     options: authOptions,
                     completionHandler: {_, _ in })
             } else {
                 let settings: UIUserNotificationSettings =
                     UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                 application.registerUserNotificationSettings(settings)
             }
             
             application.registerForRemoteNotifications()
             
           
           

             application.beginReceivingRemoteControlEvents()
              Messaging.messaging().delegate = self as? MessagingDelegate
             
            
        let appearance = UITabBarItem.appearance()
              let attributes = [NSAttributedString.Key.font:UIFont(name: "ArialMT", size: 10)]
              appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
              Purchases.debugLogsEnabled = true
        
        let defaults = UserDefaults.standard
              if defaults.string(forKey: SavedKeys.isSignedIn) == "true" {
                            if let email = defaults.string(forKey: SavedKeys.email) {
                                print("Saved Email (Autofill): \(email)")
                              
                               if let password = defaults.string(forKey: SavedKeys.password) {
                                                print("Saved Password (Autofill): \(password)")
                                
                                
                                  autoLogin(email: email, password: password)
                                 
                                 
                             }
                            }
              }else{
                  let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

                                    // rootViewController
                                    let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "signIn")

                                    // navigationController
                                    let navigationController = UINavigationController(rootViewController: rootViewController)

                                    navigationController.isNavigationBarHidden = false
                                 //   let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    
                                 //   let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeView")
                                    
                                    self.window?.rootViewController = navigationController
                                    self.window?.makeKeyAndVisible()
              }
              
                     
                   
             
              
             
           

        // [END register_for_notifications]
        return true
      }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let appId: String = Settings.appID!
           if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" {
               return ApplicationDelegate.shared.application(app, open: url, options: options)
           }
           return false
       }
   

      // [START receive_message]
      func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
      }

      func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
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
      

    // [START ios_10_message_handling]
   
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler()
      }
    
    // [END ios_10_message_handling]

   
  
   

    
   func autoLogin(email: String, password: String){
        
         
      
                  
        System.handleLogin(email: email,password: password, completion: { uid in
            print("UID: \(uid) - line 59")
            let defaults = UserDefaults.standard
                             print("Saved Uid : \(uid)")
                             defaults.set(uid, forKey: SavedKeys.uid)
                 
          
                let isSubscribedInOldSystem = false
            // If the old system says we have a subscription, but RevenueCat does not
            
            Purchases.configure(withAPIKey: REVENUECATAPIKEY, appUserID: uid)
            
            Purchases.shared.identify(uid) { (purchaserInfo, error) in
               print("purchaserInfo updated for \(uid)")
                
                let isSubscribedInRevenueCat = purchaserInfo?.entitlements.active.isEmpty
                if (isSubscribedInOldSystem && !(isSubscribedInRevenueCat ?? true))
                {
                  // Tell Purchases to restoreTransactions.
                  // This will sync the user's receipt with RevenueCat.
                      
                  Purchases.shared.restoreTransactions { (purchaserInfo, error) in }
                }
            }
            User.uid = uid
            FirebaseManager.updateFcmToken()
            System.getUserInfo(uid: uid, completion: { message in
                
                print(message)
                
                System.getFollowingIdsForUid(uid: uid) { (followingIds) in
                    
                    User.followingIds = followingIds

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeView") as UIViewController
                    
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
              
                       
              
            })
                              
        })
     
                
              
             
       
    }
    
     override init() {
        super.init()
        FirebaseApp.configure()
      
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        /*
        let sources = [DISCOVERTRACKS, LIBRARYTRACKS,LIKEDTRACKS,DISLIKEDTRACKS, UPLOADEDTRACKS, BLACKLISTTRACKS]
        
        for source in sources {
            let defaults = UserDefaults.standard
            defaults.set(User.trackKeys[source], forKey: "Cached\(source)")
            print("Saved: \(source) keys")
        }

      */
    }
    
  

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    @available(iOS 13.0, *)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Limelight")
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

    @available(iOS 13.0, *)
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
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([])
  }

}
extension AppDelegate : MessagingDelegate {
     // [START refresh_token]
     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
       print("Firebase registration token: \(fcmToken)")
       
       let dataDict:[String: String] = ["token": fcmToken]
       NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
       // TODO: If necessary send token to application server.
       // Note: This callback is fired at each app startup and whenever a new token is generated.
     }
     // [END refresh_token]
     // [START ios_10_data_message]
     // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
     // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
     func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
       print("Received data message: \(remoteMessage.appData)")
     }
     // [END ios_10_data_message]
   }


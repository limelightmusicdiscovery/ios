//
//  SceneDelegate.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-18.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import Purchases
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func autoLogin(email: String, password: String){
        
        
        System.handleLogin(email: email,password: password, completion: { uid in
            print("UID: \(uid) - line 59")
            
            let defaults = UserDefaults.standard
                                        print("Saved Uid : \(uid)")
                                        defaults.set(uid, forKey: SavedKeys.uid)
             User.uid = uid
            let pushManager = PushNotificationManager(userID: uid)
                         pushManager.registerForPushNotifications()
                   
              
                 Purchases.configure(withAPIKey: REVENUECATAPIKEY, appUserID: uid)
                let isSubscribedInOldSystem = false
            // If the old system says we have a subscription, but RevenueCat does not
            
            Purchases.shared.identify(uid) { (purchaserInfo, error) in
               print("purchaserInfo updated for \(uid)")
                let entitlement = purchaserInfo?.entitlements[0]
                Subscription.uid = User.uid
                 
                 Subscription.entitlementId = entitlement?.identifier ?? ""
                 Subscription.isActive = entitlement?.isActive ?? false
                 Subscription.periodType = entitlement?.periodType
                 Subscription.originalPurchaseDate = Int(entitlement?.originalPurchaseDate.timeIntervalSince1970 ?? 0)
                 Subscription.latestPurchaseDate = Int(entitlement?.latestPurchaseDate.timeIntervalSince1970 ?? 0)
                 Subscription.expirationPurchaseDate = Int(entitlement?.expirationDate?.timeIntervalSince1970 ?? 0)
                 Subscription.willRenew = entitlement?.willRenew ?? false
                 Subscription.store = entitlement?.store
                 if entitlement?.identifier == "pro" {
                     Subscription.planType = PROARTIST
                     Subscription.tracksAvailable = PROTRACKCOUNT
                 }else if  entitlement?.identifier == "plus" {
                     Subscription.planType = PLUSARTIST
                     Subscription.tracksAvailable = PLUSTRACKCOUNT
                 }else {
                     Subscription.planType = BASICARTIST
                     Subscription.tracksAvailable = BASICTRACKCOUNT
                 }
                
                if Subscription.isActive == true {
                    User.isSubscribed = true
                }
                
                System.setRevenueCatSubscription(uid: uid)
                
                
                let isSubscribedInRevenueCat = purchaserInfo?.entitlements.active.isEmpty
                if (isSubscribedInOldSystem && !(isSubscribedInRevenueCat ?? true))
                {
                  // Tell Purchases to restoreTransactions.
                  // This will sync the user's receipt with RevenueCat.
                      
                  Purchases.shared.restoreTransactions { (purchaserInfo, error) in }
                }
            }
           
           
            System.getUserInfo(uid: uid, completion: { message in
                
                print(message)
                 FirebaseManager.updateFcmToken()
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


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                             window?.windowScene = windowScene
        
        let defaults = UserDefaults.standard
        
     
     
            if defaults.string(forKey: SavedKeys.isSignedIn) == "true" {
                if let email = defaults.string(forKey: SavedKeys.email) {
                    print("Saved Email (Autofill): \(email)")
                  
                   if let password = defaults.string(forKey: SavedKeys.password) {
                                    print("Saved Password (Autofill): \(password)")
                      autoLogin(email: email, password: password)
                     
                     
                 }
                }
            }
                    else{
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

                    // rootViewController
                    let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "signIn") //"ChooseGenres") as! ChooseGenresViewController // "signIn")

                    // navigationController
                    let navigationController = UINavigationController(rootViewController: rootViewController)

                    navigationController.isNavigationBarHidden = false
                 //   let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                 //   let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeView")
                    
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
            }
        
               
       
       
    }
    
    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


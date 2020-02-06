//
//  SignInViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework
import Purchases
import FBSDKLoginKit

class SignInViewController: UIViewController, LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
         if ((error) != nil) {
                   // Process error
               }
         else if result?.isCancelled ?? false {
                   // Handle cancellations
               }
               else {
                   // Navigate to other view
               }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("did logout")
    }
    
    // swiftlint:disable vertical_whitespace line_length unused_closure_parameter trailing_whitespace identifier_name function_body_length
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    
    @IBAction func selectFacebookLogin(sender: UIButton)
       {
        let fbLoginManager : LoginManager = LoginManager()
        
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) {
            

               (result, error) -> Void in
               if (error == nil)
               {
                let fbloginresult : LoginManagerLoginResult = result!
                if result?.isCancelled ?? true
                   {
                       return
                   }

                   if(fbloginresult.grantedPermissions.contains("email"))
                   {
                       self.getFBUserData()
                   }
               }
           }
       }

    func getFBUserData()
       {
        

        if((AccessToken.current) != nil)
           {
            GraphRequest(graphPath: "me",
                         parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                            completionHandler: { (connection, result, error) -> Void in
                       
                   if (error == nil)
                   {
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                      print(result)
                    let result = result as! [String: Any]
                    let email = result["email"] ?? ""
                    let name = "\(result["first_name"] ?? "")  \(result["last_name"] ?? "")"
                    print(result["email"] )
                    print(result["first_name"])
                    print(result["last_name"])
                    
                    User.name = name
                    User.email = email as? String ?? ""
                    let defaults = UserDefaults.standard
                    defaults.set(email, forKey: SavedKeys.email)
                
                    defaults.set("true", forKey: SavedKeys.isSignedIn)
                    
                    self.handleFBLogin(credential: credential)
                   
                    

                   }
               })
           }
       }
    
  
    
    var db = Firestore.firestore()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        System.frame = self.view.frame //for the gradient in library
        
        /*
        if (AccessToken.current != nil)
               {
                   //performSegueWithIdentifier("unwindToViewOtherController", sender: self)
               }
               else
               {
                facebookLoginButton.permissions = ["public_profile", "email", "user_friends"]
               }
*/
       
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
               self.navigationController?.navigationBar.shadowImage = UIImage()
               self.navigationController?.navigationBar.isTranslucent = true
               self.navigationController?.view.backgroundColor = .clear
               self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        autofillLoginInfo() //if login information was provided before, it will automatically be filled in.
        //loadingIndicator.isAnimating = false
        // Ask for Authorisation from the User.
        self.hideKeyboardWhenTappedAround()
      
       
        
    }
        

    func autofillLoginInfo() {
        
        let defaults = UserDefaults.standard
        if let email = defaults.string(forKey: SavedKeys.email) {
            print("Saved Email (Autofill): \(email)")
            emailTextField.text = email
           
        }
        if let password = defaults.string(forKey: SavedKeys.password) {
            print("Saved Password (Autofill): \(password)")
            passwordTextField.text = password
            
        }
       
        
    }
    
    func saveAutofillLoginInfo(email: String, password: String) {
        
        let defaults = UserDefaults.standard
        print("Saved Email (Saved Autofill): \(email)")
        defaults.set(email, forKey: SavedKeys.email)
         print("Saved Password (Saved Autofill): \(password)")
        defaults.set(password, forKey: SavedKeys.password)
        defaults.set("true", forKey: SavedKeys.isSignedIn)
        
        print("MESSAGE: AutoLogin Info Saved - SignInViewController/saveAutofillLoginInfo")
        
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        self.loadingIndicator.startAnimating()
        
        guard let email = emailTextField.text else {
            print("No Email")
             loadingIndicator.stopAnimating()
            return
        }
        guard let password = passwordTextField.text else {
            print("No Password")
             loadingIndicator.stopAnimating()
            return
        }
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.handleLogin(email: email, password: password)
        }
       
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Reset Password", message: "Please enter your email address below", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Send Password Reset Link", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Please check your email for a password reset link.", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
    
    func handleFBLogin(credential: AuthCredential) {
        
      Auth.auth().signIn(with: credential) { (user, error)in
        
        if error != nil {
            
            self.loadingIndicator.stopAnimating()
            
            print(error?.localizedDescription ?? "ERROR: Firebase auth - SignInViewController/handleLogin")
            
            let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Incorrect Password", preferredStyle: .alert)
            self.present(errorAlert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            
            DispatchQueue.main.asyncAfter(deadline: when) {
                errorAlert.dismiss(animated: true, completion: nil)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
               // self.saveAutofillLoginInfo(email: email, password: password) //save login info since successful attempt
            }
            
            guard let uid = user?.user.uid else {
                print("ERROR: UID is null - SignInViewController/handleLogin")
                return
            }
            
           
            
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getUserInfo(uid: uid)
                
              
            }
             
        }
        }
           
    }
       
    func handleLogin(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
        
        if error != nil {
            
            self.loadingIndicator.stopAnimating()
            
            print(error?.localizedDescription ?? "ERROR: Firebase auth - SignInViewController/handleLogin")
            
            let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Incorrect Password", preferredStyle: .alert)
            self.present(errorAlert, animated: true, completion: nil)
            let when = DispatchTime.now() + 2
            
            DispatchQueue.main.asyncAfter(deadline: when) {
                errorAlert.dismiss(animated: true, completion: nil)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                self.saveAutofillLoginInfo(email: email, password: password) //save login info since successful attempt
            }
            
            guard let uid = user?.user.uid else {
                print("ERROR: UID is null - SignInViewController/handleLogin")
                return
            }
            
           
            
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getUserInfo(uid: uid)
                
              
            }
             
        }
        })
           
    }
    
    @IBAction func done(_ sender: UITextField) {
        self.dismissKeyboard()
    }
    
   
    @IBAction func generateError(sender: UIButton){
           
         //  let vc = storyboard?.instantiateViewController(withIdentifier: "UploadTrack") as! UploadTableViewController
                    
                        
          // self.present(vc, animated: true, completion: nil)
           
           let generator = UINotificationFeedbackGenerator()
                      generator.notificationOccurred(.error)
       }
       

  
    func getUserInfo(uid: String) {
        
        //set User Uid for further reference
        print("UID: \(uid)")
        User.uid = uid
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                       
                let data = document.data()
                       
                let city = data?["city"] as? String ?? "None"
                let state = data?["state"] as? String ?? "None"
                let country = data?["country"] as? String ?? "None"
                let profilePhoto = data?["photoUrl"] as? String ?? "None"
                let username = data?["username"] as? String ?? ""
                let bio = data?["bio"] as? String ?? ""
                //let coverPhoto = data?["coverPhotoUrl"] as? String ?? "" NOT USED YET
                let name = data?["name"] as? String ?? ""
                let spotify = data?["spotify"] as? String ?? ""
                let appleMusic = data?["applemusic"] as? String ?? ""
                let soundcloud = data?["soundcloud"] as? String ?? ""
                let twitter = data?["twitter"] as? String ?? ""
                let instagram = data?["instagram"] as? String ?? ""
                let spotifyClicks = data?["spotifyClicks"] as? Int ?? 0
                let soundcloudClicks = data?["soundcloudClicks"] as? Int ?? 0
                let applemusicClicks = data?["applemusicClicks"] as? Int ?? 0
                let twitterClicks = data?["twitterClicks"] as? Int ?? 0
                let instagramClicks = data?["instagramClicks"] as? Int ?? 0
                let listenerPoints = data?["listenerPoints"] as? Int ?? 0
                let profileImpressionCount = data?["profileImpressionCount"] as? Int ?? 0
                //not sure if below will work
                let followers = data?["followers"] as? [String]
                let following = data?["following"] as? [String]
                let likedTracks = data?["likedTracks"] as? [String]
                let dislikedTracks = data?["dislikedTracks"] as? [String]
                let library = data?["library"] as? [String]
                let migrated = data?["migrated"] as? Bool ?? false
                
                User.location["city"] = city
                User.location["state"] = state
                User.location["country"] = country
                User.imageUrl = profilePhoto
                User.username = username
                User.bio = bio
                User.name = name
                User.listenerPoints = listenerPoints
                User.socials["spotify"] = spotify
                User.socials["applemusic"] = appleMusic
                User.socials["soundcloud"] = soundcloud
                User.socials["twitter"] = twitter
                User.socials["instgram"] = instagram
                //add limelight social link
                User.socialClicks["spotify"] = spotifyClicks
                User.socialClicks["applemusic"] = applemusicClicks
                User.socialClicks["soundcloud"] = soundcloudClicks
                User.socialClicks["twitter"] = twitterClicks
                User.socialClicks["instagram"] = instagramClicks
                 //add limelight clicks
                User.profileImpressionCount = profileImpressionCount
                //not sure if below will work
               // User.followers = followers ?? [String]()
               // User.following = following ?? [String]()
                User.trackKeys[LIKEDTRACKS] = likedTracks ?? [String]()
                User.trackKeys[DISLIKEDTRACKS] = dislikedTracks ?? [String]()
                User.trackKeys[LIBRARYTRACKS] = library ?? [String]()
                
                
                if !migrated{
                    System.migrateUser(uid: uid) { (done) in
                        if done {
                            self.db.collection("users").document(uid).setData([
                                                                                                    "migrated": true
                                                                                                  
                                                                                                ], merge: true)
                            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeView") as UIViewController
                                         secondViewController.modalPresentationStyle = .fullScreen
                                         self.loadingIndicator.stopAnimating()
                                         self.present(secondViewController, animated: true, completion: nil)
                        }
                    }
                }else {
                    let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeView") as UIViewController
                                 secondViewController.modalPresentationStyle = .fullScreen
                                 self.loadingIndicator.stopAnimating()
                                 self.present(secondViewController, animated: true, completion: nil)
                }
               
             
            }
        }
    }
    

}

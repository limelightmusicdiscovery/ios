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

class SignInViewController: UIViewController {
    // swiftlint:disable vertical_whitespace line_length unused_closure_parameter trailing_whitespace identifier_name function_body_length
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
       // autofillLoginInfo() //if login information was provided before, it will automatically be filled in.

        // Do any additional setup after loading the view.
    }
    
    func autofillLoginInfo() {
        
        let defaults = UserDefaults.standard
        if let email = defaults.string(forKey: SavedKeys.email) {
            emailTextField.text = email
           
        }
        if let password = defaults.string(forKey: SavedKeys.password) {
            passwordTextField.text = password
            
        }
       
        
    }
    
    func saveAutofillLoginInfo(email: String, password: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: SavedKeys.email)
        defaults.set(password, forKey: SavedKeys.password)
        
        print("MESSAGE: AutoLogin Info Saved - SignInViewController/saveAutofillLoginInfo")
        
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        guard let email = emailTextField.text else {
            print("No Email")
            return
        }
        guard let password = passwordTextField.text else {
            print("No Password")
            return
        }
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.handleLogin(email: email, password: password)
        }
       
    }
       
    func handleLogin(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
        
        if error != nil {
            
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getUserInfo(uid: uid)
                
              
            }
             
        }
        })
           
    }
    
    func getUserInfo(uid: String) {
        
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
                let alias = data?["alias"] as? String ?? ""
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
                
                //not sure if below will work
                let followers = data?["followers"] as? [String]
                let following = data?["following"] as? [String]
                let likedTracks = data?["likedTracks"] as? [String]
                let dislikedTracks = data?["dislikedTracks"] as? [String]
                let library = data?["library"] as? [String]
                
                User.location["city"] = city
                User.location["state"] = state
                User.location["country"] = country
                User.imageUrl = profilePhoto
                User.username = username
                User.bio = bio
                User.alias = alias
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
                
                //not sure if below will work
                User.followers = followers ?? [String]()
                User.following = following ?? [String]()
                User.likedTracks = likedTracks ?? [String]()
                User.dislikedTracks = dislikedTracks ?? [String]()
                User.library = library ?? [String]()
                
                
                let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeView") as UIViewController
                secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
            }
        }
    }
    

}

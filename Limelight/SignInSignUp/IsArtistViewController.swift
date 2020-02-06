//
//  IsArtistViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-28.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import PopupDialog
import Purchases
import Firebase
import FirebaseFirestore
class IsArtistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        //loadPopupDialogSettings()
        // Do any additional setup after loading the view.
    }
    
    
    
    func pushArtistPlansViewController(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ArtistPlans")// as! ChooseGenresViewController
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func pushHomeViewController(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeView") as UIViewController
        
        newViewController.modalPresentationStyle = .fullScreen
       
        self.present(newViewController, animated: true)
    }
    func showPopup(){

           // Prepare the popup assets
           let title = "Limelight For Artists Disabled"
           let message = "If you're an artist, please wait until launch to use this feature."
           let image = UIImage(named: "limelightBlackBackground")

           // Create the dialog
           let popup = PopupDialog(title: title, message: message, image: image)

           let okButton = DefaultButton(title: "OK", height: 60) {
               
               
           }

           // Add buttons to dialog
           // Alternatively, you can use popup.addButton(buttonOne)
           // to add a single button
           popup.addButtons([okButton])

           // Present dialog
           self.present(popup, animated: true, completion: nil)
       }
    
    func showArtistPayWall(){
            Purchases.shared.purchaserInfo { (purchaserInfo, error) in
                if let e = error {
                    print(e.localizedDescription)
                }
                
                // Route the view depending if we have a premium cat user or not
                if false{//purchaserInfo?.entitlements["pro"]?.isActive == true || purchaserInfo?.entitlements["plus"]?.isActive == true {
                    
                    // if we have a pro_cat subscriber, send them to the cat screen
                    //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //  let controller = storyboard.instantiateViewController(withIdentifier: "cats")
                    //   controller.modalPresentationStyle = .fullScreen
                    //     self.present(controller, animated: true, completion: nil)
                    print("subscription active")
                    
                } else {
                    // if we don't have a pro subscriber, send them to the upsell screen
                    let controller = SwiftPaywall(
                        termsOfServiceUrlString: "http://limelight.io",
                        privacyPolicyUrlString: "https://limelight.io")
                    
                    controller.titleLabel.text = "Limelight for Artists"
                    controller.subtitleLabel.text = "Higher radius, unlimited uploads, personal artist insights and more!"
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
           }
        
       }
       
    @IBAction func isArtistButtonClicked() {
      
      let db = Firestore.firestore()
      db.collection("users").document(User.uid).setData([
                                                                      "isArtist": true
                                                                    
                                                                  ], merge: true)
     
        
        pushHomeViewController()
    }
    
   
    @IBAction func isListenerButtonClicked() {
      
       pushHomeViewController()
    }
    
    func showPopupDialog(){
        // Prepare the popup assets
        let title = "Confirm your location"
        let message = "We've located your location is New York, New York"
        

        // Create the dialog
        let popup = PopupDialog(title: title, message: message)

        // Create buttons
        let buttonOne = CancelButton(title: "CANCEL") {
            print("You canceled the car dialog.")
        }

        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "This is correct", dismissOnTap: false) {
            print("What a beauty!")
        }

        let buttonThree = DefaultButton(title: "This is incorrect", height: 60) {
            print("Ah, maybe next time :)")
        }

        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo, buttonThree])

        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func loadPopupDialogSettings(){
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .purple
        pcv.shadowOpacity   = 0.6
        pcv.shadowRadius    = 20

        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.7
        ov.color           = .black

        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor     = .white
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)

        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        
        
   
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

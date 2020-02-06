//
//  SignUp2ViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-28.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import MapKit
import PopupDialog
import FirebaseFirestore
import Purchases

enum defaultsKeys {
    static let username = "firstStringKey"
    static let password = "secondStringKey"
    static let uid = ""
    
   
}

class SignUp2ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var birthDateTextField: UIDatePicker!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
   
    var locationManager = CLLocationManager()
    
    func showGenreViewController(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseGenres") as! ChooseGenresViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func pushGenreViewController(){
           let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
           let newViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseGenres")// as! ChooseGenresViewController
           navigationController?.pushViewController(newViewController, animated: true)
       }
    
    func pushUserLocationViewController(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "UserLocation")// as! ChooseGenresViewController
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    @IBAction func done(_ sender: UITextField) {
           self.view.endEditing(true)
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
               self.navigationController?.navigationBar.shadowImage = UIImage()
               self.navigationController?.navigationBar.isTranslucent = true
               self.navigationController?.view.backgroundColor = .clear
             self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        self.hideKeyboardWhenTappedAround()
        pickerView.delegate = self
        pickerView.dataSource = self
        errorLabel.isHidden = true
        popupDialogSetup()
        // Do any additional setup after loading the view.
    }
    
    func checkIfUsernameExists(username: String){
         print("checking if username exists")
        
 
         let db = Firestore.firestore()
         let usernameString = username
         
         db.collection("users")
             .whereField("username", isEqualTo: usernameString.lowercased())
             .getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     // Some error occured
                    self.errorLabel.text = err.localizedDescription
                    self.errorLabel.isHidden = false
                    
                 } else if querySnapshot!.documents.count == 0 {
                     // Perhaps this is an error for you?
                    User.username = username
                    print("finished checking if username exists")
                    self.handleRegister(name: User.name, email: User.email, password: User.password, username: User.username)
                    
                 } else {
                    self.errorLabel.text = "Username exists, please choose a different one"
                    self.errorLabel.isHidden = false
                    self.loadingIndicator.stopAnimating()
                    print("finished checking if username exists")
                  
                 }
         }
    }
    
    func handleRegister(name: String, email: String, password: String, username: String) {
           let generator = UIImpactFeedbackGenerator(style: .light)
           generator.impactOccurred()
         

           Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
               
               if error != nil {
                  
                                      
                print(error?.localizedDescription ?? "Error creating user" )
                   return
               }
               
               
               
               guard let uid = user?.user.uid else {
                   return
               }
               
               let db = Firestore.firestore()
               

               let docData: [String: Any] = [
                "dateOfBirth": User.birthdate,
                   "bio": "",
                   "city": "",
                   "state":"",
                   "country": "",
                   "photoUrl":"",
                   "email": email.lowercased(),
                   "name":"",
                   "sex":"",
                   "latitude":"",
                   "longitude":"",
                   "uid": uid,
                   "username":username.lowercased(),
                   "accountCreationDate": NSDate().timeIntervalSince1970
                
                   

               ]
            
            User.uid = uid
            
            db.collection("users").document(uid).setData(docData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.errorLabel.text = err.localizedDescription
                    self.errorLabel.isHidden = false
                } else {
                    print("User successfully created!")
                    let defaults = UserDefaults.standard
                    defaults.set(email, forKey: defaultsKeys.username)
                    defaults.set(password, forKey: defaultsKeys.password)
                    defaults.set(uid, forKey: defaultsKeys.uid)
                    
                    Purchases.configure(withAPIKey: REVENUECATAPIKEY, appUserID: uid)
                    self.showPopup()
                    
                }
            }
        })
    }
    
    func showPopup(){

        // Prepare the popup assets
        let title = "Location Permissions"
        let message = "We use your location to find music near you. Please enable access on the next screen."
        let image = UIImage(named: "limelightBlackBackground")

        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)

    
        

        let okButton = DefaultButton(title: "OK", height: 60) {
            
            self.pushUserLocationViewController()
        }

        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([okButton])

        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func popupDialogSetup(){
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "Poppins-SemiBold", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "Poppins-Regular", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black

        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.7
        ov.color           = .black

        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "Poppins-Regular", size: 14)!
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
            
        
           


    
   
    
    var nameError = false
    var usernameError = false
    var birthdateError = false
    var sexError = false
    var gender = "Male"
    
    func checkError(){
           self.errorLabel.isHidden = true
           
           if nameError != false || usernameError != false || birthdateError != false || sexError != false {
               self.errorLabel.isHidden = false
               self.loadingIndicator.stopAnimating()
           }
       }
    
    var genders = ["Please Select Your Gender", "Male", "Female", "Other", "Prefer Not to Say"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == pickerView {
            return 1
        }
    return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView {
            return genders.count
               }
    return genders.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView {
                   return genders[row]
               }
        
    return genders[row] // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == pickerView {
                   gender = genders[row]
               }
    gender = genders[row] // selected item
    
    }


    @IBAction func nextButtonClicked() {
         self.loadingIndicator.startAnimating()
      
        errorLabel.isHidden = true
        nameError = false
        usernameError = false
        birthdateError = false
        sexError = false
      
        let name = nameTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let sex = gender
        let birthdate = birthDateTextField.date
        
        if name.count == 0 {
            nameError = true
            errorLabel.text = "Please enter a valid name"
        }
        
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
       /* if regex.firstMatch(in: name, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, name.count)) != nil {
           self.nameError = true
            self.errorLabel.text = "Please enter a valid name"
        }*/
        
        if username.count == 0 {
            usernameError = true
            errorLabel.text = "Please enter a valid username"
              self.loadingIndicator.stopAnimating()
        }
        
        /*
        if sex.count == 0 {
            sexError = true
            errorLabel.text = "Please enter a valid sex"
              self.loadingIndicator.stopAnimating()
        }*/
        
        /*
        if birthdate.count == 0{
            birthdateError = true
            errorLabel.text = "Please enter a valid birthdate"
              self.loadingIndicator.stopAnimating()
        }*/
        
        
        
        
        if regex.firstMatch(in: username, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, username.count)) != nil {
            self.usernameError = true
            self.errorLabel.text = "Please enter a valid username"
        }
        
        
        checkError()
       
        
        if !nameError && !usernameError && !sexError && !birthdateError {
            User.name = name
            User.sex = sex
            User.birthdate = String(birthdate.timeIntervalSince1970)
            checkIfUsernameExists(username: username)
        }
        
       
        
       
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


//
//  SignUpViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-19.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseFirestore
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
     @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var emailError = true
    var passwordError = true
    
   
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
        errorLabel.isHidden = true
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func checkError(){
        self.errorLabel.isHidden = true
        
        if emailError != false || passwordError != false {
            self.errorLabel.isHidden = false
             self.loadingIndicator.stopAnimating()
        }
    }
    
    
    
    func pushSignUp2ViewController(){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                   let newViewController = storyBoard.instantiateViewController(withIdentifier: "SignUp2")// as! ChooseGenresViewController
                   navigationController?.pushViewController(newViewController, animated: true)
        
        
          }
       
    
    func checkIfEmailExists(emailString: String){
          
          //NOT COMPLETE YET, UNUSED
         self.loadingIndicator.startAnimating()
          
          let db = Firestore.firestore()
          
          
          db.collection("users")
              .whereField("email", isEqualTo: emailString.lowercased())
              .getDocuments() { (querySnapshot, err) in
                if err != nil {
                      // Some error occured
                    self.errorLabel.text = "An error occured, please try again."
                    self.errorLabel.isHidden = false
                  } else if querySnapshot!.documents.count == 0 { //email doesn't exist in db; is available
                      
                    
                    self.passwordError = false
                    let password = self.passwordTextField.text ?? ""
                    let confirmPassword = self.passwordConfirmTextField.text ?? ""

                    if password != confirmPassword {
                        self.passwordError = true
                        
                         self.errorLabel.text = "Please verify that the passwords match"
                    }
                    
                    if password.count < 5 {
                        self.passwordError = true
                         self.errorLabel.text = "Password must be greater than 5 characters"
                        
                    }
                    
                    let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
                    if regex.firstMatch(in: password, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, password.count)) != nil {
                       self.passwordError = true
                        self.errorLabel.text = "Please enter a valid password"
                    }
                    
                    
                    self.checkError()
                    if self.passwordError == false {
                        User.email = emailString.lowercased()
                        User.password = password
                        self.pushSignUp2ViewController()
                    }
                  
    
                  } else { //email already exists
                    self.emailError = true
                    self.errorLabel.text = "Email address is already in use"
                    self.checkError()
                  }
          }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.errorLabel.isHidden = true
        passwordError = true
        emailError = true
    }
    
    func checkIfPasswordsMatch(password: String, passwordConfirm: String){
        
        if password == passwordConfirm{
            passwordError = false
            checkIfPasswordLengthGood(password: password)
           
        }else{
            passwordError = true
            self.errorLabel.text = "Passwords do not match"
            self.checkError()
            
            
            
        }
        
         
        
    }
    
    func checkIfPasswordLengthGood(password: String){
        if password.count > 5 {
            passwordError = false
        } else {
            passwordError = true
            self.errorLabel.text = "Password must be longer than 5 characters"
        }
        
        if passwordError == false && emailError == false {
            pushSignUp2ViewController()
        }
         
    }
    

     @IBAction func nextButtonClicked() {
        self.errorLabel.isHidden = true
        
        emailError = false
        
        let emailAddress = emailTextField.text ?? ""
       
        
        if emailAddress.count < 1 {
            emailError = true
            self.errorLabel.text = "Please enter a valid email address"
            checkError()
        }else{
             checkIfEmailExists(emailString: emailAddress)
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

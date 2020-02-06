//
//  ReportProblemTableTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-02-04.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import Firebase

class ReportProblemTableTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        self.descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionTextView.layer.borderWidth = 1
        self.subjectTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.subjectTextField.layer.borderWidth = 1
        self.emailTextField.layer.borderWidth = 1
        self.emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.emailTextField.text = User.email
        self.hideKeyboardWhenTappedAround()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
             self.view.endEditing(true)
             self.descriptionTextView.endEditing(true)
            return false
        }
        return true
    }

    
  
    @IBAction func submit(_ sender: UIButton) {
        self.view.endEditing(true)
        self.descriptionTextView.endEditing(true)
        submitButton.isEnabled = false
        submitProblem()
    }
    
    func submitProblem(){
        let db = Firestore.firestore()
                      

                      let docData: [String: Any] = [
                     
                        "email": User.email.lowercased(),
                        "enteredEmail": emailTextField.text ?? "",
                        "name":User.name,
                        "uid": User.uid,
                        "username":User.username.lowercased(),
                        "location": "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")"
                          

                      ]
                   
                   
                   
                   db.collection("ReportedIssues").document().setData(docData) { err in
                       if let err = err {
                           print("Error writing document: \(err)")
                           
                       } else {
                           print("User successfully reported problem ")
                           self.dismiss(animated: true)
                          
                         
                           
                       }
                   }
    }

    // MARK: - Table view data source

  
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

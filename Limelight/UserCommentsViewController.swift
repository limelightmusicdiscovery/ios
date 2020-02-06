//
//  UserCommentsViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import DZNEmptyDataSet

class UserCommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {
    
    var db = Firestore.firestore()
    var profileUid = ""
    var wallPosts = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight;

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           wallPosts.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
           //cell.textLabel?.text = User.likedTracks[indexPath.row].title
           cell.comment = wallPosts[indexPath.row]
           cell.usernameLabel.tag = indexPath.row
                     cell.usernameLabel.isUserInteractionEnabled = true
                     let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
                     cell.usernameLabel.addGestureRecognizer(gestureRecognizer)
           return cell
           
       }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if wallPosts.indices.contains(currentIndex ?? 0) {
             let currentCard =  wallPosts[currentIndex ?? 0]
            
            if currentCard.uid == profileUid{
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
            vc.profileUserId = currentCard.uid
            vc.username = currentCard.username//change to reference
               
                // secondViewController.dataString = textField.text!
               // vc.
                self.navigationController?.pushViewController(vc, animated: true)
                //self.present(vc, animated: true, completion: nil)
                
            
            }
        }
        
    }
    
    let tableView = UITableView()
    
    
      
      
      var safeArea: UILayoutGuide!
      override func loadView() {
          super.loadView()
          view.backgroundColor = .white
          safeArea = view.layoutMarginsGuide
          setupTableView()
      }
      func setupTableView() {
          view.addSubview(tableView)
          tableView.translatesAutoresizingMaskIntoConstraints = false
          tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
          tableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
          tableView.bottomAnchor.constraint(equalTo:  safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true
          tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
          tableView.delegate = self
          tableView.dataSource = self
          tableView.backgroundColor = .clear
          self.view.backgroundColor = .clear
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
      
      }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
             let str = "No Wall Posts"
             let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
             return NSAttributedString(string: str, attributes: attrs)
         }

         
         func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
             let str = "Wall Posts will appear here"
             let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
             
             return NSAttributedString(string: str, attributes: attrs)
         }

         func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
             return UIImage(named: "comment")?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFill)
         }


         func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
             let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "Hurray", style: .default))
             present(ac, animated: true)
         }
    
    func getCurrentUserDetailForPosts(trackId: String){
           let db = Firestore.firestore()
             
             db.collection("users").document(trackId).collection("wallPosts").order(by: "dateCreated", descending: false).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                         
                         
                            
                            let date = data["dateCreated"] as? Double ?? 0.0
                            
                            let uid = data["uid"] as? String ?? "None"
                            let likes = data["likes"] as? Int ?? 0
                            let text = data["text"] as? String ?? "None"
                           
                            let location = data["location"] as? String ?? ""
                            let commentId = document.documentID
                         
                         db.collection("users").document(uid).getDocument() { (document, err) in
                         if err != nil {
                             // Some error occured
                             print("Error ")
                         } else {
                               let data = document?.data()
                              let imgUrl = data?["photoUrl"] as? String ?? "N/A"
                              let username = data?["username"] as? String ?? "N/A"
                            let fcmToken = data?["fcmToken"] as? String ?? "N/A"
                            
                            
                             let comment = Comment(text: text, username: username, uid: uid, profileImage: imgUrl, datePosted: Int(date), commentId: commentId, fcmToken: fcmToken)
                             
                            self.wallPosts.append(comment)
                            
                                 self.tableView.reloadData()
                             
                             
                         
                            
                            
                            
                        }
                         }
                         }
                
                    }
                 
              
              
                
               //  self.getUserInfoForComment()
                 
                 
                }
    }
      
    
 
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        
    }
    
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: wallPosts.count - 1, section: 0)
        
        if wallPosts.indices.contains(indexPath.row){
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            print("Scrolled tableview to bottom")
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

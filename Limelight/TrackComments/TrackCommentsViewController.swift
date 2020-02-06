//
//  TrackCommentsViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-24.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import FirebaseFirestore
class TrackCommentsViewController: UIViewController {
    
    @IBOutlet weak var commentTextfield: UITextField!
    @IBOutlet weak var commentsUIView: UIView!
    @IBOutlet weak var miniProfileImage: UIImageView!
    @IBOutlet weak var sendCommentButton: UIButton!
    var trackId = ""
    var trackTitle = ""
    var trackArtist = ""
    var track: Track?
    
    var controller = AudioController.shared
    
    var commentView = TrackCommentsTableViewController()
    var isKeyboardAppear = false
    
    func loadTrackComments(){
        if trackId != "" {
            commentView.getComments(trackId: trackId)
            commentView.setTrack(trackTitle: trackTitle, trackArtist: trackArtist, trackId: trackId)
        }else{
            print("ERROR: No trackId provided for comments")
        }
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        commentsUIView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        self.addChild(commentView)
        commentsUIView.addSubview(commentView.view)
        commentTextfield.placeholder = "Enter your comment"
        loadTrackComments()
        
        
        
        
        miniProfileImage.makeRounded()
        miniProfileImage.sd_setImage(with: URL(string:  User.imageUrl), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            
            Cache.incrementImageCacheCount()
        })
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillShow(notification:)),name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(notification:)),name: UIResponder.keyboardDidShowNotification, object: nil)
        
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            print("Keyboard Appeared")
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
            isKeyboardAppear = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y += keyboardSize.height
                }
            }
            isKeyboardAppear = false
        }
    }
    
    @IBAction func sendComment(_ sender: UIButton) {
        
        if commentTextfield.text != ""{
            sendComment(text: self.commentTextfield.text ?? "", trackId: trackId)
            commentTextfield.layer.borderWidth = 0
            commentTextfield.placeholder = "Enter your comment"
            
        }else{
            
            commentTextfield.layer.borderColor = UIColor.red.cgColor
            commentTextfield.layer.borderWidth = 1.0
            commentTextfield.placeholder = "Please enter a valid comment"
        }
        
    }
    
    func sendComment(text: String, trackId: String){
        let db = Firestore.firestore()
        
        if User.name != ""{
               
            System.push.sendPushNotification(to:FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "", body:  "\(User.name) (\(User.username)) posted a comment on \(track?.title ?? "your track").")
                       
                   }
               
                   
               else{
                    System.push.sendPushNotification(to: FirebaseManager.fcmTokenDict[track?.artistUid ?? BIZLALUID] ?? BIZLALUID, title: "",body:  "\(User.username) posted a comment on \(track?.title ?? "your track").")
                              }
        
        
        view.endEditing(true)
        let document = db.collection("all-tracks").document(trackId).collection("comments").document()
        let comment = Comment(text: text, username: User.username, uid: User.uid, profileImage: User.imageUrl, datePosted: Int(NSDate().timeIntervalSince1970), commentId: document.documentID, fcmToken: User.fcmToken)
        commentView.trackComments.append(comment)
        
        commentView.tableView.reloadData()
        
        document.setData([
            "dateCreated": NSDate().timeIntervalSince1970,
            "uid": User.uid,
            "likes": 0,
            "text": text]
            
            
        ) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.commentTextfield.text = ""
                self.controller.incrementCommentCount(trackId: trackId)
                Analytics.logEvent(TRACKCOMMENTEVENT, parameters: [
                                             "username": User.username,
                                             "comment": text,
                                             "trackId": trackId,
                                             "location":  "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")",
                                             "outreach50km": User.outreachIn50km
                                             ])
                
                
                
            }
        }
        
        
    }
    
    var delegate: cardControl?
    
    override func viewDidDisappear(_ animated: Bool) {
        print("comments did disappear")
        self.delegate?.reloadCards()
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

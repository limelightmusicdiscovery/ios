import UIKit
import Firebase
import FirebaseFirestore
import DZNEmptyDataSet

class TrackCommentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate,  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var db = Firestore.firestore()
    var trackComments = [Comment]()
    var trackTitle = ""
    var trackArtist = ""
    var trackId = ""
    var controller = AudioController.shared
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "No Comments"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
           return NSAttributedString(string: str, attributes: attrs)
       }

       
       func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "Tracks comments will appear here"
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

    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.hideKeyboardWhenTappedAround()
      

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        
        if trackComments[indexPath.row].uid == User.uid {
            
            return true
            
        }


        return false
    }
    
    
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
        
        
        if trackComments.indices.contains(indexPath.row){
            
            let commentId = trackComments[indexPath.row].commentId
            trackComments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            deleteComment(trackId: trackId, commentId: commentId )
             
           
        }
        
       
     }
    }
    
   
   
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if trackComments.count == 1 {
            return "\(trackComments.count) Comment • \(trackTitle) by \(trackArtist)"
        }

        return "\(trackComments.count) Comments • \(trackTitle) by \(trackArtist)"
    }
  
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackComments.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
           //cell.textLabel?.text = User.likedTracks[indexPath.row].title
           cell.comment = trackComments[indexPath.row]

           cell.usernameLabel.tag = indexPath.row
           cell.usernameLabel.isUserInteractionEnabled = true
           let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
           cell.usernameLabel.addGestureRecognizer(gestureRecognizer)
           return cell
           
       }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if trackComments.indices.contains(currentIndex ?? 0) ?? false{
             let currentCard =  trackComments[currentIndex ?? 0]
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
    
    
    
    
  
    let tableView = UITableView()
    
    
      
      
      var safeArea: UILayoutGuide!
      override func loadView() {
          super.loadView()
      
          safeArea = view.layoutMarginsGuide
          setupTableView()
      }
      func setupTableView() {
          view.addSubview(tableView)
          tableView.translatesAutoresizingMaskIntoConstraints = false
          tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
          tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
          tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
          tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

          tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
          tableView.delegate = self
          tableView.dataSource = self
          tableView.backgroundColor = .clear
          self.view.backgroundColor = .clear
        tableView.emptyDataSetSource = self
                      tableView.emptyDataSetDelegate = self
                      tableView.tableFooterView = UIView()
       
          
          
        // getComments()
          
      }
    
    func setTrack(trackTitle: String, trackArtist: String, trackId: String){
        self.trackTitle = trackTitle
        self.trackArtist = trackArtist
        self.trackId = trackId
    }
    
    func deleteComment(trackId: String, commentId: String){
        
       // let commentIndex = getCommentIndexById(commentId: commentId)
        
       
        
        
        db.collection("all-tracks").document(trackId).collection("comments").document(commentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.controller.decrementCommentCount(trackId: trackId)
            }
        }
    }
    
    var commentIds = [String]()
      
    
    func getComments(trackId: String){
        
           let db = Firestore.firestore()
        
        db.collection("all-tracks").document(trackId).collection("comments").order(by: "dateCreated", descending: false).getDocuments() { (querySnapshot, err) in
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
                        
                       
                        if !self.commentIds.contains(commentId){
                            self.trackComments.append(comment)
                            self.tableView.reloadData()
                        }
                        
                        if self.trackComments.count == self.commentIds.count {
                               self.scrollToBottom()
                        }
                    
                       
                       
                       
                   }
                    }
                    }
           
               }
            
            print(self.trackComments.count)
         
           
          //  self.getUserInfoForComment()
            
            
           }
           
     
       }
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.trackComments.count - 1, section: 0)
        print("Attempting scroll to bottom: \(self.trackComments.count)")
        if self.trackComments.indices.contains(indexPath.row){
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            print("Scrolled tableview to bottom")
        }
       
    }
    
    func getCommentIndexById(commentId: String) -> Int {
        
        var i = 0
        var index = -1
        
        while i < trackComments.count {
            if trackComments[i].commentId == commentId{
                index = i
            }
            i += 1
        }
        
        return index
    }
    
    func getUserInfoForComment(){
        let db = Firestore.firestore()
        var i = 0
        while i < self.trackComments.count {
            print("Attempting for \(self.trackComments[i].uid)")
            db.collection("users").document(self.trackComments[i].uid).getDocument() { (document, err) in
                if err != nil {
                    // Some error occured
                    print("Error For: \( self.trackComments[i].uid)")
                } else {
                      let data = document?.data()
                     let imgUrl = data?["photoUrl"] as? String ?? "N/A"
                    let username = data?["username"] as? String ?? "N/A"
                    let fcmToken = data?["fcmToken"] as? String ?? "N/A"
                    
                    print("Adjusted comment for \(username)")
                    
                    if self.trackComments.indices.contains(i){
                        self.trackComments[i].profileImage = imgUrl
                        self.trackComments[i].username = username
                        self.trackComments[i].fcmToken = fcmToken
                        self.tableView.reloadData()
                        
                    }
                    
                   
                
                }
            }
            i = i + 1
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

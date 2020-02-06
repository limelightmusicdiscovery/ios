//
//  FollowingViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-16.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import Firebase

class FollowingViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating  {
    func updateSearchResults(for searchController: UISearchController) {
        print("update")
    }
    
    
    var db = Firestore.firestore()
    var followingArray = [LimelightUser]()
    var followingKeys = [String]()
    var followerKeys = [String]()
    var profileUid = User.uid
  
       
    func checkIfFollowingUsers(){
           var i = 0
           
           while i < followingArray.count {
               if !User.followingIds.contains(followingArray[i].uid){
                   followingArray.remove(at: i)
               }
               i = i + 1
           }
           
           tableView.reloadData()
       }
          
       override func viewDidAppear(_ animated: Bool) {
           if profileUid == User.uid {
               checkIfFollowingUsers()
           }
       }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        followingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
        
        cell.user = followingArray[indexPath.row]
     //  cell.followButton.addTarget(self, action: #selector(followButton(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
     let currentIndex = indexPath.row
            
            if followingArray.indices.contains(currentIndex ?? 0) {
                     
                     let currentUser = followingArray[currentIndex ?? 0]
             
             if currentUser.uid == profileUid{
                 let generator = UINotificationFeedbackGenerator()
                 generator.notificationOccurred(.error)
             }else{
                     let storyboard = UIStoryboard(name: "Main", bundle: nil)
                     
                     let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
             vc.profileUserId = currentUser.uid
             vc.username = currentUser.username //change to reference
                     
                     // secondViewController.dataString = textField.text!
                     // vc.
                     self.navigationController?.pushViewController(vc, animated: true)
                     //self.present(vc, animated: true, completion: nil)
                     
                 }
            
     }
            
            
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc func followButton(_ sender: UIButton){
           let generator = UINotificationFeedbackGenerator()
           generator.notificationOccurred(.error)
       }
    
    
    
    
    
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    override func loadView() {
        super.loadView()
        view.backgroundColor = .black
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
        tableView.register(UserCell.self, forCellReuseIdentifier: "userCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = true
        controller.searchBar.sizeToFit()
        
        tableView.tableHeaderView = controller.searchBar
        
        getFollowing(followingKeys: followingKeys)
        
    }
    
  
    
    func getFollowing(followingKeys: [String]){
        
      
        var count = 0
        
        
        
        for userId in followingKeys{
            
            
            let db = Firestore.firestore()
            
            print("Attempting For: \(userId)")
            db.collection("users").document(userId)
                
                .getDocument() { (document, err) in
                    if err != nil {
                        // Some error occured
                        print("Error For: \(userId)")
                    } else {
                        
                        let data = document?.data()
                        
                        
                      
                        let username = data?["username"] as? String ?? "None"
                        let name = data?["name"] as? String ?? "None"
                        let uid = userId
                        let profileImage = data?["photoUrl"] as? String ?? "None"
                        let listenerPoints =  data?["listenerPoints"] as? Int ?? 0
                          print("follower: \(username)")
                        let user = LimelightUser(uid: uid, username: username, name: name, profileImage: profileImage, listenerPoints: listenerPoints, followerKeys: [""], followingKeys: [""], following: [LimelightUser](), followers: [LimelightUser](), isFollowing: true)
                        
                        // self.trackArray.append(track)
                        if user.username != "None"{
                            self.followingArray.append(user)
                            
                            print("Done For: \(userId)")
                            count = count + 1
                            print("Done: \(count)/\(followingKeys.count)")
                            if count == followingKeys.count {
                                print("refreshing")
                                
                            
                                self.tableView.reloadData()
                                
                                
                                //self.controller.player.play()
                                
                            }
                        }
                        
                        //self.cardSwiper.reloadData()
                        
                        // self.tableView.reloadData()
                        
                        
                    }
            }
            
            
            
        }
        
        
        
        
    }
}



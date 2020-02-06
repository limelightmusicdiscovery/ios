//
//  FollowersViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating  {
    func updateSearchResults(for searchController: UISearchController) {
        print("update")
    }
    
    
    var db = Firestore.firestore()
    var followerArray = [LimelightUser]()
    var followerKeys = [String]()
    var followingKeys = [String]()
    var profileUid = User.uid
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        followerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
        
        cell.user = followerArray[indexPath.row]
        
       // cell.followButton.addTarget(self, action: #selector(followButton(_:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndex = indexPath.row
               
               if followerArray.indices.contains(currentIndex ?? 0) {
                        
                        let currentUser = followerArray[currentIndex ?? 0]
                
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
        
        System.getUsersByUids(uids: followerKeys) { (uids) in
            self.followerArray = uids
            UIView.transition(with: self.tableView,
                                                                                                                              duration: 0.35,
                                                                                                                              options: .transitionCrossDissolve,
                                                                                                                              animations: { self.tableView.reloadData() })
            
        }
        
       // getFollowers(followerKeys: followerKeys)
        
    }
    
    
    
    func getFollowers(followerKeys: [String]){
        
        print("followerKeys: \(followerKeys.count)")
        
      
        var count = 0
        
        
        
        for userId in followerKeys{
            
            
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
                        var isFollowing = false
                        
                        if User.followingIds.contains(uid){
                            isFollowing = true
                        }
                        
                        
                        let user = LimelightUser(uid: uid, username: username, name: name, profileImage: profileImage, listenerPoints: listenerPoints, followerKeys: [""], followingKeys: [""], following: [LimelightUser](), followers: [LimelightUser](), isFollowing: isFollowing)
                        
                        // self.trackArray.append(track)
                        if user.username != "None"{
                            self.followerArray.append(user)
                            
                            print("Done For: \(userId)")
                            count = count + 1
                            if count == followerKeys.count {
                                
                            
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


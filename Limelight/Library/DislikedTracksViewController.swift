//
//  DislikedTracksViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-09.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftAudio
import DZNEmptyDataSet

class DislikedTracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
func updateSearchResults(for searchController: UISearchController) {
    print("update")
    
    }
    
    var db = Firestore.firestore()
    var libraryRef = DISLIKEDTRACKS
    var trackKeysArray =  User.trackKeys[DISLIKEDTRACKS]
    var trackArray = User.dislikedTracks
    var controller = AudioController.shared
    var loadedTracks = 0
    lazy var refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
           if User.cards[DISLIKEDTRACKS]?.count != loadedTracks {
              // tableView.reloadData()
               loadedTracks = User.cards[DISLIKEDTRACKS]?.count ?? 0
           }
       }
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         User.cards[DISLIKEDTRACKS]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
         if User.cards[DISLIKEDTRACKS]?.indices.contains(indexPath.row) ?? false{
                  cell.track = User.cards[DISLIKEDTRACKS]?[indexPath.row]
                         
                              cell.trackArtistLabel.tag = indexPath.row
                              cell.trackArtistLabel.isUserInteractionEnabled = true
                              let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
                              cell.trackArtistLabel.addGestureRecognizer(gestureRecognizer)
                       
              }
              
             
                return cell
    }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if User.cards[DISLIKEDTRACKS]?.indices.contains(currentIndex ?? 0) ?? false{
            if let currentCard =  User.cards[DISLIKEDTRACKS]?[currentIndex ?? 0] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                vc.profileUserId = currentCard.artistUid
                vc.username = currentCard.artistUsername //change to reference
               
                // secondViewController.dataString = textField.text!
               // vc.
                self.navigationController?.pushViewController(vc, animated: true)
                //self.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
              if controller.currentSource != DISLIKEDTRACKS {
                   controller.player.stop()
              }
             
              
              controller.playTrack(index: indexPath.row, source: DISLIKEDTRACKS)
           controller.preloadTrack(index: indexPath.row + 1, source: DISLIKEDTRACKS)
      //  showMusicPlayer(track: (User.cards[DISLIKEDTRACKS]?[indexPath.row])!)
            // controller.showMusicPlayer(track: (User.cards[DISLIKEDTRACKS]?[indexPath.row])!, tabBarController: self.tabBarController!)
           tableView.deselectRow(at: indexPath, animated: true)
             
          }
       func setupSearchBar(){
           let controller = UISearchController(searchResultsController: nil)
                  controller.searchResultsUpdater = self
                  controller.dimsBackgroundDuringPresentation = true
                  controller.searchBar.sizeToFit()
                  
                  tableView.tableHeaderView = controller.searchBar
           self.hideKeyboardWhenTappedAround()
       }
    
    
  let tableView = UITableView()
  var safeArea: UILayoutGuide!
  override func loadView() {
    super.loadView()
    view.backgroundColor = .red
    safeArea = view.layoutMarginsGuide
    setupTableView()
   NotificationCenter
                 .default
                     .addObserver(
                         self,
                         selector: #selector(reloadTableView),
                         name: NSNotification.Name(rawValue: "dataDeleted"),
                         object: nil)
             }

         @objc func reloadTableView() {
                  DispatchQueue.main.async {
                           self.tableView.reloadData()
                       }

             }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "No Disliked Tracks"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
           return NSAttributedString(string: str, attributes: attrs)
       }

       
       func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "Tracks you dislike will appear here"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
           
           return NSAttributedString(string: str, attributes: attrs)
       }

       func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
           return UIImage(named: "thumbsDown")?.sd_resizedImage(with: CGSize(width: 40, height: 40), scaleMode: .aspectFill)
       }


       func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
           let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "Hurray", style: .default))
           present(ac, animated: true)
       }
    
    func setupTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(TrackCell.self, forCellReuseIdentifier: "trackCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        tableView.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
              tableView.emptyDataSetSource = self
              tableView.emptyDataSetDelegate = self
              tableView.tableFooterView = UIView()
         tableView.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
       // setupSearchBar()
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
       
      //  getTrackKeys(uid: User.uid)
        
        System.getTrackIdsBySource(uid: User.uid, source: DISLIKEDTRACKS) { (trackIds) in
                   User.trackKeys[DISLIKEDTRACKS] = trackIds
                   System.getTracksByIdsForSource(source: DISLIKEDTRACKS, trackIds: trackIds) { (tracks) in
                       
                       //User.cards[DISLIKEDTRACKS] = tracks
                        UIView.transition(with: self.tableView,
                                             duration: 0.35,
                                             options: .transitionCrossDissolve,
                                             animations: { self.tableView.reloadData() })
                                             print(tracks.count)
                                         
                       print(tracks.count)
                    FirebaseManager.getUserInfoForTracks(source: DISLIKEDTRACKS)
                   }
                   
                //   self.getLikedTracks(trackKeys: trackIds)
               }
        
       let longPressRecognizer = UILongPressGestureRecognizer(target: self,  action: #selector(longPress))
                   tableView.addGestureRecognizer(longPressRecognizer)
                  
             
         }
         //Called, when long press occurred
         @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {

             if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let touchPoint = longPressGestureRecognizer.location(in: tableView)
                 if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                     guard let popupNavController = storyboard.instantiateViewController(withIdentifier: "TrackOptions") as? TrackOptionsViewController else { return }
                          popupNavController.height = TRACKOPTIONSHEIGHT
                          popupNavController.topCornerRadius = TRACKOPTIONSCORNER
                      popupNavController.presentDuration = TRACKOPTIONSSPEED
                        popupNavController.dismissDuration = TRACKOPTIONSSPEED
                    popupNavController.source = DISLIKEDTRACKS
                    popupNavController.index = indexPath.row
                      popupNavController.track = User.cards[DISLIKEDTRACKS]?[indexPath.row ]
                         let generator =  UIImpactFeedbackGenerator(style: .heavy)
                      generator.impactOccurred()
                          present(popupNavController, animated: true, completion: nil)
                     // your code here, get the row for the indexPath or do whatever you want
             }
             }
         }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
    //    User.trackKeys[DISLIKEDTRACKS]?.removeAll()
            //   loadedTracks.removeAll()
            //   User.cards[DISLIKEDTRACKS]?.removeAll()
     //   self.getTrackKeys(uid: User.uid)
        self.refreshControl.endRefreshing()
      
        
    }
    
    func getTrackKeys(uid: String){
        
        db.collection("users").document(uid).collection(libraryRef).order(by: "dateAdded", descending: false).getDocuments { (snapshot, error) in
            
            print("Total \(self.libraryRef) documents: \(snapshot!.count)")
            if let error = error
            {
                print("Error getting documents from \(self.libraryRef): \(error)");
            }
            else
            {
                
                for document in snapshot!.documents {
                    
                    let data = document.data()
                                      
                                      
                    let trackId = data["trackId"] as? String ?? "None"
                    
                    if !(User.trackKeys[DISLIKEDTRACKS]?.contains(trackId) ?? false){
                                             User.trackKeys[DISLIKEDTRACKS]?.append(trackId)
                                       }
                    
                  
                }
                
                print("Getting \(User.trackKeys[DISLIKEDTRACKS]?.count) \(self.libraryRef) Tracks")
                self.getTracks(trackKeys: User.trackKeys[DISLIKEDTRACKS] ?? [])
                
                
            }
            
            
        }
        
    }
        
    
    func getTracks(trackKeys: [String]){
        
        self.refreshControl.beginRefreshing()
        
        print("getting \(libraryRef) tracks")
        print("trackKeys count: \(trackKeys.count)")
        self.refreshControl.endRefreshing()
        var count = 0
        

        for trackId in trackKeys{
            
            
            let db = Firestore.firestore()
            
            print("Attempting For: \(trackId)")
            db.collection("all-tracks").document(trackId)
                
                .getDocument() { (document, err) in
                    if err != nil {
                        // Some error occured
                        print("Error For: \(trackId)")
                    } else {
                        
                        let data = document?.data()
                        
                        
                        _ = data?["artist"] as? String ?? "None"
                        _ = data?["producer"] as? String ?? "None"
                        let username = data?["username"] as? String ?? "None"
                        let trackName = data?["title"] as? String ?? "None"
                        let description = data?["description"] as? String ?? "None"
                        let genre = data?["genre"] as? String ?? "None"
                        let coverURL = data?["imgUrl"] as? String ?? "None"
                        let backgroundURL = data?["username"] as? String ?? "None"
                        let albumName = data?["album_title"] as? String ?? "None"
                        let trackURL = data?["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                        var radius = data?["radius"] as? String ?? "0"
                        
                        var latitude = data?["latitude"] as? String ?? "0.0"
                        var longitude = data?["longitude"] as? String ?? "0.0"
                        
                        
                        let city = data?["city"] as? String ?? "None"
                        let state = data?["state"] as? String ?? "None"
                        let country = data?["country"] as? String ?? "None"
                        let uid = data?["uid"] as? String ?? "None"
                        let id = document?.documentID
                        let unixDate = data?["time"] as? Int ?? 1561696540741
                        let likedBy = data?["likedBy"] as? [String: Any] ?? ["false":"false"]
                        let dislikedBy = data?["dislikedBy"] as? [String: Any] ?? ["false":"false"]
                        let streamCount = data?["streamCount"] as? Int ?? 0
                        let soundcloudLink = data?["soundcloudLink"] as? String ?? "None"
                        let spotifyLink = data?["spotifyLink"] as? String ?? "None"
                        let itunesLink = data?["itunesLink"] as? String ?? "None"
                        let Id = document?.documentID
                        let totalLikes =  data?["totalLikes"] as? Int ?? 0
                        let totalDislikes =  data?["totalDisikes"] as? Int ?? 0
                        let limelightLink = "" //need to finish
                        
                        let trackRadius = Int(radius) ?? 0
                        let trackLatitude = Double(latitude) ?? 0.0
                        let trackLongitude = Double(longitude) ?? 0.0
                         let audioItem = DefaultAudioItem(audioUrl: String(trackURL), artist: String(username), title: String(trackName), albumTitle: String(albumName), sourceType: .stream ,artwork: #imageLiteral(resourceName: "itunes_13_icon__png__ico__icns__by_loinik_d8wqjzr-pre"))
                        
                        var likePercentage = 0.0
                        let commentCount =  data?["commentCount"] as? Int ?? 0
                         
                        
                         
                         if totalLikes != 0 && totalDislikes != 0 {
                             let totalLikeDislikeCount = totalLikes + totalDislikes
                             likePercentage = (Double(totalLikes) / Double(totalLikeDislikeCount))
                             print("\(trackName): \(likePercentage)% [\(totalLikes) + \(totalDislikes) = \(totalLikeDislikeCount)]")
                         }
                          
                        
                        let track = Track(artistUsername: username, artistUid: uid, genre: genre, albumTitle: albumName, description: description, imageUrl: coverURL, socials:[APPLEMUSIC: itunesLink,
                                                                                                                                                                                SOUNDCLOUD: soundcloudLink,
                                                                                                                                                                                SPOTIFY: spotifyLink,
                                                                                                                                                                                LIMELIGHT: limelightLink], socialClicks: [APPLEMUSIC: 0,
                                                                                                                                                                                                                          SOUNDCLOUD: 0,
                                                                                                                                                                                                                          SPOTIFY: 0,
                                                                                                                                                                                                                          LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes, commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: DISLIKEDTRACKS, audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                        
                        
                        count = count + 1
                        if track.trackUrl != "None" {
                            User.cards[DISLIKEDTRACKS]?.append(track)
                                                                        
                                                                        
                                                                     
                        }
                        
                        if count == trackKeys.count {
                            print("done loading disliked tracks")
                                                                                                 
                                                                                                 self.controller.addTracksToSource(trackArray:  User.cards[DISLIKEDTRACKS] ?? [] , source: DISLIKEDTRACKS)
                                                                                                 self.controller.loadTracks(source: DISLIKEDTRACKS)
                                                                                                 self.tableView.reloadData()
                                                                                                   self.refreshControl.endRefreshing()
                              FirebaseManager.getUserInfoForTracks(source: DISLIKEDTRACKS)                                                       
                                                                                                 //self.controller.player.play()
                                                                                                 
                                                                                             }
                        
                    
                                               
                        
                        //self.tableView.reloadData()
                        
                        
                    }
            }
            
            
            
        }
        
       
        
        
    }
}



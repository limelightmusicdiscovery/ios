//
//  LikedTracksViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-09.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftAudio
import ChameleonFramework
import BottomPopup
import DZNEmptyDataSet

class LikedTracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchResultsUpdating, BottomPopupDelegate,  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    func bottomPopupDidAppear() {
        self.tableView.reloadData()
    }
func updateSearchResults(for searchController: UISearchController) {
     let searchBar = searchController.searchBar
     filterContentForSearchText(searchBar.text!)
 }
 
 
 let tableView = UITableView()
 var filteredTracks: [Track] = []
 var searchController = UISearchController(searchResultsController: nil)
 var isSearchBarEmpty: Bool {
     return searchController.searchBar.text?.isEmpty ?? true
 }
 var isFiltering: Bool {
     return searchController.isActive && !isSearchBarEmpty
 }
 
 func setupSearchBar(){
     
     self.extendedLayoutIncludesOpaqueBars = true
     //let searchController = UISearchController(searchResultsController: nil)
     //let controller = UISearchController(searchResultsController: nil)
     searchController.searchResultsUpdater = self
     // controller.dimsBackgroundDuringPresentation = true
     searchController.searchBar.sizeToFit()
     
     tableView.tableHeaderView = searchController.searchBar
     //self.definesPresentationContext = true
     //  tableView.setContentOffset(CGPoint(x: 0,y: self.searchController.searchBar.frame.size.height), animated: false)
     
     self.hideKeyboardWhenTappedAround()
     
 }
 
 func filterContentForSearchText(_ searchText: String
 ) {
     filteredTracks = (User.cards[LIKEDTRACKS]?.filter { (track: Track) -> Bool in
         return track.title.lowercased().contains(searchText.lowercased())
         })!
     
     tableView.reloadData()
 }
 
    lazy var refreshControl = UIRefreshControl()
    var db = Firestore.firestore()
    var controller = AudioController.shared
    var loadedTrackCount = 0
    
    
    
    override func viewDidAppear(_ animated: Bool) {
          print("liked tracks did appear")
        tableView.reloadData()
        if User.trackKeys[LIKEDTRACKS]?.count != loadedTrackCount {
            loadedTrackCount =  User.trackKeys[LIKEDTRACKS]?.count ?? 0
            //reload the data for new tracks added
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
                   return filteredTracks.count
               }
               
        return User.cards[LIKEDTRACKS]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
         if User.cards[LIKEDTRACKS]?.indices.contains(indexPath.row) ?? false{
                 let track = User.cards[LIKEDTRACKS]?[indexPath.row]
                             if isFiltering {
                                 cell.track = filteredTracks[indexPath.row]
                             }else {
                                 cell.track = track
                             }
                             
                         
                              cell.trackArtistLabel.tag = indexPath.row
                              cell.trackArtistLabel.isUserInteractionEnabled = true
                              let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
                              cell.trackArtistLabel.addGestureRecognizer(gestureRecognizer)
                       
              }
              
             
                return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if controller.currentSource != LIKEDTRACKS {
            controller.player.stop()
        }
        
        
        controller.playTrack(index: indexPath.row, source: LIKEDTRACKS)
        controller.preloadTrack(index: indexPath.row + 1, source: LIKEDTRACKS)
        //controller.showMusicPlayer(track: (User.cards[LIKEDTRACKS]?[indexPath.row])!, tabBarController: self.tabBarController!)
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
   
    
    
    var safeArea: UILayoutGuide!
    override func loadView() {
        super.loadView()
        view.backgroundColor = .black
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
        print("reloadTableView")
          //  self.definesPresentationContext = true
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

            
        }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "No Liked Tracks"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
           return NSAttributedString(string: str, attributes: attrs)
       }

       
       func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "Tracks you like will appear here"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
           
           return NSAttributedString(string: str, attributes: attrs)
       }

       func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
           return UIImage(named: "thumbsUp")?.sd_resizedImage(with: CGSize(width: 40, height: 40), scaleMode: .aspectFill)
       }


       func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
           let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "Hurray", style: .default))
           present(ac, animated: true)
       }

  
    func setupTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
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
        //tableView.separatorColor?.withAlphaComponent(0.5)
        //self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
       // setupSearchBar()
        
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        
        System.getTrackIdsBySource(uid: User.uid, source: LIKEDTRACKS) { (trackIds) in
            User.trackKeys[LIKEDTRACKS] = trackIds
            System.getTracksByIdsForSource(source: LIKEDTRACKS, trackIds: trackIds) { (tracks) in
                UIView.transition(with: self.tableView,
                                      duration: 0.35,
                                      options: .transitionCrossDissolve,
                                      animations: { self.tableView.reloadData() })
                                      print(tracks.count)
                                  
               
                  FirebaseManager.getUserInfoForTracks(source: LIKEDTRACKS)
                print(tracks.count)
            }
            
         //   self.getLikedTracks(trackKeys: trackIds)
        }
       // getLikedTrackKeys(uid: User.uid)
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
                popupNavController.source = LIKEDTRACKS
                print("longpress index: \(indexPath.row)")
                               popupNavController.index = indexPath.row
                               popupNavController.track = User.cards[LIKEDTRACKS]?[indexPath.row ]
                     popupNavController.height = TRACKOPTIONSHEIGHT
                     popupNavController.topCornerRadius = TRACKOPTIONSCORNER
                popupNavController.presentDuration = TRACKOPTIONSSPEED
                popupNavController.dismissDuration = TRACKOPTIONSSPEED
                    let generator =  UIImpactFeedbackGenerator(style: .heavy)
                 generator.impactOccurred()
               
               
                
                     present(popupNavController, animated: true, completion: nil)
                // your code here, get the row for the indexPath or do whatever you want
        }
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        //User.trackKeys[LIKEDTRACKS]?.removeAll()
              // loadedTracks.removeAll()
             //  User.cards[LIKEDTRACKS]?.removeAll()
        
     //   self.getLikedTrackKeys(uid: User.uid)
        self.refreshControl.endRefreshing()
      
        
    }
    
  
    
  
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if User.cards[LIKEDTRACKS]?.indices.contains(currentIndex ?? 0) ?? false{
            if let currentCard =  User.cards[LIKEDTRACKS]?[currentIndex ?? 0] {
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
    
    
    
    
    
    func getLikedTrackKeys(uid: String){
        db.collection("users").document(uid).collection("likedTracks").order(by: "dateAdded", descending: true).getDocuments { (snapshot, error) in
            
            print("Total liked track documents: \(snapshot!.count)")
            if let error = error
            {
                print("Error getting documents from likedTracks: \(error)");
            }
            else
            {
                
                for document in snapshot!.documents {
                    
                    let data = document.data()
                    
                    
                    let trackId = data["trackId"] as? String ?? "None"
                    
                    if !(User.trackKeys[LIKEDTRACKS]?.contains(trackId) ?? false){
                          User.trackKeys[LIKEDTRACKS]?.insert(trackId, at: 0)
                    }
                    
                    
                }
                
                print("Getting \( User.trackKeys[LIKEDTRACKS]?.count) Liked Tracks")
                self.getLikedTracks(trackKeys:   User.trackKeys[LIKEDTRACKS] ?? [])
                
                
            }
            
            
        }
        
    }
    
    var loadedTracks = [String]()
    
    func getLikedTracks(trackKeys: [String]){
        
        print("getting liked tracks")
        print("trackKeys count: \(trackKeys.count)")
        var count = 0
        
        
        for trackId in trackKeys{
            
            if !loadedTracks.contains(trackId){
                
                
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
                            _ = data?["username"] as? String ?? "None"
                            let albumName = data?["album_title"] as? String ?? "None"
                            let trackURL = data?["trackUrl"] as? String ?? "http://www.noiseaddicts.com/samples_1w72b820/2514.mp3"
                            let radius = data?["radius"] as? String ?? "0"
                            
                            let latitude = data?["latitude"] as? String ?? "0.0"
                            let longitude = data?["longitude"] as? String ?? "0.0"
                            
                            
                            let city = data?["city"] as? String ?? "None"
                            let state = data?["state"] as? String ?? "None"
                            let country = data?["country"] as? String ?? "None"
                            let uid = data?["uid"] as? String ?? "None"
                            _ = document?.documentID
                            let unixDate = data?["time"] as? Int ?? 1561696540741
                            _ = data?["likedBy"] as? [String: Any] ?? ["false":"false"]
                            _ = data?["dislikedBy"] as? [String: Any] ?? ["false":"false"]
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
                                                                                                                                                                                                                              LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes, commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: LIKEDTRACKS,audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                            
                            count = count + 1
                            
                            
                            if track.trackUrl != "None" {
                                User.cards[LIKEDTRACKS]?.append(track)
                                
                                self.loadedTracks.append(trackId)
                                //self.tableView.reloadData()
                            }
                            
                            
                            //self.controller.player.play()
                            
                        }
                        
                        
                        print("Done For: \(trackId)")
                        self.tableView.reloadData()
                        
                        if count == trackKeys.count {
                            print("adding \(LIKEDTRACKS) to audio source")
                            self.controller.addTracksToSource(trackArray:  User.cards[LIKEDTRACKS] ?? [] , source: LIKEDTRACKS)
                           // self.controller.loadTracks(source: LIKEDTRACKS)
                            self.loadedTrackCount = trackKeys.count
                            self.tableView.reloadData()
                            
                        }
                        //self.cardSwiper.reloadData()
                        
                        //self.tableView.reloadData()
                        
                        
                }
            }
            
            
        }
         self.controller.addTracksToSource(trackArray:  User.cards[LIKEDTRACKS] ?? [] , source: LIKEDTRACKS)
          FirebaseManager.getUserInfoForTracks(source: LIKEDTRACKS) 
          self.tableView.reloadData()
        self.refreshControl.endRefreshing()
      
    }
    
   
    
    /*
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Discover Music"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }*/

    
    
    
    
}


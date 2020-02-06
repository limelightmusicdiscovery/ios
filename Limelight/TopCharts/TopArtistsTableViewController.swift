//
//  TopArtistsTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-18.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftAudio
import Alamofire
import SwiftyJSON

class TopArtistsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    var db = Firestore.firestore()
    var controller = AudioController.shared
    
    var artistKeys = [String]()
    lazy var refreshControl = UIRefreshControl()
    lazy var topArtists = [Artist]()
    
    var artistStreamDict = [String: Int]()
    
    
    
    
    lazy var loadedArtists = [String]()
    var chartingVariable = ARTISTS
    var chartType = WEEKLYTOPTRACKS
    var startDate = ""
    
    
    var formatter = DateFormatter()
    var endDate = ""
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return topArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistCell
        
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
        cell.rank = indexPath.row
        cell.artist = topArtists[indexPath.row]
        
        
        cell.nameLabel.tag = indexPath.row
        cell.nameLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
        cell.nameLabel.addGestureRecognizer(gestureRecognizer)
        
        
        
        
        
        
        return cell
        
    }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        
        
        if topArtists.indices.contains(currentIndex ?? 0) {
            
            let currentArtist = topArtists[currentIndex ?? 0]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
            vc.profileUserId = currentArtist.uid
            vc.username = currentArtist.username //change to reference
            
            // secondViewController.dataString = textField.text!
            // vc.
            self.navigationController?.pushViewController(vc, animated: true)
            //self.present(vc, animated: true, completion: nil)
            
        }
        
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndex = indexPath.row
        
        if topArtists.indices.contains(currentIndex ?? 0) {
                 
                 let currentArtist = topArtists[currentIndex ?? 0]
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 
                 let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                 vc.profileUserId = currentArtist.uid
                 vc.username = currentArtist.username //change to reference
                 
                 // secondViewController.dataString = textField.text!
                 // vc.
                 self.navigationController?.pushViewController(vc, animated: true)
                 //self.present(vc, animated: true, completion: nil)
                 
             }
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
    
    let tableView2 = UITableView()
    
    
    var safeArea: UILayoutGuide!
    var chartLoaded = false
    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
        safeArea = view.layoutMarginsGuide
        
        if chartLoaded != true {
            setupTableView()
        }
        
    }
    func setupTableView() {
        self.view.addSubview(tableView2)
        tableView2.translatesAutoresizingMaskIntoConstraints = false
        tableView2.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView2.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView2.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        tableView2.register(ArtistCell.self, forCellReuseIdentifier: "artistCell")
        
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView2.backgroundColor = .clear
        self.view.backgroundColor = .clear
        tableView2.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
        tableView2.addSubview(refreshControl)
        //self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        
        let date = Date()
        formatter.dateFormat = "yyyyMMdd"
        self.endDate = formatter.string(from: Date())
        
        let last1Day = Calendar.current.date(byAdding: .day, value: -1, to: Date())
               let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())
               let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date())
               let last365Days = Calendar.current.date(byAdding: .day, value: -365, to: Date())
               
               switch chartType {
               case DAILYTOPTRACKS:
                   self.startDate =  formatter.string(from: last1Day!)
               case WEEKLYTOPTRACKS:
                       self.startDate =  formatter.string(from: last7Days!)
                       //self.endDate = formatter.string(from: date)
               case MONTHLYTOPTRACKS:
                   self.startDate =  formatter.string(from: last30Days!)
                   //self.endDate = formatter.string(from: date)
               case YEARLYTOPTRACKS:
                   self.startDate =  formatter.string(from: last365Days!)
                   //self.endDate = formatter.string(from: date)
                   
               default:
                   self.endDate = formatter.string(from: date)
               }
        
        print("\(chartingVariable) Top Charts Range: \(self.startDate) to \(self.endDate)")
        //  refreshControl.attributedTitle = NSAttributedString(string: "Loading Top Charts")
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        getTopChartKeys(start: self.startDate, end: self.endDate, chartingVariable: chartingVariable)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,  action: #selector(longPress))
        //  tableView.addGestureRecognizer(longPressRecognizer)
        
    }
    //Called, when long press occurred
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let touchPoint = longPressGestureRecognizer.location(in: tableView2)
            if let indexPath = tableView2.indexPathForRow(at: touchPoint) {
                guard let popupNavController = storyboard.instantiateViewController(withIdentifier: "TrackOptions") as? TrackOptionsViewController else { return }
                popupNavController.source = LIKEDTRACKS
                print("longpress index: \(indexPath.row)")
                popupNavController.index = indexPath.row
                popupNavController.track = User.cards[chartType]?[indexPath.row ]
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
        self.refreshControl.endRefreshing()
    }
    
    
    
    func getTopChartKeys(start: String, end: String, chartingVariable: String){ //format of YYYYMMDD
        print("getting \(start) - \(end)")
        refreshControl.beginRefreshing()
        
        let url = "https://us-central1-locartist-c2410.cloudfunctions.net/top\(chartingVariable)?startDate=\(start)&&endDate=\(end)"
        print("AlamoURL: \(url)")
        Alamofire.request(url)
            .responseJSON { response in
                
                switch response.result {
                case .success(let result):
                    // do what you need
                   
                    var i = 0
                    let swiftyJSONVar = JSON(result)
                    print("Top Chart \(chartingVariable) Count: \(swiftyJSONVar.count)")
                    while i < swiftyJSONVar.count {
                        let streamCount = swiftyJSONVar[i][1].intValue
                        let artistKey = swiftyJSONVar[i][0].stringValue
                        print("\(artistKey):\(streamCount)")
                        i = i + 1
                        
                        if artistKey != "None" && !self.artistKeys.contains(artistKey) {
                            self.artistKeys.append(artistKey)
                        }
                  
                        self.artistStreamDict[artistKey] = streamCount
                        
                    }
                    
                    if self.artistKeys.count != 0 {
                        
                        
                        self.getTopChartArtists(artistKeys: self.artistKeys)
                        
                        
                    }else{
                        print("Not enough top chart artists in date range")
                    }
                    
                    
                    
                case .failure(let error):
                    
                    
                    print("Error: \(error)")
                }
                
        }
    }
    
    
    
    
    
    
    
    func getTopChartArtists(artistKeys: [String]){
        topArtists.removeAll()
        print("getting top artist tracks")
        print("Artist Top Chart Keys count: \(artistKeys.count)")
        var count = 0
        
        
        for uid in artistKeys{
            
            if !loadedArtists.contains(uid){
                
                
                let db = Firestore.firestore()
                
                print("Attempting For Artist: \(uid)")
                
                db.collection("users").document(uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        
                        let data = document.data()
                        
                        let city = data?["city"] as? String ?? "None"
                        let state = data?["state"] as? String ?? "None"
                        let country = data?["country"] as? String ?? "None"
                        let profilePhoto = data?["photoUrl"] as? String ?? "None"
                        let username = data?["username"] as? String ?? ""
                        let bio = data?["bio"] as? String ?? ""
                        //let coverPhoto = data?["coverPhotoUrl"] as? String ?? "" NOT USED YET
                        var name = data?["name"] as? String ?? ""
                        let spotify = data?["spotify"] as? String ?? ""
                        let appleMusic = data?["applemusic"] as? String ?? ""
                        let soundcloud = data?["soundcloud"] as? String ?? ""
                        let twitter = data?["twitter"] as? String ?? ""
                        let instagram = data?["instagram"] as? String ?? ""
                        let spotifyClicks = data?["spotifyClicks"] as? Int ?? 0
                        let soundcloudClicks = data?["soundcloudClicks"] as? Int ?? 0
                        let applemusicClicks = data?["applemusicClicks"] as? Int ?? 0
                        let twitterClicks = data?["twitterClicks"] as? Int ?? 0
                        let instagramClicks = data?["instagramClicks"] as? Int ?? 0
                        let listenerPoints = data?["listenerPoints"] as? Int ?? 0
                        let profileImpressionCount = data?["profileImpressionCount"] as? Int ?? 0
                        //not sure if below will work
                        let followers = data?["followers"] as? [String]
                        let following = data?["following"] as? [String]
                        let likedTracks = data?["likedTracks"] as? [String]
                        let dislikedTracks = data?["dislikedTracks"] as? [String]
                        let library = data?["library"] as? [String]
                        let streamCount = self.artistStreamDict[uid]
                        
                       
                        let artist = Artist(uid: document.documentID, subscriptionId: "", username: username, name: name, bio: bio, profileImage: profilePhoto, totalStreams: streamCount ?? 0, totalListeners: 0, signUpDate: 0, trackKeys: [], tracks: [], followerKeys: [], followingKeys: [], verified: false,socials: [APPLEMUSIC: "",
                                                                                                                                                                                                                                                                                                                  SOUNDCLOUD: soundcloud,
                                                                                                                                                                                                                                                                                                                  SPOTIFY: spotify,
                                                                                                                                                                                                                                                                                                                  TWITTER: twitter,
                                                                                                                                                                                                                                                                                                                  INSTAGRAM: instagram,
                                                                                                                                                                                                                                                                                                                  LIMELIGHT: ""],
                                            
                                            location: [LATITUDE: 0.0,
                                                       LONGITUDE: 0.0,
                                                       CITY: city,
                                                       STATE: state,
                                                       COUNTRY: country], profileImpressions: profileImpressionCount)
                        
                        
                        //not sure if below will work
                        // User.followers = followers ?? [String]()
                        // User.following = following ?? [String]()
                        
                        if username != "" {
                            self.topArtists.append(artist)
                                                   self.loadedArtists.append(artist.uid)
                                                   print("Appended Artist: \(uid)")
                        }
                       
                        count = count + 1
                        
                        if count == self.artistKeys.count {
                            self.chartLoaded = true
                            let sortedByStreamCount = self.topArtists.sorted(by: { Int($0.totalStreams) > Int($1.totalStreams) })
                            self.topArtists = sortedByStreamCount
                           // self.tableView2.reloadData()
                            UIView.transition(with: self.tableView2,
                                                                duration: 0.35,
                                                                options: .transitionCrossDissolve,
                                                                animations: { self.tableView2.reloadData() })
                                                               
                                                            
                            
                            self.refreshControl.endRefreshing()
                            print("\(self.chartType) Top Charts Loaded")
                        }
                        
                        
                    }
                    
                    
                    let sortedByStreamCount = self.topArtists.sorted(by: { Int($0.totalStreams) > Int($1.totalStreams) })
                    self.topArtists = sortedByStreamCount
                    //self.cardSwiper.reloadData()
                    
                   // self.tableView2.reloadData()
                    UIView.transition(with: self.tableView2,
                                                                                   duration: 0.35,
                                                                                   options: .transitionCrossDissolve,
                                                                                   animations: { self.tableView2.reloadData() })
                                                                                  
                                                                               
                                               
                    
                     self.refreshControl.endRefreshing()
                }
            }
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}

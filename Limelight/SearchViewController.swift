//
//  SearchViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-02-02.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import SwiftAudio
import BottomPopup
import DZNEmptyDataSet
import Firebase
import SideMenu
import InstantSearchClient
import ChameleonFramework

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        if searchBar.text?.count ?? 0 > 0{
            searchCollection(forText: searchBar.text!)
        }else{
            User.cards[SEARCHEDTRACKS]?.removeAll()
            tableView.reloadData()
        }
        
        print("update")
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
        self.definesPresentationContext = true
        //  tableView.setContentOffset(CGPoint(x: 0,y: self.searchController.searchBar.frame.size.height), animated: false)
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    
    
    
    var resultSearchController = UISearchController()
    
    var db = Firestore.firestore()
    
    var controller = AudioController.shared
    
    lazy var refreshControl = UIRefreshControl()
    
    var objects = [Any]()
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return User.cards[SEARCHEDTRACKS]?.count ?? 0 // objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        if self.users.count > User.cards[SEARCHEDTRACKS]?.count ?? 0 {
            
        }
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        
        
        if self.objects.indices.contains(indexPath.row){
            if let object = self.objects[indexPath.row] as? LimelightUser {
               // obj is a String. Do something with str
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
                 //cell.textLabel?.text = User.likedTracks[indexPath.row].title
                 
                cell2.user = object
                return cell2
                
            } else if let object = self.objects[indexPath.row] as? Track {
                              // obj is not a String
                                let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
                                cell.track = object//User.cards[SEARCHEDTRACKS]?[indexPath.row]
                               if User.cards[SEARCHEDTRACKS]?.indices.contains(indexPath.row) ?? false{
                                          //cell.track = User.cards[SEARCHEDTRACKS]?[indexPath.row]
                                          cell.trackArtistLabel.tag = indexPath.row
                                          cell.trackArtistLabel.isUserInteractionEnabled = true
                                          let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
                                          cell.trackArtistLabel.addGestureRecognizer(gestureRecognizer)
                                          
                                      }
                               return cell
                               
                           }
            
            if User.cards[SEARCHEDTRACKS]?.indices.contains(indexPath.row) ?? false{
                       //cell.track = User.cards[SEARCHEDTRACKS]?[indexPath.row]
               
                      
                
                
                       
                   }
            
        }
        */
        
        
        
         
        // cell.followButton.addTarget(self, action: #selector(followButton(_:)), for: .touchUpInside)
         
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        
        if User.cards[SEARCHEDTRACKS]?.indices.contains(indexPath.row) ?? false{
            cell.track = User.cards[SEARCHEDTRACKS]?[indexPath.row]
            cell.trackArtistLabel.tag = indexPath.row
            cell.trackArtistLabel.isUserInteractionEnabled = true
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
            cell.trackArtistLabel.addGestureRecognizer(gestureRecognizer)
            
        }
        
        
        return cell
    }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if User.cards[SEARCHEDTRACKS]?.indices.contains(currentIndex ?? 0) ?? false{
            if let currentCard =  User.cards[SEARCHEDTRACKS]?[currentIndex ?? 0] {
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
        
        
        self.searchController.searchBar.endEditing(true)
        
        /*
        if self.objects.indices.contains(indexPath.row){
                   if let object = self.objects[indexPath.row] as? LimelightUser {
                      
                                           let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                           
                                           let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                                   vc.profileUserId = object.uid
                                   vc.username = object.username //change to reference
                                           
                                           // secondViewController.dataString = textField.text!
                                           // vc.
                                           self.navigationController?.pushViewController(vc, animated: true)
                                           //self.present(vc, animated: true, completion: nil)
                                           
                                       
            }
            
                       
                    else if let object = self.objects[indexPath.row] as? Track {
                                     // obj is not a String
                                       print("search track playing: \(object.title)")
                                              
                                              if controller.currentSource != SEARCHEDTRACKS {
                                                  controller.player.stop()
                                              }
                                              
                                              if controller.currentSource == SEARCHEDTRACKS && controller.currentlyPlaying!.trackId != object.trackId {
                                                  controller.player.stop()
                                                  controller.player.removeUpcomingItems()
                                                  
                                                  self.controller.addTracksToSource(trackArray: User.cards[SEARCHEDTRACKS] ?? [] , source: SEARCHEDTRACKS)
                                                  self.controller.loadTracks(source: SEARCHEDTRACKS)
                                                  self.controller.playTrack(index: indexPath.row, source: SEARCHEDTRACKS)
                                                  
                                                  
                                                  controller.profileUid = object.artistUid
                                              }else{
                                                  self.controller.playTrack(index: indexPath.row, source: SEARCHEDTRACKS)
                                              }
                                      
                                  }
        }
        

        
        
        */
        
      
       
        if controller.currentSource != SEARCHEDTRACKS {
            controller.player.stop()
        }
        
        if controller.currentSource == SEARCHEDTRACKS && controller.currentlyPlaying!.trackId != User.cards[SEARCHEDTRACKS]?[indexPath.row].trackId {
            controller.player.stop()
            controller.player.removeUpcomingItems()
            
            self.controller.addTracksToSource(trackArray: User.cards[SEARCHEDTRACKS] ?? [] , source: SEARCHEDTRACKS)
            self.controller.loadTracks(source: SEARCHEDTRACKS)
            self.controller.playTrack(index: indexPath.row, source: SEARCHEDTRACKS)
            
            print("search track playing: \(User.cards[SEARCHEDTRACKS]?[indexPath.row].title)")
                   
            controller.profileUid = (User.cards[SEARCHEDTRACKS]?[indexPath.row].artistUid)!
        }else{
            self.controller.playTrack(index: indexPath.row, source: SEARCHEDTRACKS)
        }
        
        //controller.playTrack(index: indexPath, source: <#T##String#>)
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    var client = Client(appID: "HAQZ3E0FG1", apiKey: "17733dd973dce5fe7ce0ea4c79429e98")
    var myObjects = [Track]()
    private var collectionIndex : Index!
    private var collectionIndex2 : Index!
    private let query = Query()
    var uids = [String]()
    var users = [LimelightUser]()
    
    private func setupAlgoliaSearch() {
        guard let bundle = Bundle.main.bundleIdentifier else { return }
        let searchClient = Client(appID: "HAQZ3E0FG1", apiKey: "17733dd973dce5fe7ce0ea4c79429e98")
        let indexName = bundle == "TRACK" ? "TRACK" : "TRACK"
        let indexName2 = bundle == "USER" ? "USER" : "USER"
        collectionIndex = searchClient.index(withName: indexName)
        collectionIndex2 = searchClient.index(withName: indexName2)
        query.hitsPerPage = 20
        
        // Limiting the attributes to be retrieved helps reduce response size and improve performance
        query.attributesToRetrieve = ["username", "title","objectID"]
        query.attributesToHighlight = ["username", "title","objectID",]
    }
    func searchCollection(forText searchString : String) {
        query.query = searchString
        self.filteredTracks.removeAll()
        User.trackKeys[SEARCHEDTRACKS]?.removeAll()
        
        collectionIndex.search(query) { (content, error) in
            guard let content = content else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            
            
            guard let hits = content["hits"] as? [[String: AnyObject]] else { return }
            
            self.objects.removeAll()
            User.trackKeys[SEARCHEDTRACKS]?.removeAll()
            hits.forEach({ (record) in
                // ... handle record JSON.
                
                print("record: \(record["username"])")
                let trackId = record["objectID"] as! String
                if !(User.trackKeys[SEARCHEDTRACKS]?.contains(trackId) ?? true){
                    User.trackKeys[SEARCHEDTRACKS]?.append(trackId)
                }
               
                //self.addHit(hit: record["objectID"] as! String)
            })
            print("record hitcount: \(hits.count)")
            print("record tablecount: \(self.filteredTracks.count)")
            
            System.getTracksByIdsForSource(source: SEARCHEDTRACKS, trackIds: User.trackKeys[SEARCHEDTRACKS] ?? []) { (tracks) in
                print("record searchedTracks count: \(tracks.count)")
                UIView.transition(with: self.tableView,
                duration: 0.1,
                options: .transitionCrossDissolve,
                animations: { self.tableView.reloadData() })
                print(tracks.count)
                FirebaseManager.getUserInfoForTracks(source: LIKEDTRACKS)
                /*
                for track in tracks {
                    self.objects.append(track)
                }*/
            }
            
            
        }
        /*
        collectionIndex2.search(query) { (content, error) in
            guard let content = content else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            
            
            guard let hits = content["hits"] as? [[String: AnyObject]] else { return }
            
            
            self.uids.removeAll()
            self.users.removeAll()
            hits.forEach({ (record) in
                // ... handle record JSON.
                
                print("user record: \(record["username"])")
                let uid = record["objectID"] as! String
                if !(self.uids.contains(uid)){
                    self.uids.append(uid)
                }
               
                //self.addHit(hit: record["objectID"] as! String)
            })
            print("user record hitcount: \(hits.count)")
         
            
            System.getUsersByUids(uids: self.uids) { (users) in
                print("uids record count: \(users.count)")
                
                self.users = users
                
                for user in users {
                    self.objects.append(user)
                }
                
                UIView.transition(with: self.tableView,
                duration: 0.1,
                options: .transitionCrossDissolve,
                animations: { self.tableView.reloadData() })
                
            }
            
            
        }*/
        
    }
    
    func setSearchBar2(){
        //  let searchController = UISearchController(searchResultsController: nil)
        //searchController.searchResultsUpdater = self.updateSearchResults(for: sl)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    
    func setNavBarLogo(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "smallLimelightLogo")
        imageView.image = image
        
        self.navigationItem.titleView = imageView
        
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        
    }
    var sideMenu = SideMenuNavigationController(rootViewController: SideMenuViewController())
    
    @IBAction func pushSide(sender: UIButton){
        pushSideMenu()
    }
    
    func setupSideMenu(){
        //  SideMenuPresentationStyle.menuStartAlpha = 1
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu")
        sideMenu = SideMenuNavigationController(rootViewController: newViewController)
        
        sideMenu.leftSide = true
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.menuWidth = 300
    }
    
    
    
    @objc func pushSideMenu(){
        present(sideMenu, animated: true, completion: nil)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Search Limelight"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Find artists, listeners, and music"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "bigAssSearchIcon")?.sd_resizedImage(with: CGSize(width: 60, height: 60), scaleMode: .aspectFit)
    }
    
    
    
    
    
    
    
    var safeArea: UILayoutGuide!
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        safeArea = view.layoutMarginsGuide
        setupTableView()
        
    }
    
    @objc func reloadTableView() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // self.controller.addTracksToSource(trackArray:  User.cards[LIBRARYTRACKS] ?? [] , source: LIBRARYTRACKS)
        // self.controller.loadTracks(source: LIBRARYTRACKS)
    }
    
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(TrackCell.self, forCellReuseIdentifier: "trackCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "userCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        setupSideMenu()
        setNavBarLogo()
        setSearchBar2()
        setupAlgoliaSearch()
        //setupSearchBar()
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        //self.refreshControl.endRefreshing()
        definesPresentationContext = true
        //getTrackKeys(uid: User.uid)
    
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
                popupNavController.source = SEARCHEDTRACKS
                popupNavController.index = indexPath.row
                popupNavController.track = User.cards[SEARCHEDTRACKS]?[indexPath.row ]
                
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
        //   User.trackKeys[libraryRef]?.removeAll()
        //  loadedTracks.removeAll()
        //    User.cards[libraryRef]?.removeAll()
        //  getTrackKeys(uid: User.uid)
        
        
    }
    
    
}


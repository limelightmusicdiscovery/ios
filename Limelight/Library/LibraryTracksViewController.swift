//
//  LibraryTracksViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-09.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftAudio
import BottomPopup
import DZNEmptyDataSet

class LibraryTracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
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
        self.definesPresentationContext = true
        //  tableView.setContentOffset(CGPoint(x: 0,y: self.searchController.searchBar.frame.size.height), animated: false)
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    func filterContentForSearchText(_ searchText: String
    ) {
        filteredTracks = (User.cards[LIBRARYTRACKS]?.filter { (track: Track) -> Bool in
            return track.title.lowercased().contains(searchText.lowercased())
            })!
        
        tableView.reloadData()
    }
    
    
    
    
    var resultSearchController = UISearchController()
    
    var db = Firestore.firestore()
    var libraryRef = LIBRARYTRACKS
    var trackKeysArray = User.trackKeys[LIBRARYTRACKS]
    var trackArray = User.cards[LIBRARYTRACKS]
    var controller = AudioController.shared
    var loadedTracks = [String]()
    lazy var refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        print("library did appear")
        self.tableView.reloadData()
        if User.cards[LIBRARYTRACKS]?.count != loadedTracks.count {
            // tableView.reloadData()
            loadedTracks = User.trackKeys[LIBRARYTRACKS] ?? []
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredTracks.count
        }
        
        return User.cards[LIBRARYTRACKS]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
        
        
        
        
        if User.cards[LIBRARYTRACKS]?.indices.contains(indexPath.row) ?? false{
            let track = User.cards[LIBRARYTRACKS]?[indexPath.row]
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
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if User.cards[LIBRARYTRACKS]?.indices.contains(currentIndex ?? 0) ?? false{
            if let currentCard =  User.cards[LIBRARYTRACKS]?[currentIndex ?? 0] {
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
        
        if controller.currentSource != LIBRARYTRACKS {
            controller.player.stop()
        }
        
        
        controller.playTrack(index: indexPath.row, source: LIBRARYTRACKS)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    var safeArea: UILayoutGuide!
    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
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

        // self.controller.addTracksToSource(trackArray:  User.cards[LIBRARYTRACKS] ?? [] , source: LIBRARYTRACKS)
        // self.controller.loadTracks(source: LIBRARYTRACKS)
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "No Library Tracks"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
           return NSAttributedString(string: str, attributes: attrs)
       }

       
       func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
           let str = "Tracks you add to your library will appear here"
           let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
           
           return NSAttributedString(string: str, attributes: attrs)
       }

       func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
           return UIImage(named: "library")?.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFill)
       }


       func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
           let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "Hurray", style: .default))
           present(ac, animated: true)
       }

    
    
    
    
    func setupTableView() {
        view.addSubview(tableView)
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
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
         //setupSearchBar()
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
         tableView.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
       
        //self.refreshControl.endRefreshing()
        //definesPresentationContext = true
        //getTrackKeys(uid: User.uid)
        
        System.getTrackIdsBySource(uid: User.uid, source:LIBRARYTRACKS) { (trackIds) in
            User.trackKeys[LIBRARYTRACKS] = trackIds
                   System.getTracksByIdsForSource(source: LIBRARYTRACKS, trackIds: trackIds) { (tracks) in
                       
                     //  User.cards[LIBRARYTRACKS] = tracks
                    UIView.transition(with: self.tableView,
                       duration: 0.35,
                       options: .transitionCrossDissolve,
                       animations: { self.tableView.reloadData() })
                    
                    print(tracks.count)
                     FirebaseManager.getUserInfoForTracks(source: LIBRARYTRACKS)
                   
                //   self.getLikedTracks(trackKeys: trackIds)
               }
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
                popupNavController.source = LIBRARYTRACKS
                popupNavController.index = indexPath.row
                popupNavController.track = User.cards[LIBRARYTRACKS]?[indexPath.row ]
                
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


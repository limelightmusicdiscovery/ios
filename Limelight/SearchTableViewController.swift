//
//  SearchTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-02-02.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import InstantSearchClient
import Firebase
import SwiftAudio
import SideMenu
import DZNEmptyDataSet

struct searchResult {

    var id : Int
    var title : String
    var text : String
    var image : String

}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
  
    var headlines = [
        searchResult(id: 1, title: "Lorem Ipsum", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", image: "Apple"),
       searchResult(id: 2, title: "Aenean condimentum", text: "Ut eget massa erat. Morbi mauris diam, vulputate at luctus non.", image: "Banana"),
        searchResult(id: 3, title: "In ac ante sapien", text: "Aliquam egestas ultricies dapibus. Nam molestie nunc.", image: "Cantaloupe"),
    ]
    
    var filteredTracks: [Track] = []
    
      var searchController = UISearchController(searchResultsController: nil)

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        if searchBar.text?.count ?? 0 > 0{
              searchCollection(forText: searchBar.text!)
        }else{
            filteredTracks.removeAll()
            tableView.reloadData()
        }
       
    print("update")
    }
    
    var client = Client(appID: "HAQZ3E0FG1", apiKey: "17733dd973dce5fe7ce0ea4c79429e98")
    var myObjects = [Track]()
    private var collectionIndex : Index!
    private let query = Query()
    
   
    private func setupAlgoliaSearch() {
        guard let bundle = Bundle.main.bundleIdentifier else { return }
        let searchClient = Client(appID: "HAQZ3E0FG1", apiKey: "17733dd973dce5fe7ce0ea4c79429e98")
        let indexName = bundle == "TRACK" ? "TRACK" : "TRACK"
        collectionIndex = searchClient.index(withName: indexName)
        query.hitsPerPage = 20
        
        // Limiting the attributes to be retrieved helps reduce response size and improve performance.
        query.attributesToRetrieve = ["objectID", "title", "username"]
        query.attributesToHighlight = ["objectID", "title", "username"]
    }
    func searchCollection(forText searchString : String) {
        query.query = searchString
         self.filteredTracks.removeAll()
       
        collectionIndex.search(query) { (content, error) in
            guard let content = content else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            guard let hits = content["hits"] as? [[String: AnyObject]] else { return }
            print("hitcount: \(hits.count)")
           
            
            hits.forEach({ (record) in
                // ... handle record JSON.
                
                let db = Firestore.firestore()
                              
                             
                db.collection("all-tracks").document(record["objectID"] as! String)
                                  
                                  .getDocument() { (document, err) in
                                      if err != nil {
                                          // Some error occured
                                         
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
                                        
                                        self.filteredTracks.append(track)
                                        self.tableView.reloadData()
                                    }
                }
            
               
                
                //self.tableView.reloadData()
                print("record: \(record["username"])")
            })
            //  self.filteredTracks = searchedTracks
           // self.tableView.reloadData()
        }
       // self.tableView.reloadData()
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



      

       override func viewDidLoad() {
           
          
        super.viewDidLoad()
         setupSideMenu()
        setNavBarLogo()
         
        print("search")
        tableView.register(TrackCell.self, forCellReuseIdentifier: "trackCell")
               tableView.delegate = self
               tableView.dataSource = self
        tableView.emptyDataSetSource = self
                      tableView.emptyDataSetDelegate = self
                      tableView.tableFooterView = UIView()
        setSearchBar2()
          setupAlgoliaSearch()
        
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredTracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        
        if filteredTracks.indices.contains(indexPath.row){
            cell.track = filteredTracks[indexPath.row]
            
        }
        
        
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

import UIKit
import FirebaseFirestore
import SwiftAudio
import Alamofire
import SwiftyJSON

class TopTracksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    var db = Firestore.firestore()
    var controller = AudioController.shared
    var trackKeys = [String]()
    lazy var refreshControl = UIRefreshControl()
    
    var tracksStreamDict = [String: Int]()
   
 
    var loadedTrackCount = 0
    var loadedTracks = [String]()
    var chartingVariable = TRACKS
    var chartType = WEEKLYTOPTRACKS
    var startDate = ""
    
  
    var formatter = DateFormatter()
    var endDate = ""
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        User.cards[chartType]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topChartCell", for: indexPath) as! TopChartCell
        //cell.textLabel?.text = User.likedTracks[indexPath.row].title
        cell.rank = indexPath.row
        cell.track = User.cards[chartType]?[indexPath.row]
        
             cell.trackArtistLabel.tag = indexPath.row
             cell.trackArtistLabel.isUserInteractionEnabled = true
             let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_:)))
             cell.trackArtistLabel.addGestureRecognizer(gestureRecognizer)
        
        return cell
        
    }
    
    @objc func showUserProfile(_ sender: UITapGestureRecognizer){
        let currentIndex = sender.view?.tag
        if User.cards[chartType]?.indices.contains(currentIndex ?? 0) ?? false{
            if let currentCard =  User.cards[chartType]?[currentIndex ?? 0] {
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
        
        if controller.currentSource != chartType {
            controller.player.stop()
        }
        
        
        controller.playTrack(index: indexPath.row, source: self.chartType)
        controller.preloadTrack(index: indexPath.row + 1, source: self.chartType)
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    let tableView = UITableView()
    
    
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
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(TopChartCell.self, forCellReuseIdentifier: "topChartCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        self.view.backgroundColor = .clear
         tableView.separatorColor = UIColor(red: 34/255, green: 17/255, blue: 52/255, alpha: 1)
        tableView.addSubview(refreshControl)
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
        print("Top Charts Range: \(self.startDate) to \(self.endDate)")
      //  refreshControl.attributedTitle = NSAttributedString(string: "Loading Top Charts")
        refreshControl.addTarget(self,  action: #selector(refresh), for: UIControl.Event.valueChanged)
      
        getTopChartKeys(start: self.startDate, end: self.endDate, chartingVariable: chartingVariable)
        
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
        
          refreshControl.beginRefreshing()
        
   Alamofire.request("https://us-central1-locartist-c2410.cloudfunctions.net/top\(chartingVariable)?startDate=\(start)&&endDate=\(end)")
             .responseJSON { response in
                 
                 switch response.result {
                     case .success(let result):
                     // do what you need
                     
                         var i = 0
                         let swiftyJSONVar = JSON(result)
                         print("Top Chart Count: \(swiftyJSONVar.count)")
                         while i < swiftyJSONVar.count {
                            let streamCount = swiftyJSONVar[i][1].intValue
                            let trackKey = swiftyJSONVar[i][0].stringValue
                            print("\(trackKey):\(streamCount)")
                            i = i + 1
                            
                            if !self.trackKeys.contains(trackKey){
                                 self.trackKeys.append(trackKey)
                            }
                           
                            
                         
                            self.tracksStreamDict[trackKey] = streamCount
                    
                    }
                    
                         if self.trackKeys.count != 0 {
                            self.getTopChartTracks(trackKeys: self.trackKeys)
                         }else{
                            print("Not enough top chart tracks in date range")
                    }
                  
                    
                    
                    
                    
                    
                         
                         //print(swiftyJSONVar)//  response.result.value!)
                         
                        // let streamCount = swiftyJSONVar[0][1].stringValue
                        
                     
                     case .failure(let error):
                
                        
                      print("Error: \(error)")
                     }
                
        }
    }
                 
                 
        
    
    
  
        
    
    
    func getTopChartTracks(trackKeys: [String]){
        User.cards[self.chartType]?.removeAll()
        print("getting top chart tracks")
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
                        let streamCount = self.tracksStreamDict[trackId]//data?["streamCount"] as? Int ?? 0
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
                                                                                                                                                                                                                          LIMELIGHT: 0], radius: trackRadius, streamCount: streamCount ?? 0, uploadDate: unixDate, likeCount: totalLikes, dislikeCount: totalDislikes, commentCount: commentCount, title: trackName, trackUrl: trackURL, trackId: Id ?? "None", latitude: trackLatitude, longitude: trackLongitude, city: city, state: state, country: country, trackSource: self.chartType,audioItem: audioItem, avgCoverColor: UIColor.black, comments: [Comment](), likePercentage: likePercentage, fcmToken: "")
                          count = count + 1
                        if track.trackUrl != "None" {
                            User.cards[self.chartType]?.append(track)
                          
                            self.loadedTracks.append(trackId)
                            if count == trackKeys.count {
                                
                                self.controller.addTracksToSource(trackArray:  User.cards[self.chartType] ?? [] , source: self.chartType)
                             //   self.controller.loadTracks(source: LIKEDTRACKS)
                                let sortedByStreamCount = User.cards[self.chartType]?.sorted(by: { Int($0.streamCount) > Int($1.streamCount) })
                                User.cards[self.chartType] = sortedByStreamCount
                                self.loadedTrackCount = trackKeys.count
                                //self.tableView.reloadData()
                                UIView.transition(with: self.tableView,
                                                                                                                    duration: 0.35,
                                                                                                                    options: .transitionCrossDissolve,
                                                                                                                    animations: { self.tableView.reloadData() })
                                
                                print("Top Charts Loaded")
                                self.chartLoaded = true
                                self.refreshControl.endRefreshing()
                                //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                            }
                            
                            
                            
                            
                            
                            //self.controller.player.play()
                            
                        }
                        
                        
                        print("Top Track Done For: \(trackId)")
                        //self.cardSwiper.reloadData()
                        
                        //self.tableView.reloadData()
                        
                        
                    }
            }
            
            
            }
        }
        
        
        
        
    }
 
 
}

//
//  TrackOptionsTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-13.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import SDWebImage
import MarqueeLabel

class TrackOptionsTableViewController: UITableViewController{
   
    let controller = AudioController.shared
    
    
    var track: Track?
     @IBOutlet weak var trackName: UILabel!
    var delegate: trackOptionsControl?
      
       @IBOutlet weak var trackLocation: MarqueeLabel!
     @IBOutlet weak var trackOutreach: UILabel!
     
    @IBOutlet weak var trackCover: UIImageView!
     @IBOutlet weak var trackStreams: UILabel!
       @IBOutlet weak var trackUsername: UILabel!
    var trackImage: UIImage?
    
     @IBOutlet weak var trackCommentsLabel: UIButton!
      @IBOutlet weak var trackLibrary: UIButton!
    @IBOutlet weak var trackLibraryIcon: UIImageView!
    override func viewDidAppear(_ animated: Bool) {
        print("track options did appear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(track?.title ?? "N/A")
        if track?.commentCount == 1 {
             trackCommentsLabel.setTitle("View \(track?.commentCount ?? 0) Comment", for: .normal)
        }else{
              trackCommentsLabel.setTitle("View \(track?.commentCount ?? 0) Comments", for: .normal)
        }
        print("track options library count \( User.trackKeys[LIBRARYTRACKS]?.count)")
        if User.trackKeys[LIBRARYTRACKS]?.contains(track?.trackId ?? "") ?? false {
            trackLibrary.setTitle("Remove from Library", for: .normal)
            trackLibraryIcon.image = UIImage(named: "recycle-bin")
        }else {
            trackLibrary.setTitle("Add to Library", for: .normal)
            trackLibraryIcon.image = UIImage(named: "library")
        }
      
        trackName.text = track?.title
        trackLocation.text = "\(track?.city ?? "N/A"), \(track?.state ?? "N/A")"
        trackUsername.text = track?.artistUsername
        trackStreams.text = "\(track?.streamCount ?? 0) STREAMS"
        trackCover.layer.cornerRadius = 2
        
               let shadowColor = UIColor.darkGray
             trackCover.layer.borderWidth = 1
               trackCover.layer.borderColor = shadowColor.cgColor
                   
        trackCover.sd_setImage(with: URL(string: (track?.imageUrl) ?? DEFAULTCOVERURL), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
            
            self.trackImage = image
           
            
        })
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
      @IBAction func showTrackComments(_ sender: UIButton) {
           
      //  self.dismiss(animated: true, completion: nil)
         
              
                   let storyboard = UIStoryboard(name: "Main", bundle: nil)
                   
                   let vc = storyboard.instantiateViewController(withIdentifier: "trackComments") as! TrackCommentsViewController
        vc.trackId = track?.trackId ?? ""
        vc.trackTitle = track?.title ?? ""
        vc.trackArtist = track?.artistUsername ?? ""
        vc.track = track
                   //vc.delegate = self
                   // secondViewController.dataString = textField.text!
                   self.present(vc, animated: true, completion: nil)
                   
               
               
           
           
       }
    
    @IBAction func shareButtonClicked(sender: AnyObject)
    {
        //Set the default sharing message.
        let message = "\(track?.title ?? "") by \(track?.artistUsername ?? "")"
        //Set the link to share.
        if let link = NSURL(string: "http://bit.ly/limelightapp")
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func playNextClicked(sender: AnyObject) {
      
        self.controller.player.preload(item: track!.audioItem!)
        try? self.controller.player.add(items: [track!.audioItem!], at: self.controller.player.currentIndex + 1)
       
        
       let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        self.dismiss(animated: true) {
            System.showMessage(title: self.track?.title ?? "Track", body: "Added to Play Next", duration: 1.5, type: .success, image: self.trackImage)
              }
       
    }
    @IBAction func playLaterClicked(sender: AnyObject) {
        try? self.controller.player.add(items: [track!.audioItem!], at: controller.player.items.count)
                
               let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
        
         self.dismiss(animated: true) {
            System.showMessage(title: self.track?.title ?? "Track", body: "Added to Play Later", duration: 1.5, type: .success, image: self.trackImage)
        }
              
       }
    @IBAction func likeTrackClicked(sender: AnyObject) {
        
        if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false) {
            self.controller.addTrackToUserCollectionCompletion(trackId: track!.trackId, source: LIKEDTRACKS, track: track) { (action) in
                if action == "added" {
                   
                }
            }
        } else{
            self.controller.addTrackToUserCollectionCompletion(trackId: track!.trackId, source: DISLIKEDTRACKS, track: track) { (action) in
                if action == "removed" {
                    self.controller.addTrackToUserCollection(trackId: self.track!.trackId, source: LIKEDTRACKS, track: self.track)
                  
                }
            }
        }
             let generator = UINotificationFeedbackGenerator()
                      generator.notificationOccurred(.success)
        
              
               self.dismiss(animated: true) {
                  System.showMessage(title: self.track?.title ?? "Track", body: "Added to Liked Tracks", duration: 1.5, type: .success, image: self.trackImage)
              }
       }
    @IBAction func dislikeTrackClicked(sender: AnyObject) {
          if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false) {
                     self.controller.addTrackToUserCollectionCompletion(trackId: track!.trackId, source: LIKEDTRACKS, track: track) { (action) in
                         if action == "added" {
                           
                         }
                     }
                 } else{
                     self.controller.addTrackToUserCollectionCompletion(trackId: track!.trackId, source: LIKEDTRACKS, track: track) { (action) in
                         if action == "removed" {
                            self.controller.addTrackToUserCollection(trackId: self.track!.trackId, source: DISLIKEDTRACKS, track: self.track)
                             
                         }
                     }
                 }
        
         self.dismiss(animated: true) {
             System.showMessage(title: self.track?.title ?? "Track", body: "Added to Disiked Tracks", duration: 1.5, type: .error, image: self.trackImage)
        }
         
       }
    @IBAction func appleMusicClicked(sender: AnyObject) {
          let currentCard = track!
                    let link = currentCard.socials[APPLEMUSIC] ?? ""
                                     print(link)
                                     print(link.count)
                                     guard let url = URL(string: currentCard.socials[APPLEMUSIC] ?? "") else {  let generator = UINotificationFeedbackGenerator()
                                                            generator.notificationOccurred(.error)
                                         return }
                                    
                                                           
                                     
                                     if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                                         let generator = UINotificationFeedbackGenerator()
                                         generator.notificationOccurred(.success)
                                         UIApplication.shared.open(url)
                                     }else{
                                         let generator = UINotificationFeedbackGenerator()
                                         generator.notificationOccurred(.error)
                                     }
       }
    @IBAction func spotifyClicked(sender: AnyObject) {
          let currentCard = track!
                    let link = currentCard.socials[SPOTIFY] ?? ""
                                     print(link)
                                     print(link.count)
                                     guard let url = URL(string: currentCard.socials[SPOTIFY] ?? "") else {  let generator = UINotificationFeedbackGenerator()
                                                            generator.notificationOccurred(.error)
                                         return }
                                    
                                                           
                                     
                                     if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                                         let generator = UINotificationFeedbackGenerator()
                                         generator.notificationOccurred(.success)
                                         UIApplication.shared.open(url)
                                     }else{
                                         let generator = UINotificationFeedbackGenerator()
                                         generator.notificationOccurred(.error)
                                     }
       }
    @IBAction func soundcloudClicked(sender: AnyObject) {
        let currentCard = track!
           let link = currentCard.socials[SOUNDCLOUD] ?? ""
                            print(link)
                            print(link.count)
                            guard let url = URL(string: currentCard.socials[SOUNDCLOUD] ?? "") else {  let generator = UINotificationFeedbackGenerator()
                                                   generator.notificationOccurred(.error)
                                return }
                           
                                                  
                            
                            if  link != "" &&  link != "None" && link != "null" && link.count != 0{
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                UIApplication.shared.open(url)
                            }else{
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.error)
                            }
       }
    
    
   
    @IBAction func libraryButtonClicked(sender: AnyObject)
       {
        
       
       let generator = UINotificationFeedbackGenerator()
       generator.notificationOccurred(.success)
        
         controller.addTrackToUserCollection(trackId: track?.trackId ?? "", source: LIBRARYTRACKS, track: track)
        if trackLibrary.titleLabel?.text == "Add to Library"{
            trackLibrary.setTitle("Remove from Library", for: .normal)
             trackLibraryIcon.image = UIImage(named: "recycle-bin")
            self.dismiss(animated: true) {
                             System.showMessage(title: self.track?.title ?? "Track", body: "Added to Library", duration: 1.5, type: .success, image: self.trackImage)
                               }
             //User.cards[LIBRARYTRACKS]?.append(track!)
        }else{
            trackLibrary.setTitle("Add to Library", for: .normal)
             trackLibraryIcon.image = UIImage(named: "library")
            self.dismiss(animated: true) {
                             System.showMessage(title: self.track?.title ?? "Track", body: "Removed from Library", duration: 1.5, type: .error, image: self.trackImage)
                               }
        }
        
        
             
              
             
       
       // self.delegate?.closeTrackOptions()
       }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 1 //Now section 0's header is hidden regardless of the new behaviour in iOS11.
        }

        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            return 88
        }
        if  indexPath.section == 2 && indexPath.row == 2{
            if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false) {
                return 39
            }else if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && (User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false)  {
                return 39
                
            }else if (User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false)  {
                return 1
            }else {
                return 1
            }
        }
        if  indexPath.section == 2 &&  indexPath.row == 3 {
            if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false) {
                return 39
            }else if (User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && !(User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false)  {
                return 39
                
            }else if !(User.trackKeys[LIKEDTRACKS]?.contains(track!.trackId) ?? false) && (User.trackKeys[DISLIKEDTRACKS]?.contains(track!.trackId) ?? false)  {
                return 1
            }else {
                return 1
            }
        }
        
        if indexPath.section == 3 && indexPath.row == 1 {
            let card = track!
            if card.socials[APPLEMUSIC] == "null" || card.socials[APPLEMUSIC] == "None" || card.socials[APPLEMUSIC]?.count == 0{
                              return 1
                           }else {
                              return 39
            }
            
            
         
                           
                          
                           
        }
        
        if indexPath.section == 3 && indexPath.row == 2 {
             let card = track!
            if card.socials[SPOTIFY] == "null" || card.socials[SPOTIFY] == "None" || card.socials[SPOTIFY]?.count == 0{
                                         return 1
                                                                  }else {
                                                                     return 39
                                    }
        }
        
        if indexPath.section == 3 && indexPath.row == 3 {
             let card = track!
            if card.socials[SOUNDCLOUD] == "null" || card.socials[SOUNDCLOUD] == "None" || card.socials[SOUNDCLOUD]?.count == 0{
                                                  return 1
                                                                                   }else {
                                                                                      return 39
                                                     }
        }
        
        return 39
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
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

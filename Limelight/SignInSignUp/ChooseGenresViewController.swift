//
//  ChooseGenresViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-28.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import GeoFire
import FirebaseFirestore


class ChooseGenresViewController: UIViewController {
    
     @IBOutlet weak var button: UIButton!
     @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
     var selectedGenres = [String]()
    
    func pushIsArtistViewController(){
              let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
              let newViewController = storyBoard.instantiateViewController(withIdentifier: "IsArtist")// as! ChooseGenresViewController
              navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    @IBAction func addGenre(sender: UIButton) {
        
        sender.backgroundColor = .blue
        if let genre = sender.currentTitle {
             
            if selectedGenres.contains(genre){
              
               
                if let genreIndex = selectedGenres.firstIndex(of: genre) {
                    print("contains at \(genreIndex)")
                    selectedGenres.remove(at: genreIndex)
                    sender.backgroundColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 0)
                    
                }
                 
            }else{
                selectedGenres.append(genre)
                 sender.backgroundColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
            }
        }
        
        //selectedGenres.append(sender.currentTitle ?? "")
       // sender.backgroundColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        
    }
    
    var users = [GeoFireUser]()
    
    func getFirestoreUsers(){
              
              
              _ = 0
             
            
             
              self.users.removeAll()
             
             
            
              
            //  UserInfo.currentIndex = 0
              
              let db = Firestore.firestore()
              
        db.collection("users").whereField("alias", isGreaterThan: "" ).getDocuments() { (querySnapshot, err) in
                  
                  
                
             
                  if let err = err {
                      print("Error getting documents: \(err)")
                  } else {
                      for document in querySnapshot!.documents {
                        
                
                                 
                        
                        let data = document.data()
                        
                            
                          
                            let username = data["username"] as? String ?? "None"
                            let alias = data["alias"] as? String ?? "None"
                          
                            let latitude = data["latitude"] as? String ?? "0.0"
                            
                           let longitude = data["longitude"] as? String ?? "0.0"
                        let uid = document.documentID
                        
                          
                         
                              
                        
                              
                         
                              
                              if latitude != "" && latitude != "" && !Double(latitude)!.isNaN && !Double(longitude)!.isNaN{
                                 _ = CLLocation(latitude: Double(latitude)! , longitude: Double(longitude)! )
                             
                                 
                                  
                                let user = GeoFireUser(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0, uid: uid, name: username, alias: alias)
                                 self.users.append(user)
                                 
                                 
                                  
                                  
                              }else{
                                    
                                  
                              }
                             
                          
                         
         
                         // UserInfo.sources.append(audioItem)
                          
                          
                          
                        //  self.cards.append(card)
                         
                        
                          }
                          
                        
                         
                 
                          
                      }
                  print("done getting firestore users")
                 print("User Count: \(self.users.count)")
            self.addNameFieldByAlias()
        }
    }
    
    
    var tracks = [String]()
    
    func getAllTrackIds(){
        let db = Firestore.firestore()
                  
            db.collection("all-tracks").getDocuments() { (querySnapshot, err) in
                      
                      
                    
                 
                      if let err = err {
                          print("Error getting documents: \(err)")
                      } else {
                          for document in querySnapshot!.documents {
                           
                            
                            self.tracks.append(document.documentID)
                        }
                        
                        print("done getting firestore tracks")
                        print("Track Count: \(self.tracks.count)")
                        self.initRequiredTrackFields()
                }
        }
    }
    func addNameFieldByAlias(){
        for user in users{
                 let userId = user.uid ?? "jAyWuKwPECcmDvejHsKZ"
                 
                 if userId != "jAyWuKwPECcmDvejHsKZ"{
                     let db = Firestore.firestore()
                     
                     print("Attmpting For: \(user.name)")
                    db.collection("users").document(userId).setData(["migrated": 0, "name": user.alias ], merge: true)
                    print("Done For: \(user.name)")
            
                    
            }
      
        }
                    
                    
            
            }
    
    func initRequiredTrackFields(){
         let db = Firestore.firestore()
          for track in tracks{
              
                    print("Attmpting For: \(track)")
                      db.collection("all-tracks").document(track).setData(["active": true,
                             "outreach": 1000,
                             "yesterdayTrackData": ["likedTracksAddCount": 0,
                                                   "dislikedTracksAddCount":0,
                                                   "libraryTracksAddCount": 0]], merge: true)
                      print("Done For: \(track)")
              
                      
              
        
          }
        print("done init tracks")

        
       
    }
        
    
                 
                  

         
    
    //remove field that was causing everything to be slow
    func addGeohashToRealTimeDb(){
        
        for user in users{
            let userId = user.uid ?? "jAyWuKwPECcmDvejHsKZ"
            
            if userId != "jAyWuKwPECcmDvejHsKZ"{
                let db = Firestore.firestore()
                
                print("Attmpting For: \(user.name)")
                db.collection("users").document(userId)
                    
                    .getDocument() { (document, err) in
                        if err != nil {
                            // Some error occured
                            print("Error For: \(user.name)")
                        } else {
                            
                            
                            let geofireRef = Database.database().reference().child("GeofireUsers")
                            let geoFire = GeoFire(firebaseRef: geofireRef)
                            
                            geoFire.setLocation(CLLocation(latitude: user.latitude, longitude: user.longitude), forKey: userId) { (error) in
                                if (error != nil) {
                                    print("An error occured: \(error)")
                                } else {
                                    print("Saved location successfully!")
                                }
                            }
                            
                            
                            
                            
                            print("Done For: \(user.name)")
                            
                        }
                }
            }
            
            
        }
    }
        
        
   
    
    func addGenresToDb(uid: String) {
        
        let db = Firestore.firestore()
        
        let dbRef = db.collection("users").document(uid)

        // Set the "capital" field of the city 'DC'
        dbRef.updateData([
            "favoriteGenres": selectedGenres
        ]) { err in
            if let err = err {
                print("Error updating genres: \(err)")
                 self.loadingIndicator.stopAnimating()
            } else {
                print("User generes successfully updated")
                 self.loadingIndicator.stopAnimating()
                self.pushIsArtistViewController()
            }
        }

    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                      self.navigationController?.navigationBar.shadowImage = UIImage()
                      self.navigationController?.navigationBar.isTranslucent = true
                      self.navigationController?.view.backgroundColor = .clear
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        // Do any additional setup after loading the view.
       // getFirestoreUsers()
        //getAllTrackIds()
       
    
    
    }
    
    @IBAction func nextButtonClicked() {
       self.loadingIndicator.startAnimating()
        print("uid: \(User.uid)")
        addGenresToDb(uid: User.uid)
      // addGeohashToRealTimeDb()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  UploadTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-09.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import FirebaseStorage
import MobileCoreServices
import SwiftMessages
import FirebaseFirestore
import Firebase
import Purchases


class UploadTableViewController: UITableViewController, UIDocumentPickerDelegate{
   
    
      var delegate: ProgressDelegate?
       var fileURL = ""
       var fileName = ""
       var db = Firestore.firestore()
       let controller = AudioController.shared
       @IBOutlet weak var chooseFileButton: UIButton!
     @IBOutlet weak var chooseFileLabel: UILabel!
       @IBOutlet weak var coverArtImageView: UIImageView!
       @IBOutlet weak var titleTextfield: UITextField!
       @IBOutlet weak var locationLabel: UILabel!
       @IBOutlet weak var startingOutreachLabel: UILabel!
      // @IBOutlet weak var radiusPlanLabel: UILabel!
       @IBOutlet weak var tracksAvailableLabel: UILabel!
       @IBOutlet weak var spotifyTextfield: UITextField!
       @IBOutlet weak var itunesTextfield: UITextField!
       @IBOutlet weak var soundcloudTextfield: UITextField!
        @IBOutlet weak var uploadStatus: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
        @IBAction func nextPressed(_ sender: UIButton){
            if Subscription.tracksAvailable > User.trackKeys[UPLOADEDTRACKS]?.count ?? 2  {
                self.uploadStatus.text = "(1/2) Uploading Track Audio"
                           self.uploadButton.isEnabled = false
                       uploadTrack()
            }else {
                 self.uploadStatus.text = "Please upgrade your plan for more uploads"
                 self.showArtistPayWall()
            }
            
            
        }
    
    override func viewDidAppear(_ animated: Bool) {
         if Subscription.tracksAvailable > User.trackKeys[UPLOADEDTRACKS]?.count ?? 2  {
                       self.uploadStatus.text = ""
                       self.uploadButton.isEnabled = true
                              
                   }else {
                        self.uploadStatus.text = "Please upgrade your plan for more uploads"
                        self.showArtistPayWall()
                   }
    }
       
        var imagePicker: UIImagePickerController!
       
       @objc func openImagePicker(_ sender:Any) {
           // Open Image Picker
           self.present(imagePicker, animated: true, completion: nil)
       }
    
    func showArtistPayWall(){
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            
            // Route the view depending if we have a premium cat user or not
            if false{//purchaserInfo?.entitlements["pro"]?.isActive == true || purchaserInfo?.entitlements["plus"]?.isActive == true {
                
                // if we have a pro_cat subscriber, send them to the cat screen
                //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //  let controller = storyboard.instantiateViewController(withIdentifier: "cats")
                //   controller.modalPresentationStyle = .fullScreen
                //     self.present(controller, animated: true, completion: nil)
                print("subscription active")
                
            } else {
                // if we don't have a pro subscriber, send them to the upsell screen
                let controller = SwiftPaywall(
                    termsOfServiceUrlString: "http://limelight.io",
                    privacyPolicyUrlString: "https://limelight.io")
                
                controller.titleLabel.text = "Limelight for Artists"
                controller.subtitleLabel.text = "Higher radius, unlimited uploads, personal artist insights and more!"
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    
    
@IBOutlet weak var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Subscription.tracksAvailable == 9999 {
              self.uploadStatus.text = "Limelight Artist PRO"
        }else {
            self.uploadStatus.text =  "\(Subscription.tracksAvailable - (User.trackKeys[UPLOADEDTRACKS]?.count ?? 2)) Uploads Remaining"
        }
        
        
       
        print("Tracks Available: \(Subscription.tracksAvailable)")
        print("Uploaded Tracks: \(User.trackKeys[UPLOADEDTRACKS]?.count)")
        self.view.backgroundColor = .clear//UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:
        
               let gradientImage = UIImage.gradientImage(with: progressBar.frame,
                                                                colors: LIMELIGHTGRADIENTCG,
                      locations: nil)
                      progressBar.progressImage = gradientImage!
               
        //self.view.frame, andColors: BACKGROUNDGRADIENT)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
              coverArtImageView.isUserInteractionEnabled = true
              coverArtImageView.addGestureRecognizer(imageTap)
        locationLabel.text = "\(User.location[CITY] ?? ""), \(User.location[STATE] ?? "")"
            setNavBarLogo()
        
        if Subscription.planType == PRO {
            userOutreach = PROOUTREACH
            startingOutreachLabel.text = "\(PROOUTREACH)"
            Subscription.startingRadius = PROSTARTRADIUS
        }else if Subscription.planType == PLUS {
            userOutreach = PLUSOUTREACH
                   startingOutreachLabel.text = "\(PLUSOUTREACH)"
             Subscription.startingRadius = PLUSSTARTRADIUS
        }else {
            userOutreach = BASICOUTREACH
            startingOutreachLabel.text = "\(BASICOUTREACH)"
             Subscription.startingRadius = BASICSTARTRADIUS
        }
          
              imagePicker = UIImagePickerController()
              imagePicker.allowsEditing = true
              imagePicker.sourceType = .photoLibrary
              imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
  self.hideKeyboardWhenTappedAround()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func showDiscoverCard() {
        let view: DiscoverCardPopUp = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.getTacosAction = { _ in SwiftMessages.hide() }
        
        view.cancelAction = { SwiftMessages.hide() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: true)
        
        SwiftMessages.show(config: config, view: view)
    }
    var userOutreach = 1000

    lazy var uploadController = ContainerUploadViewController.shared
    func uploadTrack(){
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // File located on disk
        let localFile = URL(string: fileURL)!
         let trackDocRef = self.db.collection("all-tracks").document()
        // Create a reference to the file you want to upload
        let trackRef = storageRef.child("all-tracks/\(User.uid)/\(trackDocRef.documentID)/audio/\(fileName)")
        
        // Upload the file to the path "images/rivers.jpg"
          let uploadTask = trackRef.putFile(from: localFile, metadata: nil) { metadata, error in
         
          // Metadata contains file metadata such as size, content-type.
            let size = metadata?.size
          // You can also access to download URL after upload.
           
          
          trackRef.downloadURL { (url, error) in
            
            guard let downloadUrl = url else {
                return
            }
           
            self.setDocument(url: downloadUrl, trackDocRef: trackDocRef, outreach: self.userOutreach)
                         
                         
          }
        }
            let observer = uploadTask.observe(.progress) { snapshot in
              print("Upload status: \(Float(snapshot.progress?.fractionCompleted ?? 0.0))" )
                
               
                if (Float(snapshot.progress?.fractionCompleted ?? 0.0)) == 1.0 {
                    self.uploadStatus.text = " (2/2) Uploading Cover Art"
                    guard let image = self.coverArtImageView.image else { return }
                        
                    //self.uploadCoverImage(image, trackId: trackDocRef.documentID)
                }
                
                self.progressBar.setProgress(Float(snapshot.progress?.fractionCompleted ?? 0.0), animated: true)
                
            }
        
      
    }
    
    func uploadCoverImage(_ image:UIImage, trackId: String) {
        
        
        //NVActivityIndicatorPresenter.sharedInstance.setMessage("Uploading Profile Picture")
        
        
        let storageRef = Storage.storage().reference().child("all-tracks/\(User.uid)/\(trackId)/image/\(fileName)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else{
            return
        }//UIImageJPEGRepresentation(image, 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Upload the file to the path "images/rivers.jpg"
       
        let uploadTask2 = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            // Metadata contains file metadata such as size, content-type.
            let size = metadata?.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                print("Download URL: \(downloadURL)")
                
           
                
                let trackRef = self.db.collection("all-tracks").document(trackId)
                
                // Set the "capital" field of the city 'DC'
                trackRef.setData([
                    "imgUrl":downloadURL.absoluteString
                ], merge: true)
            }
            
        }
        let observer2 = uploadTask2.observe(.progress) { snapshot in
                   
                     // print(snapshot.progress?.estimatedTimeRemaining)
                     
                   //   print("Upload 2 status: \(Float(snapshot.progress?.fractionCompleted ?? 0.0))" )
            
          
                  
         
                  //self.delegate?.updateProgressBar(elapsed: Float(snapshot.progress?.fractionCompleted ?? 0.0))
                self.progressBar.setProgress(Float(snapshot.progress?.fractionCompleted ?? 0.0), animated: true)
            
          if Float(snapshot.progress?.fractionCompleted ?? 0.0) == 1.0 {
              self.uploadStatus.text = "Track uploaded successfully"
            self.showMessage(title: "Track Uploaded Successfully" , body: "\(self.titleTextfield.text ?? "Track") is ready to be discovered", duration: 3.0, type: .success)
            
          
            
         Analytics.logEvent(TRACKUPLOADEVENT, parameters: [
            "username": User.username,
            "planType": Subscription.planType,
            "location":  "\(User.location[CITY] ?? "N/A"), \(User.location[STATE] ?? "N/A"), \(User.location[COUNTRY] ?? "N/A")",
            "outreach50km": User.outreachIn50km
            ])
            
            
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .didReceiveData, object: nil)
            }
          }
                     
                 }
        
        
    }
    var successConfig = SwiftMessages.defaultConfig
    
    
       func showMessage(title: String, body: String, duration: Double, type: Theme){
           
           let message = MessageView.viewFromNib(layout: .tabView)
                              message.configureTheme(type)
                              message.configureDropShadow()
                            
                                   
                              self.successConfig.duration = .seconds(seconds: duration)
                              

                             
                              message.configureContent(title: title, body: body)
                              //error.button?.setTitle("Stop", for: .normal)
                              message.button?.isHidden = true
          self.successConfig.duration = .seconds(seconds: 3)
                               
                              SwiftMessages.show(config: self.successConfig, view: message)
         
       }
       
    
    func setDocument(url: URL, trackDocRef: DocumentReference, outreach: Int){
        let date = Int(NSDate().timeIntervalSince1970) * 1000
               
        let title = self.titleTextfield.text ?? "None"
        let spotify = self.spotifyTextfield.text ?? "None"
        let itunes =  self.itunesTextfield.text ?? "None"
        let soundcloud = self.soundcloudTextfield.text ?? "None"
                                // Set the "capital" field of the city 'DC'
        
        
                                trackDocRef.setData([
                                  "city": User.location[CITY],
                                                       "state": User.location[STATE],
                                                       "country":  User.location[COUNTRY],
                                                       "latitude":  User.location[LATITUDE] ?? 0.0,
                                                       "longitude":  User.location[LONGITUDE] ?? 0.0,
                                                       "title": title,
                                                       "genre": "Hip-Hop",
                                                       "imgUrl": "",
                                                       "streamCount": 0,
                                                       "radius": Subscription.startingRadius,
                                                       "uid": User.uid,
                                                       "username": User.username,
                                                       "trackUrl": url.absoluteString,
                                                       "time": date,
                                                       "dateUploaded": date,
                                                       "spotifyLink": spotify ,
                                                       "itunesLink": itunes ,
                                                       "soundcloudLink": soundcloud,
                                                       "active": true,
                                                       "outreach": outreach,
                                                       "yesterdayTrackData": ["likedTracksAddCount": 0,
                                                                             "dislikedTracksAddCount":0,
                                                                             "libraryTracksAddCount": 0]
                                                       
                                ])
        
        guard let image = self.coverArtImageView.image else { return }
              
        uploadCoverImage(image, trackId: trackDocRef.documentID)
        
        User.trackKeys[UPLOADEDTRACKS]?.append(trackDocRef.documentID)
        controller.addTrackToUserCollectionCompletion(trackId: trackDocRef.documentID, source: UPLOADEDTRACKS, track: nil) { (action) in
            
            print(action)
            FirebaseManager.setTrackGeohash(uid: User.uid, trackId: trackDocRef.documentID)
        }
        
        
    }
    
    @IBAction func openDocumentBrowser(_ sender: UIButton) {
           let documentPickerController = UIDocumentPickerViewController(documentTypes: [ String(kUTTypeMP3), String(kUTTypeWaveformAudio), String(kUTTypeAudio)], in: .import)
           documentPickerController.delegate = self
           present(documentPickerController, animated: true, completion: nil)
           
       }
    
      func setNavBarLogo(){
                 self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                 self.navigationController?.navigationBar.shadowImage = UIImage()
                 self.navigationController?.navigationBar.isTranslucent = false
                 self.navigationController?.view.backgroundColor = .black
                 let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
                 imageView.contentMode = .scaleAspectFit
                 
                 let image = UIImage(named: "smallLimelightLogo")
                 imageView.image = image
                 
                 self.navigationItem.titleView = imageView
             }
          
       

    // MARK: - Table view data source


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


extension UploadTableViewController :  UINavigationControllerDelegate {
    
    
   
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url = \(url)")
        fileURL = url.absoluteString
        fileName = (fileURL as NSString).lastPathComponent
        
        chooseFileLabel.text = fileName
       // saveButton.isEnabled = true
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //dismiss(animated: true, completion: nil)
    }
}


extension UploadTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.coverArtImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


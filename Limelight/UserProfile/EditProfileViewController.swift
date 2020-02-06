//
//  EditProfileViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-11.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseStorage

class EditProfileViewController: UIViewController {
    
    
    var didEditPicture = false
    var bio = ""
    var username = ""
    var name = ""
    var location = ""
    var imgUrl = ""
    
    @IBOutlet weak var bioLabel: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UITextField!
    @IBOutlet weak var locationLabel: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var saveButton: UIButton!
    var imagePicker: UIImagePickerController!
    var isSaving = false
    
    @IBAction func saveButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
                  generator.impactOccurred()
        saveButton.setTitle("Saving", for: .normal)
        saveButton.isEnabled = false

        
        if didEditPicture {
            guard let image = self.profilePicture.image else { return }
            
            if !isSaving {
                uploadProfileImage(image)
                isSaving = true
            }
            
        }else{
            updateUserProfile()
        }
        
    }
    
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
                  generator.impactOccurred()

        self.dismiss(animated: true, completion:nil)
        
        
        
        
        
        
    }
    var db = Firestore.firestore()
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadProfileImage(_ image:UIImage) {
        
        
        //NVActivityIndicatorPresenter.sharedInstance.setMessage("Uploading Profile Picture")
        
        
        let storageRef = Storage.storage().reference().child("user/\(User.uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else{
            return
        }//UIImageJPEGRepresentation(image, 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            // Metadata contains file metadata such as size, content-type.
            let size = metadata?.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                print("Download URL: \(downloadURL)")
                
                
                User.imageUrl = downloadURL.absoluteString
                User.name = self.fullNameLabel.text ?? ""
                User.bio = self.bioLabel.text ?? ""
                let userRef = self.db.collection("users").document(User.uid)
                
                // Set the "capital" field of the city 'DC'
                userRef.updateData([
                    "photoUrl":downloadURL.absoluteString,
                    "bio": self.bioLabel.text ?? "",
                    "name": self.fullNameLabel.text ?? ""
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        print("Document successfully updated")
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter
                                   .default.post(name: NSNotification.Name(rawValue: "updateUserDetail"), object: nil)
                                           
                    }
                }
            }
            
        }
        let observer = uploadTask.observe(.progress) { snapshot in
                   
                     // print(snapshot.progress?.estimatedTimeRemaining)
                     
                     print("Upload Progress: \(Int(Double(snapshot.progress?.fractionCompleted ?? 0.0)*100))%")
            self.progressBar.setProgress(Float(snapshot.progress?.fractionCompleted ?? 0.0), animated: true)
                     
                 }
        
        
    }
    
 
    
    
    
    func updateUserProfile(){
        User.bio = self.bioLabel.text ?? ""
        User.name = self.fullNameLabel.text ?? ""
        let userRef = db.collection("users").document(User.uid)
        
        // Set the "capital" field of the city 'DC'
        userRef.updateData([
            
            "bio": self.bioLabel.text ?? "",
            "name": self.fullNameLabel.text ?? ""
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.dismiss(animated: true, completion: nil)
                                     NotificationCenter
                                                .default.post(name: NSNotification.Name(rawValue: "updateUserDetail"), object: nil)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        progressBar.isHidden = false
        let gradientImage = UIImage.gradientImage(with: progressBar.frame,
                                                  colors: LIMELIGHTGRADIENTCG,
        locations: nil)
        progressBar.progressImage = gradientImage!
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
               profilePicture.isUserInteractionEnabled = true
               profilePicture.addGestureRecognizer(imageTap)
        imagePicker = UIImagePickerController()
              imagePicker.allowsEditing = true
              imagePicker.sourceType = .photoLibrary
              imagePicker.delegate = self

              
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:self.view.frame, andColors: BACKGROUNDGRADIENT)
        detailView.backgroundColor = .clear
        bioLabel.text = bio
        usernameLabel.text = username
        locationLabel.text = location
        fullNameLabel.text = name
        profilePicture.sd_setImageWithURLWithFade(url: URL(string: imgUrl), placeholderImage: UIImage(named: "defaultCoverArt"))
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.darkGray.cgColor
                       
        // Do any additional setup after loading the view.
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.didEditPicture = true
            self.profilePicture.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIImage {
    static func gradientImage(with bounds: CGRect,
                            colors: [CGColor],
                            locations: [NSNumber]?) -> UIImage? {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        // This makes it horizontal
        gradientLayer.startPoint = CGPoint(x: 0.0,
                                        y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0,
                                        y: 0.5)

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}

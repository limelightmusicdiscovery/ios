//
//  UserCell.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    var user : LimelightUser? {
               didSet {
                   profileImage.sd_setImage(with: URL(string: user?.profileImage ?? "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps"), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                       
                      
                      
                       
                   })
                   
                  
                   profileImage.layer.cornerRadius = 25
             
                   profileImage.clipsToBounds = true
                   profileImage.layer.borderWidth = 1
                   profileImage.layer.borderColor = UIColor.black.cgColor
                
                if user?.isFollowing ?? false {
                    followButton.setImage(UIImage(named: "followingButton"), for: .normal)
                }else{
                     followButton.setImage(UIImage(named: "followButton"), for: .normal)
                }
                
                if user?.uid == User.uid {
                    followButton.isHidden = true
                }
                  
                       
                  
                   usernameLabel.text = user?.username
                 nameLabel.text = user?.name
               }
           }
       
       func timeSince(from: NSDate, numericDates: Bool = false) -> String {
                     let calendar = Calendar.current
                     let now = NSDate()
                     let earliest = now.earlierDate(from as Date)
                     let latest = earliest == now as Date ? from : now
                     let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
                     
                     var result = ""
                     
                     if components.year! >= 2 {
                         result = "\(components.year!) years ago"
                     } else if components.year! >= 1 {
                         if numericDates {
                             result = "1 year ago"
                         } else {
                             result = "Last year"
                         }
                     } else if components.month! >= 2 {
                         result = "\(components.month!) months ago"
                     } else if components.month! >= 1 {
                         if numericDates {
                             result = "1 month ago"
                         } else {
                             result = "Last month"
                         }
                     } else if components.weekOfYear! >= 2 {
                         result = "\(components.weekOfYear!) weeks ago"
                     } else if components.weekOfYear! >= 1 {
                         if numericDates {
                             result = "1 week ago"
                         } else {
                             result = "Last week"
                         }
                     } else if components.day! >= 2 {
                         result = "\(components.day!) days ago"
                     } else if components.day! >= 1 {
                         if numericDates {
                             result = "1 day ago"
                         } else {
                             result = "Yesterday"
                         }
                     } else if components.hour! >= 2 {
                         result = "\(components.hour!) hours ago"
                     } else if components.hour! >= 1 {
                         if numericDates {
                             result = "1 hour ago"
                         } else {
                             result = "1 hour ago"
                         }
                     } else if components.minute! >= 2 {
                         result = "\(components.minute!) minutes ago"
                     } else if components.minute! >= 1 {
                         if numericDates {
                             result = "1 minute ago"
                         } else {
                             result = "1 minute ago"
                         }
                     } else if components.second! >= 3 {
                         result = "\(components.second!) seconds ago"
                     } else {
                         result = "Just now"
                     }
                     
                     return result
                 }
                
           
           
           private let textStringLabel : UILabel = {
               let lbl = UILabel()
               lbl.textColor = .lightGray
               lbl.font = UIFont(name: "HelveticaNeue", size: 10)
               lbl.textAlignment = .right
               return lbl
           }()
           
           private let nameLabel : UILabel = {
               let lbl = UILabel()
               lbl.textColor = .lightGray
                lbl.font = UIFont(name: "Arial", size: 10)
               lbl.textAlignment = .left
               return lbl
           }()
           
           
           public let usernameLabel : UILabel = {
               let lbl = UILabel()
               lbl.textColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
               lbl.font = UIFont(name: "Poppins", size: 14)
               lbl.textAlignment = .left
               lbl.numberOfLines = 0
               return lbl
           }()
           
           private let decreaseButton : UIButton = {
               let btn = UIButton(type: .custom)
               btn.setImage(#imageLiteral(resourceName: "pass"), for: .normal)
               btn.imageView?.contentMode = .scaleAspectFill
               return btn
           }()
           
           private let increaseButton : UIButton = {
               let btn = UIButton(type: .custom)
               btn.setImage(#imageLiteral(resourceName: "trackInfo"), for: .normal)
               btn.imageView?.contentMode = .scaleAspectFit
               return btn
           }()
           var productQuantity : UILabel = {
               let label = UILabel()
               label.font = UIFont.boldSystemFont(ofSize: 16)
               label.textAlignment = .left
               label.text = "1"
               label.textColor = .white
               return label
               
           }()
           
           private let profileImage : UIImageView = {
               let imgView = UIImageView(image: #imageLiteral(resourceName: "limelightGreenBarsShadow"))
               imgView.contentMode = .scaleAspectFill
              imgView.layer.cornerRadius =  2
              
               imgView.clipsToBounds = true
               
             
              
               return imgView
           }()
    
    public let followButton : UIButton = {
        let btn = UIButton(type: .custom)
       
        btn.setImage(UIImage(named: "followButton"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    @objc func followUser(_ sender: UIButton){
           
        guard let uid = user?.uid else{
               let generator = UINotificationFeedbackGenerator()
               generator.notificationOccurred(.error)
               return
           }
           
           DispatchQueue.main.async {
               if self.followButton.image(for: .normal) == UIImage(named: "followingButton") {
                   self.followButton.setImage(UIImage(named: "followButton"), for: .normal)
                   let generator = UINotificationFeedbackGenerator()
                          generator.notificationOccurred(.success)
                          
               }else{
                   self.followButton.setImage(UIImage(named: "followingButton"), for: .normal)
                   let generator = UINotificationFeedbackGenerator()
                          generator.notificationOccurred(.success)
                          
               }
           }
          
           
           System.checkIfFollowing(uidToCheck: uid, uid: User.uid) { (action) in
               
               if action == "follow"{
                   print("followed")
                   self.followButton.setImage(UIImage(named: "followingButton"), for: .normal)
               }else if action == "unfollow" {
                   print("unfollowed")
                   self.followButton.setImage(UIImage(named: "followButton"), for: .normal)
               }else{
                   print("error following")
               }
           }
          
           
       }
           
           
           override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
               super.init(style: style, reuseIdentifier: reuseIdentifier)
               addSubview(profileImage)
               addSubview(usernameLabel)
               addSubview(nameLabel)
               addSubview(followButton)
              
               self.backgroundColor = .clear //UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
              // addSubview(decreaseButton)
              // addSubview(productQuantity)
               //ddSubview(increaseButton)
               
               
               profileImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 50, height: 50, enableInsets: false)
                    nameLabel.anchor(top:  usernameLabel.bottomAnchor, left: profileImage.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 5, width: nameLabel.sizeThatFits(nameLabel.frame.size).width, height: 0, enableInsets: false)
                    usernameLabel.anchor(top: topAnchor, left: profileImage.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width:usernameLabel.sizeThatFits(usernameLabel.frame.size).width, height: 0, enableInsets: false)
            followButton.anchor(top: topAnchor, left:nil, bottom: bottomAnchor, right:rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: followButton.sizeThatFits(followButton.frame.size).width, height: 0, enableInsets: false)
            
             followButton.addTarget(self, action: #selector(self.followUser(_:)), for: .touchUpInside)
             
              // profileImage.layer.cornerRadius = profileImage.frame.width / 2
             //  profileImage.layer.masksToBounds = false
              // profileImage.clipsToBounds = true
             //  profileImage.layer.borderWidth = 1
             //  profileImage.layer.borderColor = UIColor.black.cgColor
             
               
           }
           
           required init?(coder aDecoder: NSCoder) {
               fatalError("init(coder:) has not been implemented")
           }
       
       func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
           let size = image.size

           let widthRatio  = targetSize.width  / size.width
           let heightRatio = targetSize.height / size.height

           // Figure out what our orientation is, and use that to form the rectangle
           var newSize: CGSize
           if(widthRatio > heightRatio) {
               newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
           } else {
               newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
           }

           // This is the rect that we've calculated out and this is what is actually used below
           let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

           // Actually do the resizing to the rect using the ImageContext stuff
           UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()

           return newImage
       }
           
           
       }


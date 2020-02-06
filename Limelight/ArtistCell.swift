//
//  ArtistCell.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-18.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import MarqueeLabel

class ArtistCell:  UITableViewCell {
      var rank = 0
      var chartType = WEEKLYTOPTRACKS
    var artist : Artist? {
        didSet {
            profileImage.sd_setImage(with: URL(string: artist?.profileImage ?? "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/eb777e7a-7d3c-487e-865a-fc83920564a1/d7kpm65-437b2b46-06cd-4a86-9041-cc8c3737c6f0.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ViNzc3ZTdhLTdkM2MtNDg3ZS04NjVhLWZjODM5MjA1NjRhMVwvZDdrcG02NS00MzdiMmI0Ni0wNmNkLTRhODYtOTA0MS1jYzhjMzczN2M2ZjAuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.-bP80wHw6Jb8moQRsxURQxONZvAMnJ6xLDD8Es7mHps"), placeholderImage: UIImage(named: "coverDefaultImage"),options: [ .scaleDownLargeImages], completed: { (image, error, cacheType, imageURL) in
                
               
                Cache.incrementImageCacheCount()
                
            })
            
        //    let shadowColor = UIColor.darkGray
        //    self.profileImage.layer.borderWidth = 1
        //    self.profileImage.layer.borderColor = shadowColor.cgColor
                
                               profileImage.layer.cornerRadius = 25
                         
                               profileImage.clipsToBounds = true
                               profileImage.layer.borderWidth = 1
            profileImage.layer.borderColor = UIColor.darkGray.cgColor
            if artist?.name != ""{
                 nameLabel.textColor = .white
                 nameLabel.text = artist?.name
            }else{
                nameLabel.textColor = .darkGray
                 nameLabel.text = artist?.username
                
            }
           
            streamCountLabel.text = "\(artist?.location[CITY] ?? "N/A"), \(artist?.location[STATE] ?? "N/A") • \(artist?.totalStreams ?? 0) streams"// "\(artist?.location[CITY] ?? "N/A"), \(artist?.location[STATE] ?? "N/A")"
            
            //, \(artist?.location[COUNTRY] ?? "N/A")"
            let trimmed = artist?.username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            usernameLabel.text = "\(trimmed ?? "{username}")"
                
            
            
           
            rankLabel.text = "\(rank + 1)"
        }
    }
    
    private let rankLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        lbl.font = UIFont(name: "Poppins-Bold", size: 21)
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    
    public let nameLabel :UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white //UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        lbl.font = UIFont(name: "Poppins", size: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let streamCountLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
         lbl.font = UIFont(name: "Poppins", size: 10)
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    public let usernameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        lbl.font = UIFont(name: "Poppins-", size: 12)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    /* public let trackArtistLabel : UIButton = {
           let btn = UIButton()
         
           btn.setTitleColor(UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1), for: .normal)
           btn.titleLabel?.font = UIFont(name: "Poppins", size: 15)
           btn.contentHorizontalAlignment = .left
           btn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
           btn.titleLabel?.numberOfLines = 0
           return btn
       }()*/
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
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(rankLabel)
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(streamCountLabel)
        self.backgroundColor = .clear //UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
       // addSubview(decreaseButton)
       // addSubview(productQuantity)
        //ddSubview(increaseButton)
        
        rankLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 15, paddingBottom: 10, paddingRight: 0, width: 50, height: 0, enableInsets: false)
        profileImage.anchor(top: topAnchor, left: rankLabel.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 50, height: 0, enableInsets: false)
        nameLabel.anchor(top: topAnchor, left: profileImage.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 5, width: nameLabel.sizeThatFits(nameLabel.frame.size).width, height: 0, enableInsets: false)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: profileImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width:usernameLabel.sizeThatFits(usernameLabel.frame.size).width, height: 0, enableInsets: false)
        streamCountLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: streamCountLabel.sizeThatFits(streamCountLabel.frame.size).width, height: 0, enableInsets: false)
        
        
        let stackView = UIStackView(arrangedSubviews: [decreaseButton,productQuantity,increaseButton])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 5
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: nameLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

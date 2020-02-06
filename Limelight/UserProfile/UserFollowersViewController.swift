//
//  UserFollowersViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-20.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import SwipeMenuViewController
import ChameleonFramework

class UserFollowersViewController: SwipeMenuViewController{
    
    
    var followingIds = [String]()
    var followerIds = [String]()
    var buttonPressed = ""
    
    
    var datas: [String] = ["\(0) Followers","\(0) Following"]
    
    var options = SwipeMenuViewOptions()
   
    var dataCount: Int = 2
    var count = 0
    var searchBar = UISearchBar()
    var profileUid = User.uid
    
    
    @objc func test(){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if profileUid == User.uid {
            datas = ["\(User.followerIds.count) Followers","\(User.followingIds.count) Following"]
           
        }
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
       }
       
    

    
    override func viewDidLoad() {
        
      
     
        setNavBarLogo()
          self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
       
      
       
      
        datas.forEach { data in
            if count == 1{
                let vc = FollowersViewController()//ContentViewController()
                  vc.profileUid = profileUid
                vc.followerKeys = followerIds
                vc.followingKeys = followingIds
                vc.title = data
                //  vc.content = data
                self.addChild(vc)
            }
            else if count == 0 {
                let vc = FollowingViewController()//ContentViewController()
                vc.profileUid = profileUid
                vc.followingKeys = followingIds
                vc.followerKeys = followerIds
                vc.title = data
                //  vc.content = data
                self.addChild(vc)
                
            }
           
            else{
                let vc = ContentViewController()
                vc.title = data
                vc.content = data
                self.addChild(vc)
            }
            
            count = count + 1
        }
        
        
        
        
        super.viewDidLoad()
        
        reload()
        
        
        if buttonPressed == "followers" {
            swipeMenuView.jump(to: 1, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }
    

    private func reload() {
        options.tabView.style = .segmented
        options.tabView.addition = .underline
        options.tabView.itemView.selectedTextColor = .white
        options.tabView.additionView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.leftToRight, withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 1), andColors:[UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1), UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1),UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1)])// UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        options.tabView.backgroundColor = .black
        
        options.tabView.itemView.textColor = .lightGray
        swipeMenuView.reloadData(options: options)
    }

    // MARK: - SwipeMenuViewDelegate

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
        print("will setup SwipeMenuView")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
        print("did setup SwipeMenuView")
        
        if currentIndex == 0{
            searchBar.placeholder = "Search Library Tracks"
        }
        else if currentIndex == 1 {
             searchBar.placeholder = "Search Liked Tracks"
        }
        else if currentIndex == 2{
            searchBar.placeholder = "Search Disliked Tracks"
        }
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
        print("will change from section\(fromIndex + 1)  to section\(toIndex + 1)")
        
        if toIndex == 0{
            searchBar.placeholder = "Search Library Tracks"
        }
        else if toIndex == 1 {
             searchBar.placeholder = "Search Liked Tracks"
        }
        else if toIndex == 2{
            searchBar.placeholder = "Search Disliked Tracks"
        }
    
        
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
        print("did change from section\(fromIndex + 1)  to section\(toIndex + 1)")
        
        
    }


    // MARK - SwipeMenuViewDataSource

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return dataCount
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index]
        vc.didMove(toParent: self)
        return vc
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


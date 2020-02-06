//
//  LibraryViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-24.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import SwipeMenuViewController
import ChameleonFramework
import SideMenu

class LibraryViewController: SwipeMenuViewController, UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        print("update")
    }
    
    
    private var datas: [String] = ["Library Tracks","Liked Tracks", "Disliked Tracks"]
    
    var options = SwipeMenuViewOptions()
    var dataCount: Int = 3
    var count = 0
    var searchBar2 = UISearchBar()
    
    @objc func test(){
        
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
    
    
    

    func setSearchBar(){
        searchBar2.sizeToFit()
               searchBar2.placeholder = ""
              
             let search = UISearchController(searchResultsController: nil)
               search.searchResultsUpdater = self
               self.navigationItem.searchController = search
               
    }
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var searchController = UISearchController(searchResultsController: nil)

    func setSearchBar2(){
      //  let searchController = UISearchController(searchResultsController: nil)
        //searchController.searchResultsUpdater = self.updateSearchResults(for: sl)
          searchController.obscuresBackgroundDuringPresentation = false
          searchController.searchBar.placeholder = "Search artists"
        
        
        
          self.navigationItem.searchController = searchController
          self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // setSearchBar2()
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
   

    override func viewDidLoad() {
         
        setupSideMenu()
        setNavBarLogo()
        
        
     
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: System.frame, andColors: BACKGROUNDGRADIENT)
       
       // setSearchBar2()
        datas.forEach { data in
            if count == 0{
                let vc = LibraryTracksViewController()//ContentViewController()
                vc.title = data
                
                //  vc.content = data
              
                self.addChild(vc)
            }
            else if count == 1 {
                let vc = LikedTracksViewController()//ContentViewController()
                vc.title = data
               
                //  vc.content = data
                self.addChild(vc)
                
            }
            else if count == 2 {
                let vc = DislikedTracksViewController()//ContentViewController()
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
        
        
        // Do any additional setup after loading the view.
    }
    
    func openMusicPlayer(){
        
    }
    
    private func reload() {
        options.tabView.style = .segmented
        options.tabView.addition = .underline
        options.tabView.itemView.selectedTextColor = .white
        options.tabView.additionView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.leftToRight, withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width / 3, height: 1), andColors:[UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1), UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1),UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1)])// UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        options.tabView.backgroundColor = .black //UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
        
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
        
      
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
        print("will change from section\(fromIndex + 1)  to section\(toIndex + 1)")
        
        
       
    
        
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
       
        NotificationCenter
            .default.post(name: NSNotification.Name(rawValue: "dataDeleted"), object: nil)
                      
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
          print("library did appear")
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

class ContentViewController: UIViewController {

    var contentLabel: UILabel! {
        didSet {
            contentLabel.textColor = .black
            contentLabel.textAlignment = .center
            contentLabel.font = UIFont.boldSystemFont(ofSize: 25)
            contentLabel.text = content
            view.addSubview(contentLabel)

            contentLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentLabel.topAnchor.constraint(equalTo: self.view.topAnchor),
                contentLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                contentLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                contentLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }

    var content: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        view.backgroundColor = .black
        contentLabel = UILabel(frame: CGRect(x: 0, y: view.center.y - 50, width: view.frame.width, height: 50))
    }
}


extension UIView {
    var visibleRect: CGRect? {
        guard let superview = superview else { return nil }
        return frame.intersection(superview.bounds)
    }
}

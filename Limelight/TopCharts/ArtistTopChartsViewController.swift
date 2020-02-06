//
//  ArtistTopChartsViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-18.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//


import UIKit
import SwipeMenuViewController
import ChameleonFramework


class ArtistTopChartsViewController: SwipeMenuViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("update")
    }
    
    
    private var datas: [String] = ["Daily","Weekly", "Monthly"]
    
    var options = SwipeMenuViewOptions()
    var dataCount: Int = 3
    var count = 0
    var searchBar = UISearchBar()
    var chartingVariable = ARTISTS
    
    @objc func test(){
        
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
        
        
        //setNavBarLogo()
        self.view.backgroundColor = .clear // UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
       //setSegmentContol()
        /*
        searchBar.sizeToFit()
        searchBar.placeholder = ""
       
      let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        self.navigationItem.searchController = search
        
        */
       
            
        datas.forEach { data in
            if count == 0{
                
                let vc = TopArtistsTableViewController() //ContentViewController()
                vc.title = data
                vc.chartType = DAILYTOPTRACKS
                vc.chartingVariable = chartingVariable
                //  vc.content = data
                self.addChild(vc)
            }
            else if count == 1 {
                let vc = TopArtistsTableViewController()//ContentViewController()
                vc.title = data
                vc.chartType = WEEKLYTOPTRACKS
                vc.chartingVariable = chartingVariable
                //  vc.content = data
                self.addChild(vc)
                
            }
            else if count == 2 {
                let vc = TopArtistsTableViewController()//ContentViewController()
                vc.title = data
                vc.chartType = MONTHLYTOPTRACKS
                vc.chartingVariable = chartingVariable
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
    

    private func reload() {
        options.tabView.style = .segmented
        options.tabView.addition = .underline
        options.tabView.itemView.selectedTextColor = .white
        options.tabView.additionView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.leftToRight, withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width / 3, height: 1), andColors:[UIColor(red: 109/255, green: 38/255, blue: 185/255, alpha: 1), UIColor(red: 219/255, green: 75/255, blue: 156/255, alpha: 1),UIColor(red: 66/255, green: 209/255, blue: 245/255, alpha: 1)])// UIColor(red: 118/255, green: 82/255, blue: 156/255, alpha: 1)
        options.tabView.backgroundColor = .black //UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1) // OLD BACKGROUND COLOR UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
        
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

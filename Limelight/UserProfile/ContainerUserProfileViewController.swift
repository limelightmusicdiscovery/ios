//
//  ContainerUserProfileViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-19.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import SideMenu

class ContainerUserProfileViewController: UIViewController {
    
     @IBOutlet weak var containerView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
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
        super.viewDidLoad()
        setupSideMenu()
         self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: containerView.frame.height), andColors: BACKGROUNDGRADIENT)
setNavBarLogo()
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

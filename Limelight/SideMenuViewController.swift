//
//  SideMenuViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-12-02.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var editGenreButton: UIButton!
     @IBOutlet weak var planTypeLabel: UILabel!
    
    func setNavBarLogo(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        stackView.setCustomSpacing(32.0, after: editGenreButton)
       
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        planTypeLabel.text = Subscription.planType
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        
        //setNavBarLogo()
       // setTitle("Settings", andImage: UIImage(named: "smallLimelightLogo")!)
        // Do any additional setup after loading the view.
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
          // Do something now
          self.dismiss(animated: true) {
              NotificationCenter.default.post(name: .trackUploaded, object: nil)
          }
      }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        NotificationCenter.default.removeObserver(self, name: .didReceiveData, object: nil)
       
    }
    
  
    
    @IBAction func showGenres(sender: UIButton){
        
       // let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseGenres") as! ChooseGenresViewController
                 
                     
       // self.present(vc, animated: true, completion: nil)
        
        let generator = UINotificationFeedbackGenerator()
                   generator.notificationOccurred(.error)
    }
    
    @IBAction func logout(sender: UIButton){
        
        self.dismiss(animated: true) {
                     NotificationCenter.default.post(name: .logout, object: nil)
                 }
           
          
       }
    
    @IBAction func showUploadTrack(sender: UIButton){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "UploadTrack") as! ContainerUploadViewController
                 
                     
        self.present(vc, animated: true, completion: nil)
        
        //let generator = UINotificationFeedbackGenerator()
           //        generator.notificationOccurred(.error)
    }
    
    @IBAction func showReportProblem(sender: UIButton){
           
       let vc = storyboard?.instantiateViewController(withIdentifier: "ReportProblem") as! ContainerReportProblemViewController 
                    
                        
        self.present(vc, animated: true, completion: nil)
           
           //let generator = UINotificationFeedbackGenerator()
              //        generator.notificationOccurred(.error)
       }
    
    @IBAction func showAnalytics(sender: UIButton){
           
           let vc = storyboard?.instantiateViewController(withIdentifier: "AnalyticsView") as! ContainerAnalyticsViewController
                    
                        
           self.present(vc, animated: true, completion: nil)
           
           //let generator = UINotificationFeedbackGenerator()
              //        generator.notificationOccurred(.error)
       }
    
    @IBAction func generateError(sender: UIButton){
        
      //  let vc = storyboard?.instantiateViewController(withIdentifier: "UploadTrack") as! UploadTableViewController
                 
                     
       // self.present(vc, animated: true, completion: nil)
        
        let generator = UINotificationFeedbackGenerator()
                   generator.notificationOccurred(.error)
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

//
//  ContainerAnalyticsViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-31.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit

class ContainerAnalyticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         self.view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           if (segue.identifier == "AnalyticsController") {
               let containerVC = segue.destination  as! AnalyticsTableViewController

              
           }
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

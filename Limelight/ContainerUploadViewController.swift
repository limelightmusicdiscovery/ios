//
//  ContainerUploadViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-27.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol ProgressDelegate {
   func updateProgressBar(elapsed: Float)
}

class ContainerUploadViewController: UIViewController, ProgressDelegate {
 @IBOutlet weak var progressBar: UIProgressView!
    static let shared = ContainerUploadViewController()
    
    func updateProgressBar(elapsed: Float) {
           progressBar.setProgress(elapsed, animated: true)
       }
       
    
     var delegate: ProgressDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: self.view.frame, andColors: BACKGROUNDGRADIENT)
        

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "UploadController") {
            let containerVC = segue.destination  as!  UploadTableViewController

            containerVC.delegate = delegate
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

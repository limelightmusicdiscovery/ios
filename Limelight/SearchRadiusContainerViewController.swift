//
//  SearchRadiusContainerViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-22.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import BottomPopup

class SearchRadiusContainerViewController: BottomPopupViewController, trackOptionsControl, BottomPopupDelegate {
    
      var height: CGFloat?
       var topCornerRadius: CGFloat?
       var presentDuration: Double?
       var dismissDuration: Double?
       var shouldDismissInteractivelty: Bool?
    var source: String?
    var index: Int?
   
    
    func closeTrackOptions(){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
    }
     func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(300)
    }
    
   func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
   func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
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

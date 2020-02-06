//
//  TrackOptionsViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-10.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import BottomPopup


protocol trackOptionsControl {
    func closeTrackOptions()
    
}
class TrackOptionsViewController: BottomPopupViewController, trackOptionsControl {
    
      var height: CGFloat?
       var topCornerRadius: CGFloat?
       var presentDuration: Double?
       var dismissDuration: Double?
       var shouldDismissInteractivelty: Bool?
    var source: String?
    var index: Int?
    var track: Track?
    
    func closeTrackOptions(){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
    }
   func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(575)
    }
    
   func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
   func getPopupPresentDuration() -> Double {
    return presentDuration ?? 0.3
    }
    
   func getPopupDismissDuration() -> Double {
    return dismissDuration ?? 0.3
    }
    
   func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TrackOptions") {
            let vc = segue.destination as! TrackOptionsTableViewController
            vc.delegate = self
            vc.track = track
            
            
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

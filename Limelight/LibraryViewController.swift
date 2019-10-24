//
//  LibraryViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-10-24.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import PolioPager

class LibraryViewController: PolioPagerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  override func tabItems()-> [TabItem] {
        return [TabItem(title: "Redbull"),TabItem(title: "Monster"),TabItem(title: "Caffeine Addiction")]
    }

    override func viewControllers()-> [UIViewController]
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let viewController1 = storyboard.instantiateViewController(withIdentifier: "likes")
        let viewController2 = storyboard.instantiateViewController(withIdentifier: "likes")
        let viewController3 = storyboard.instantiateViewController(withIdentifier: "dislikes")
        let viewController4 = storyboard.instantiateViewController(withIdentifier: "likes")

        return [viewController1, viewController2, viewController3, viewController4]
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

//
//  TableViewHelper.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-02-02.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class TableViewHelper {

    class func EmptyMessage(message:String, viewController:UITableViewController) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: System.frame.width, height: System.frame.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
}

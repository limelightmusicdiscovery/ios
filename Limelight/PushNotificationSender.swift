//
//  PushNotificationSender.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-27.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        print("Sent to token: \(token)")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : "Limelight", "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAPZQIZRE:APA91bFCYqai4lssZp0FnMU-GLpIpiNQ37JvTblj98GGEQQ3m3GVqsw7JsN43k9gH-K_gotCDK3Uoerle15H-6mZL8-fZdk04u2mdRvzVlEqBgopjFxGoKskJJnhNgGNp0xR-ZMSPoJk", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print("Push Notification Error: \(err.debugDescription)")
            }
        }
        task.resume()
    }
}

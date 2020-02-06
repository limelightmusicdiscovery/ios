//
//  AnalyticsTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-31.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import SwiftUI
import SwiftUICharts
import Alamofire
import SwiftyJSON

class AnalyticsTableViewController: UITableViewController {
    
     @IBOutlet weak var containerView: UIView!
     @IBOutlet weak var pieContainerView: UIView!
    @IBOutlet weak var pieContainerView2: UIView!
     @IBOutlet weak var impressionsLabel: UILabel!
       @IBOutlet weak var streamsLabel: UILabel!
        @IBOutlet weak var listenersLabel: UILabel!
       @IBOutlet weak var followersLabel: UILabel!
    var streamData = [Double]()
    var cityData = [(String,Double)]()
    var sourceData = [(String,Double)]()
    var listenerCount = 0
    
   
    @available(iOS 13.0.0, *)
    func addAnalyticsView(){
        let barChartStylePurple = ChartStyle(
            backgroundColor: Color.black,
               accentColor:Color(LIMELIGHTPURPLE) ,
               secondGradientColor: Color(LIMELIGHTPURPLE),
               textColor: Color.white,
               legendTextColor: Color.gray)
               
        let vc = UIHostingController(rootView:
            
            LineView(data: streamData, style: barChartStylePurple, valueSpecifier:  "%.1f").padding()
            /*
            ScrollView(.horizontal) {
            HStack(spacing: 10) {
                VStack{
                   
                    LineChartView(data: streamData, title: "Streams", style: lineChartStyleTwo)
                }
                VStack{
                    LineChartView(data: streamData, title: "Listeners", style: Styles.barChartStyleOrangeDark)
                }
                
            }
        } */)
        /*HStack{
                   LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
                      
               LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
               }*/
      //  let childView = UIHostingController(rootView: Analytics())
         vc.view.backgroundColor = .clear
             addChild(vc)
        vc.view.frame = containerView.frame
        
       // childView.view.frame = containerView.frame
        containerView.addSubview(vc.view)
                // childView.didMove(toParent: self)
              
    }
    
    func getDailyStreamsByUid(start: String, end: String, artistUid: String){ //format of YYYYMMDD
         
    Alamofire.request("https://us-central1-locartist-c2410.cloudfunctions.net/streamsPerDayByArtistUid?startDate=\(start)&endDate=\(end)&artistUid=\(artistUid)")
              .responseJSON { response in
                  
                  switch response.result {
                      case .success(let result):
                      // do what you need
                      
                          var i = 0
                          let swiftyJSONVar = JSON(result)
                          print("Top Chart Count: \(swiftyJSONVar.count)")
                          while i < swiftyJSONVar.count {
                             let streamCount = swiftyJSONVar[i][1].intValue
                             let date = swiftyJSONVar[i][0].stringValue
                             print("\(date):\(streamCount)")
                             self.streamData.append(Double(streamCount))
                            self.totalStreams += streamCount
                           
                            
                            i = i + 1
                            
                     }
                          self.streamsLabel.text = "\(self.totalStreams) Streams"
                          self.getCitiesByUid(start: start, end: end, artistUid: artistUid)
                   
                      case .failure(let error):
                 
                         
                       print("Error: \(error)")
                      }
                 
         }
     }
    
    func getListenersByUid(start: String, end: String, artistUid: String){ //format of YYYYMMDD
           
             
           
      Alamofire.request("https://us-central1-locartist-c2410.cloudfunctions.net/topListeners-1?startDate=\(start)&endDate=\(end)&artistUid=\(artistUid)")
                .responseJSON { response in
                    
                    switch response.result {
                        case .success(let result):
                        // do what you need
                        
                            var i = 0
                            let swiftyJSONVar = JSON(result)
                            print("Top Chart Count: \(swiftyJSONVar.count)")
                            self.listenerCount = swiftyJSONVar.count
                            self.listenersLabel.text = "\(self.listenerCount) Listeners"
                            while i < swiftyJSONVar.count {
                               let streamCount = swiftyJSONVar[i][1].intValue
                               let date = swiftyJSONVar[i][0].stringValue
                               print("\(date):\(streamCount)")
                               i = i + 1
                              
                            
                           
                              
                       }
                        
                        if #available(iOS 13.0, *) {
                                                  self.addAnalyticsView()
                                                  self.addPieChartView()
                                               self.addPieChartView2()
                                              }
                                               
                      
                            
                            
                     
                       
                          
                        case .failure(let error):
                   
                           
                         print("Error: \(error)")
                        }
                   
           }
       }
    
    func getCitiesByUid(start: String, end: String, artistUid: String){ //format of YYYYMMDD
         
           
         
    Alamofire.request("https://us-central1-locartist-c2410.cloudfunctions.net/topCitiesByArtistUid?startDate=\(start)&endDate=\(end)&artistUid=\(artistUid)")
              .responseJSON { response in
                  
                  switch response.result {
                      case .success(let result):
                      // do what you need
                      
                          var i = 0
                          let swiftyJSONVar = JSON(result)
                          print("Top Chart Count: \(swiftyJSONVar.count)")
                          while i < swiftyJSONVar.count {
                             let streamCount = swiftyJSONVar[i][1].intValue
                             let date = swiftyJSONVar[i][0].stringValue
                             print("\(date):\(streamCount)")
                             i = i + 1
                            
                            if date != "undefined, undefined" && streamCount != 1 {
                                self.cityData.append((date,Double(streamCount)))
                            }
                         
                            
                     }
                    
                          
                          self.getSourcesByUid(start: start, end: end, artistUid: artistUid)
                   
                     
                        
                      case .failure(let error):
                 
                         
                       print("Error: \(error)")
                      }
                 
         }
     }
    
    func getSourcesByUid(start: String, end: String, artistUid: String){ //format of YYYYMMDD
            
              
            
       Alamofire.request("https://us-central1-locartist-c2410.cloudfunctions.net/topSourcesByArtistUid?startDate=\(start)&endDate=\(end)&artistUid=\(artistUid)")
                 .responseJSON { response in
                     
                     switch response.result {
                         case .success(let result):
                         // do what you need
                         
                             var i = 0
                             let swiftyJSONVar = JSON(result)
                             print("Top Chart Count: \(swiftyJSONVar.count)")
                             while i < swiftyJSONVar.count {
                                let streamCount = swiftyJSONVar[i][1].intValue
                                let date = swiftyJSONVar[i][0].stringValue
                                print("\(date):\(streamCount)")
                                i = i + 1
                               
                               if date != "undefined, undefined" && streamCount != 1 {
                                   self.sourceData.append((date,Double(streamCount)))
                               }
                            
                               
                        }
                       
                             
                             
                             self.getListenersByUid(start: start, end: end, artistUid: artistUid)
                           
                         case .failure(let error):
                    
                            
                          print("Error: \(error)")
                         }
                    
            }
        }
    
    func addPieChartView(){
        let barChartStylePurple = ChartStyle(
        backgroundColor: Color.black,
        accentColor:Color(LIMELIGHTPURPLE) ,
        secondGradientColor: Color(LIMELIGHTPURPLE),
        textColor: Color.white,
        legendTextColor: Color.gray)
        
      
        let vc = UIHostingController(rootView:
            
            
            
            
          
                

                VStack{
                    BarChartView(data:ChartData(values: cityData), title: "Cities", style: barChartStylePurple,form: CGSize(width: 360, height: 240), dropShadow: false)
                }
                
               
                
            
            
         )
        /*HStack{
                   LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
                      
               LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
               }*/
      //  let childView = UIHostingController(rootView: Analytics())
        vc.view.backgroundColor = .clear
             addChild(vc)
        vc.view.frame = pieContainerView.frame
        
       // childView.view.frame = containerView.frame
        pieContainerView.addSubview(vc.view)
        
                // childView.didMove(toParent: self)
              
    }
    
    func addPieChartView2(){
           let barChartStylePurple = ChartStyle(
           backgroundColor: Color.black,
           accentColor:Color(LIMELIGHTPURPLE) ,
           secondGradientColor: Color(LIMELIGHTPURPLE),
           textColor: Color.white,
           legendTextColor: Color.gray)
           
         
           let vc = UIHostingController(rootView:
               
               
               
               
             
                   

                   VStack{
                   
                       BarChartView(data:ChartData(values: sourceData), title: "Streaming Sources", style: barChartStylePurple,form: CGSize(width: 360, height: 240), dropShadow: false)
                   }
                   
                  
                   
               
               
            )
           /*HStack{
                      LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
                         
                  LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen").padding()
                  }*/
         //  let childView = UIHostingController(rootView: Analytics())
           vc.view.backgroundColor = .clear
                addChild(vc)
           vc.view.frame = pieContainerView2.frame
           
          // childView.view.frame = containerView.frame
           pieContainerView2.addSubview(vc.view)
           
                   // childView.didMove(toParent: self)
                 
       }
       
    
    
    var formatter = DateFormatter()
    var endDate = ""
    var startDate = ""
    var totalStreams = 0

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        impressionsLabel.text = "\(User.profileImpressionCount) Profile Visits"
       
        
        System.getFollowerIdsForUid(uid: User.uid) { (followers) in
            self.followersLabel.text = "\(followers.count) Followers"
        }
        
        formatter.dateFormat = "yyyyMMdd"
            self.endDate = formatter.string(from: Date())
              
              let last1Day = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                     let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                     let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        
        startDate =  formatter.string(from: last30Days!)
        
        getDailyStreamsByUid(start: startDate, end: endDate, artistUid: User.uid)
        
         
    
        //addAnalyticsView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

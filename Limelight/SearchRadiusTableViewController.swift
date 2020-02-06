//
//  SearchRadiusTableViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-22.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import MapKit

class SearchRadiusTableViewController: UITableViewController,  CLLocationManagerDelegate{

    var locationManager = CLLocationManager()
    //@IBOutlet weak var map: MKMapView!
    override func viewDidAppear(_ animated: Bool) {
           print("search radius did appear")
       }
       
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Ask for Authorisation from the User.
             self.locationManager.requestAlwaysAuthorization()
             
             // For use in foreground
             self.locationManager.requestWhenInUseAuthorization()
             
             if CLLocationManager.locationServicesEnabled() {
                 locationManager.delegate = self
                 locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                 locationManager.startUpdatingLocation()
             }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
           print("locations = \(locValue.latitude) \(locValue.longitude)")
           
            User.location[LATITUDE] = locValue.latitude
            User.location[LONGITUDE] = locValue.longitude
           
           let userLocation = locations.last
           
           let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 20000, longitudinalMeters: 20000)
          // self.map.setRegion(viewRegion, animated: true)
           
           
         //  welcomeLabel.text = "Welcome \(UserInfo.username)! We use your location to find talent around you."
           
          // FirebaseManager.updateUserLocation(uid: <#T##String#>)
           
       
           
           
           print("updating child")
           
         
           
         
           
           
           
            locationManager.stopUpdatingLocation()
           
           
           
           
           
           
           // self.continueView()
           
           
           
       
       
       }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

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

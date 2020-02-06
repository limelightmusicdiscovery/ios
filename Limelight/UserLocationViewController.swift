//
//  UserLocationViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2019-11-30.
//  Copyright © 2019 Bilal Khalid. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftyJSON
import Alamofire
import ChameleonFramework
import FirebaseFirestore

import SwiftAudio

class UserLocationViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate{
    
    
    
    var size = CGSize(width: 30, height: 30)
    
    @IBAction func searchButton(_sender: Any){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
     
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
    }
    
    func pushGenreViewController(){
              let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
              let newViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseGenres")// as! ChooseGenresViewController
              navigationController?.pushViewController(newViewController, animated: true)
          }
    
    @IBAction func nextButtonClicked() {
        pushGenreViewController()
    }
    
    @IBOutlet weak var discoverMusicButton: UIButton!
   
  
    
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       // UIApplication.shared.beginIgnoringInteractionEvents()
        
        regionLabel.text = "Loading location..."
        
     
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response,error) in
            if response == nil{
                print("error")
            }else{
                //remove annotations
                let annotations = self.map.annotations
                
                self.map.removeAnnotations(annotations)
                
                //getting data
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                User.location[LATITUDE] = latitude
                User.location[LONGITUDE] = longitude
                
                  self.geocodeUserLocation(lat:latitude!, long: longitude!)
                
                //create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate  = CLLocationCoordinate2DMake(latitude!, longitude!)
              
                self.map.addAnnotation(annotation)
                
                //zooming into annotation
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                
                self.map.setRegion(region, animated: true)
              //  self.plotTrackPoints()
            }
        }
        
        
    }

    
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    

    
   
 
    func drawGeoFence(radius: String, latitude: Double, longitude: Double){
        
        print("drawing geofence")
        let center = CLLocationCoordinate2D(
            latitude: CLLocationDegrees.init(latitude),
            longitude: CLLocationDegrees.init(longitude))
        
        
        
        let circle = MKCircle(center: center, radius: 100000 )  //Double(radius)! * 1000
        
        map.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView,rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.black.withAlphaComponent(0.01)
        circleRenderer.strokeColor = UIColor.black.withAlphaComponent(0.01)
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
   
    func setNavBarLogo(){
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
           self.navigationController?.navigationBar.shadowImage = UIImage()
           self.navigationController?.navigationBar.isTranslucent = true
           self.navigationController?.view.backgroundColor = .clear
           let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
           imageView.contentMode = .scaleAspectFit
           
           let image = UIImage(named: "smallLimelightLogo")
           imageView.image = image
           
           self.navigationItem.titleView = imageView
       }
    override func viewDidLoad() {
        super.viewDidLoad()
       //plotTrackPoints()
        setNavBarLogo()
        
     
        
       
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
        
        
        
        self.view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame:self.view.frame, colors:  [ UIColor(red: 142/255, green: 158/255, blue: 171/255, alpha: 1.0),UIColor(red: 238/255, green: 242/255, blue: 243/255, alpha: 1.0)])
        
        map.layer.shadowColor = UIColor.black.cgColor
        map.layer.shadowOpacity = 1
        map.layer.shadowOffset = .zero
        map.layer.shadowRadius = 10
        map.layer.cornerRadius = 8.0
        map.clipsToBounds = true
        
        
        
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
         User.location[LATITUDE] = locValue.latitude
         User.location[LONGITUDE] = locValue.longitude
        
        let userLocation = locations.last
        
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 20000, longitudinalMeters: 20000)
        self.map.setRegion(viewRegion, animated: true)
        
        
      //  welcomeLabel.text = "Welcome \(UserInfo.username)! We use your location to find talent around you."
        
       // FirebaseManager.updateUserLocation(uid: <#T##String#>)
        
     
        
        geocodeUserLocation(lat: locValue.latitude, long: locValue.longitude)
        
        
        
        print("updating child")
        
      
        
      
        
        
        
         locationManager.stopUpdatingLocation()
        
        
        
        
        
        
        // self.continueView()
        
        
        
    
    
    }
    
    func geocodeUserLocation(lat: Double, long: Double){
        //activityIndicator("Getting Events..")
        
        //create annotation
        let annotation = MKPointAnnotation()
        //annotation.title = searchBar.text
        annotation.coordinate  = CLLocationCoordinate2DMake(lat, long)
      //  self.stopAnimating()
        self.map.addAnnotation(annotation)
        
        let token = "139f44dca310cf"
        
        Alamofire.request("https://us1.locationiq.com/v1/reverse.php?key=\(token)&lat=\(lat)&lon=\(long)&format=json")
            .responseJSON { response in
                
                switch response.result {
                    case .success(let result):
                    // do what you need
                    
                        var i = 0
                        let swiftyJSONVar = JSON(result)
                        
                        //print(swiftyJSONVar)//  response.result.value!)
                        
                        let city = swiftyJSONVar["address"]["city"].stringValue
                        let state = swiftyJSONVar["address"]["state"].stringValue
                        let country = swiftyJSONVar["address"]["country"].stringValue
                        
                      //  print(state)
                        
                        
                        
                        User.location[CITY] = city
                         User.location[STATE] = state
                         User.location[COUNTRY] = country
                    
                      //  self.regionLabel.text = "\(city), \(state), \(country)"
                    
                        let db = Firestore.firestore()
                        
                        db.collection("users").document(User.uid).updateData([
                                        "latitude": lat,
                                        "longitude": long,
                                        "city": city,
                                        "state": state,
                                        "country": country
                                        ])
                                
                    
                        
                        
                        
                    
                    
                    case .failure(let error):
                    // do what you need
                        
                        self.regionLabel.text = "could not find region"
                    
                        
                        print(error)
                    }
                
                
               // DispatchQueue.main.async {
                    // self.getFirestoreTracks()
             //   }
                
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(User.location[LATITUDE] as! CLLocationDegrees, User.location[LONGITUDE] as! CLLocationDegrees)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                
                self.map.setRegion(region, animated: true)
                
                self.regionLabel.text = "\(User.location[CITY] ?? ""), \(User.location[STATE] ?? ""), \(User.location[COUNTRY] ?? "")"
                           
                self.discoverMusicButton.isEnabled = true
                
           
                 
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

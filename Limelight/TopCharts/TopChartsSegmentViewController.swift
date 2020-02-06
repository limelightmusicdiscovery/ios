//
//  TopChartsSegmentViewController.swift
//  Limelight
//
//  Created by Bilal Khalid on 2020-01-17.
//  Copyright © 2020 Bilal Khalid. All rights reserved.
//

import UIKit
import ChameleonFramework
import SideMenu

class TopChartsSegmentViewController: UIViewController {
    
   
    var segmentedControl: UISegmentedControl?
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController?
   
    private lazy var topTracksViewController: TopChartsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "TopCharts") as! TopChartsViewController
        viewController.chartingVariable = TRACKS

       // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var topArtistsViewController: ArtistTopChartsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ArtistTopCharts") as! ArtistTopChartsViewController
        viewController.chartingVariable = ARTISTS
        // Add View Controller as Child View Controller
    
       self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var topListenersViewController: ArtistTopChartsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ArtistTopCharts") as! ArtistTopChartsViewController
        viewController.chartingVariable = LISTENERS
        // Add View Controller as Child View Controller
    
       self.add(asChildViewController: viewController)

        return viewController
    }()
    
    func setNavBarLogo(){
       
        
         self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                       self.navigationController?.navigationBar.shadowImage = UIImage()
                       self.navigationController?.navigationBar.isTranslucent = false
                       self.navigationController?.view.backgroundColor = .black
                       let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
                       imageView.contentMode = .scaleAspectFit
                       
                       let image = UIImage(named: "smallLimelightLogo")
                       imageView.image = image
                       
                       self.navigationItem.titleView = imageView
        
     //   setupNavBarButtons()
          }
    
    func setupNavBarButtons(){
          let button = UIButton(type: UIButton.ButtonType.custom)
         button.titleLabel?.font =  UIFont(name: "Poppins", size: 14)
        button.setTitle("WORLD", for: .normal)
         // button.addTarget(self, action:#selector(backTapped), for: .touchUpInside)
          button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
          let barButton = UIBarButtonItem(customView: button)
          let button2 = UIButton(type: UIButton.ButtonType.custom)
          button2.setImage(UIImage(named: "settings"), for: .normal)
          button2.addTarget(self, action:#selector(chartsFilter(_:)), for: .touchUpInside)
          button2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
          let barButton2 = UIBarButtonItem(customView: button2)
          self.navigationItem.leftBarButtonItems = [barButton2]
          self.navigationItem.rightBarButtonItems = [barButton]
      }
    
    @objc func chartsFilter(_ sender: UIButton) {
        let generator = UINotificationFeedbackGenerator()
                   generator.notificationOccurred(.error)
    }
          
    
    
    var sideMenu = SideMenuNavigationController(rootViewController: SideMenuViewController())
    
    @IBAction func pushSide(sender: UIButton){
             pushSideMenu()
         }
    
    func setupSideMenu(){
        //  SideMenuPresentationStyle.menuStartAlpha = 1
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenu")
        sideMenu = SideMenuNavigationController(rootViewController: newViewController)
        
        sideMenu.leftSide = true
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.menuWidth = 300
    }
  
    
   
    @objc func pushSideMenu(){
        present(sideMenu, animated: true, completion: nil)
    }

    override func viewDidLoad() {
       
        setupSideMenu()
        setNavBarLogo()
        setSegmentContol()
        
        
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:containerView.frame, andColors: BACKGROUNDGRADIENT)
        containerView.backgroundColor = .clear
        add(asChildViewController: topTracksViewController)
        currentViewController = topTracksViewController
               //containerView.backgroundColor = .purple
         super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
       
       

        // Add Child View as Subview
       
       
        addChild(viewController)
        
        // Configure Child View
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
       
        
        if segmentedControl?.selectedSegmentIndex == 0 {
           
            cycleFromViewController(oldViewController:currentViewController! , toViewController: topTracksViewController)
            currentViewController = topTracksViewController
        } else if segmentedControl?.selectedSegmentIndex == 1{
             cycleFromViewController(oldViewController:  currentViewController!, toViewController: topArtistsViewController)
            currentViewController = topArtistsViewController
        }else {
             cycleFromViewController(oldViewController: currentViewController!, toViewController: topListenersViewController)
            currentViewController = topListenersViewController
        }
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        self.addChild(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
                newViewController.view.alpha = 1
                oldViewController.view.alpha = 0
            },
            completion: { finished in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
        })
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)

        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    
    func setSegmentContol(){
           // Container view
        
      
           
           
           let segmentView = UIView()
          
        segmentView.backgroundColor = .black //UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
           self.view.addSubview(segmentView)
        
           segmentView.translatesAutoresizingMaskIntoConstraints = false
           if #available(iOS 11.0, *) {
               let guide = self.view.safeAreaLayoutGuide
               segmentView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
               segmentView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
               segmentView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
               segmentView.heightAnchor.constraint(equalToConstant: 50).isActive = true
           } else {
               NSLayoutConstraint(item: segmentView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: view, attribute: .top,
                                  multiplier: 1.0, constant: 0).isActive = true
               NSLayoutConstraint(item: segmentView,
                                  attribute: .leading,
                                  relatedBy: .equal, toItem: view,
                                  attribute: .leading,
                                  multiplier: 1.0,
                                  constant: 0).isActive = true
               NSLayoutConstraint(item: segmentView, attribute: .trailing,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .trailing,
                                  multiplier: 1.0,
                                  constant: 0).isActive = true

                   segmentView.heightAnchor.constraint(equalToConstant: 50).isActive = true
           }
         
          // let segmentView = UIView(frame: CGRect(x: 0, y:0, width: 400, height: 40))
          // segmentView.backgroundColor = .white
        
      
        
        if #available(iOS 13.0, *) {
                   // use the feature only available in iOS 9
                   // for ex. UIStackView
            segmentedControl = PlainSegmentedControl(items: ["Tracks", "Artists", "Listeners"])
            
            segmentedControl?.tintColor = .lightGray
            segmentedControl?.selectedSegmentTintColor = .white
            segmentedControl?.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
               // First segment is selected by default
            segmentedControl?.selectedSegmentIndex = 0
               
            // Add lines below the segmented control's tintColor
            segmentedControl?.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 23)!,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ] , for: .normal)

            segmentedControl?.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 23)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
                ], for: .selected)
               // This needs to be false since we are using auto layout constraints
            segmentedControl?.translatesAutoresizingMaskIntoConstraints = false

               // Add the segmented control to the container view
            segmentView.addSubview(segmentedControl!)

               // Constrain the segmented control to the top of the container view
            segmentedControl?.topAnchor.constraint(equalTo: segmentView.topAnchor).isActive = true
               // Constrain the segmented control width to be equal to the container view width
            segmentedControl?.widthAnchor.constraint(equalTo: segmentView.widthAnchor).isActive = true
               // Constraining the height of the segmented control to an arbitrarily chosen value
            segmentedControl?.heightAnchor.constraint(equalToConstant: 50).isActive = true
              
               self.view.addSubview(segmentView)
        }else{
               segmentedControl = UISegmentedControl()
          
                       

                          // Add segments
                          segmentedControl?.insertSegment(withTitle: "Top Tracks", at: 0, animated: true)
                          segmentedControl?.insertSegment(withTitle: "Top Artists", at: 1, animated: true)
                          
                         
                           segmentedControl?.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
                          // First segment is selected by default
                          segmentedControl?.selectedSegmentIndex = 0
                          segmentedControl?.backgroundColor = .clear
                          segmentedControl?.tintColor = .clear
                       // Add lines below the segmented control's tintColor
                       segmentedControl?.setTitleTextAttributes([
                           NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 23)!,
                           NSAttributedString.Key.foregroundColor: UIColor.lightGray
                           ], for: .normal)

                       segmentedControl?.setTitleTextAttributes([
                           NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 23)!,
                           NSAttributedString.Key.foregroundColor: UIColor.white
                           ], for: .selected)
                          // This needs to be false since we are using auto layout constraints
                          segmentedControl?.translatesAutoresizingMaskIntoConstraints = false

                          // Add the segmented control to the container view
                          segmentView.addSubview(segmentedControl!)

                          // Constrain the segmented control to the top of the container view
                          segmentedControl?.topAnchor.constraint(equalTo: segmentView.topAnchor).isActive = true
                          // Constrain the segmented control width to be equal to the container view width
                          segmentedControl?.widthAnchor.constraint(equalTo: segmentView.widthAnchor).isActive = true
                          // Constraining the height of the segmented control to an arbitrarily chosen value
                          segmentedControl?.heightAnchor.constraint(equalToConstant: 50).isActive = true
                         
                          self.view.addSubview(segmentView)
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

@available(iOS 13.0, *)
class PlainSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Used for the unselected labels
    override var tintColor: UIColor! {
        didSet {
            setTitleTextAttributes([.foregroundColor: tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
        }
    }

    // Used for the selected label
    override var selectedSegmentTintColor: UIColor? {
        didSet {
            setTitleTextAttributes([.foregroundColor: selectedSegmentTintColor ?? tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
        }
    }

    private func setup() {
        backgroundColor = .clear

        // Use a clear image for the background and the dividers
        let tintColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // Set some default label colors
        setTitleTextAttributes([.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
        setTitleTextAttributes([.foregroundColor: tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
    }
}

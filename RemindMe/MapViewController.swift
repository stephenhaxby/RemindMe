//
//  MapViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 7/10/16.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import MapKit
import UIKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController : UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, HandleMapSearch {
    
    var resultSearchController:UISearchController? = nil
    
    var settingsTableViewCell : SettingsTableViewCell?
    
    var searchBarFrame : CGRect = CGRect()
    
    var setting: Setting? {
        
        get{
            return settingsTableViewCell?.setting
        }
    }
    
    @IBOutlet weak var map: MKMapView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if setting != nil && setting!.latitude != 0 && setting!.longitude != 0 {
            
            displayLocation(forLatitude: setting!.latitude, andLongitude: setting!.longitude, withDefaultZoom: true)
        }
        
        let longPressGestureRecognizer : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.25
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        map.addGestureRecognizer(longPressGestureRecognizer)
        
//        let panGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.dismissSearch))
//        panGestureRecognizer.delegate = self
//        map.addGestureRecognizer(panGestureRecognizer)
//        
//        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissSearch))
//        tapGestureRecognizer.delegate = self
//        map.addGestureRecognizer(tapGestureRecognizer)
        
        //searchBar.delegate = self
        
        // LOCATION SEARCH
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.delegate = self
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
        
        locationSearchTable.handleMapSearchDelegate = self
        
        //navigationItem.titleView = resultSearchController?.searchBar
        
        searchBarFrame = (resultSearchController?.searchBar.frame)!
        let mapViewFrame : CGRect = self.view.frame
        
        resultSearchController?.searchBar.frame = CGRect(x: searchBarFrame.origin.x, y: 64.0, width: mapViewFrame.size.width, height: 44.0)
        
        self.view.addSubview((resultSearchController?.searchBar)!)
        self.view.bringSubview(toFront: (resultSearchController?.searchBar)!)
        
        navigationItem.title = "Location Search"
    }
    
    override func viewWillDisappear(_ animated : Bool){
        
        if setting != nil {
            
            for annotation in map.annotations {
                
                if annotation is MKPointAnnotation {
                    
                    setting?.longitude = annotation.coordinate.longitude
                    setting?.latitude = annotation.coordinate.latitude
                    break
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        settingsTableViewCell?.displayLocation(forLatitude: setting!.latitude, andLongitude: setting!.longitude)
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//     
//        return true
//    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        
//        map.removeAnnotations(map.annotations as [MKAnnotation])
//
//        let localSearchRequest = MKLocalSearchRequest()
//        localSearchRequest.naturalLanguageQuery = searchBar.text
//        
//        let localSearch = MKLocalSearch(request: localSearchRequest)
//        localSearch.start { (localSearchResponse, error) -> Void in
//            
//            searchBar.resignFirstResponder()
//            
//            let location = CLLocationCoordinate2DMake(localSearchResponse!.boundingRegion.center.latitude, localSearchResponse!.boundingRegion.center.longitude)
//
//            self.displayLocation(forLatitude: location.latitude, andLongitude: location.longitude, withDefaultZoom: true)
//            
//            
////            if localSearchResponse == nil{
////                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
////                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
////                self.present(alertController, animated: true, completion: nil)
////                return
////            }
//
////            self.pointAnnotation = MKPointAnnotation()
////            self.pointAnnotation.title = searchBar.text
////            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
//            
////            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
////            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
////            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
//        }
//    }
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer) {
        
        map.removeAnnotations(map.annotations as [MKAnnotation])
        
        let touchPoint = gestureRecognizer.location(in: map)
        let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
        
        displayLocation(forLatitude: newCoordinates.latitude, andLongitude: newCoordinates.longitude, withDefaultZoom: false)
    }
    
    func displayLocation(forLatitude : Double?, andLongitude : Double?, withDefaultZoom defaultZoom : Bool){
        
        if let latitude = forLatitude,
            let longitude = andLongitude {
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            if defaultZoom {
                
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                map.setRegion(region, animated: true)
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            //annotation.title = "Big Ben"
            //annotation.subtitle = "London"
            map.addAnnotation(annotation)
        }
    }

//    func dismissSearch(gestureRecognizer: UIGestureRecognizer){
//        
//        if (gestureRecognizer.state == UIGestureRecognizerState.began
//            || gestureRecognizer.state == UIGestureRecognizerState.ended) {
//        
//            //searchBar.resignFirstResponder()
//        }
//    }
    
    func dropPinZoomIn(placemark: MKPlacemark){

        map.removeAnnotations(map.annotations as [MKAnnotation])
        
        displayLocation(forLatitude: placemark.coordinate.latitude, andLongitude: placemark.coordinate.longitude, withDefaultZoom: true)
        
        resetSearchBar()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.hidesBackButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        resetSearchBar()
    }
    
    func resetSearchBar() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            self.navigationItem.hidesBackButton = false
            self.navigationItem.titleView = UIView()
            
            let mapViewFrame : CGRect = self.view.frame
            
            let containerView : UIView = UIView(frame: CGRect(x: self.searchBarFrame.origin.x, y: 64.0, width: mapViewFrame.size.width, height: 44.0))
            containerView.backgroundColor = UIColor.lightGray
            
            //self.resultSearchController?.searchBar.frame = CGRect(x: self.searchBarFrame.origin.x, y: 64.0, width: mapViewFrame.size.width, height: 44.0)
            //self.resultSearchController?.searchBar.frame = CGRect(x: containerView.frame.origin.x + 20, y: 64.0, width: containerView.frame.size.width - 40, height: 44.0)
            
            //TODO: Get the UISearchBarTextField from the sub view
            //po self.view.subviews[3].subviews[0].subviews
            //UISearchBar
            //UIView
            //UISearchBarTextField
            
//            let searchBarTextField : [UITextField] = self.getSubviewsOfView(view: (self.resultSearchController?.searchBar)!)
//            
//            if searchBarTextField.count == 1 {
//                
//                //searchBarTextField[0].frame = CGRect(x: self.searchBarFrame.origin.x + 20, y: 64.0, width: mapViewFrame.size.width - 40, height: 44.0)
//                
//                var currentTextFieldBounds = searchBarTextField[0].bounds
//                currentTextFieldBounds.size.width = 50.0
//                searchBarTextField[0].bounds = currentTextFieldBounds
//            }
            
            containerView.addSubview((self.resultSearchController?.searchBar)!)
            
            self.view.addSubview(containerView)
            self.view.bringSubview(toFront: containerView)
        }
    }
    
    func getSubviewsOfView<T>(view : UIView) -> [T] {
        var viewsOfType = [T]()
        
        for subview in view.subviews {
            
            viewsOfType += getSubviewsOfView(view: subview)
            
            if subview is T {
                viewsOfType.append(subview as! T)
            }
        }
        
        return viewsOfType
    }
}

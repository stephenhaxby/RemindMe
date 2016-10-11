//
//  MapViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 7/10/16.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import MapKit

class MapViewController : UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    var setting: Setting?
    
    let locationManager : CLLocationManager
    
    @IBOutlet weak var map: MKMapView!
    
    required init?(coder aDecoder: NSCoder) {
        
        locationManager = CLLocationManager()
        
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestAlwaysAuthorization()
        
        if setting != nil, let latitude = setting!.Latitude, let longitude = setting!.Longitude {
            
            displayLocation(forLatitude: latitude, andLongitude: longitude, withDefaultZoom: true)
        }
        else{
            
            if CLLocationManager.locationServicesEnabled() {

                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
        
        let gestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.25
        gestureRecognizer.numberOfTouchesRequired = 1
        
        map.addGestureRecognizer(gestureRecognizer)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if map.annotations.count == 0 {
        
            displayLocation(forLatitude: manager.location?.coordinate.latitude, andLongitude: manager.location?.coordinate.longitude, withDefaultZoom: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer) {
        
        map.removeAnnotations(map.annotations as [MKAnnotation])
        
        let touchPoint = gestureRecognizer.location(in: map)
        let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
        
        displayLocation(forLatitude: newCoordinates.latitude, andLongitude: newCoordinates.longitude, withDefaultZoom: false)
    }
    
    override func viewWillDisappear(_ animated : Bool){
     
        if setting != nil, map.annotations.count > 0 {
            
            setting?.Longitude = map.annotations[0].coordinate.longitude
            setting?.Latitude = map.annotations[0].coordinate.latitude
        }
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

}

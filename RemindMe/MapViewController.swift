//
//  MapViewController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 7/10/16.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import MapKit

class MapViewController : UIViewController, UIGestureRecognizerDelegate {
    
    var settingsTableViewCell : SettingsTableViewCell?
    
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
        
        let gestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.25
        gestureRecognizer.numberOfTouchesRequired = 1
        
        map.addGestureRecognizer(gestureRecognizer)
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

}

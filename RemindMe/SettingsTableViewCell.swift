//
//  SettingsTableViewCell.swift
//  RemindMe
//
//  Created by Stephen Haxby on 5/01/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate { //CLLocationManagerDelegate

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    @IBOutlet weak var mapView: MKMapView!
    
    weak var settingsTableViewController: SettingsTableViewController!
    
    //let locationManager : CLLocationManager
    
    var setting: Setting? {
        didSet {
            
            if setting != nil {

                nameTextField.text = setting!.name
                
                if let time = setting!.time {
                    
                    timeDatePicker.date = time
                }
                
                displayLocation(forLatitude: setting!.Latitude, andLongitude: setting!.Longitude)
                
                nameTextField.delegate = self
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        //locationManager = CLLocationManager()
        
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameTextField.backgroundColor = UIColor.clear
        
        //locationManager.requestAlwaysAuthorization()
    }
    
    // Resign first responder on the text field if the time value changes
    @IBAction func timeValueChanged(_ sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        
        setting!.time = timeDatePicker.date
    }
    
    @IBAction func reminderTypeValueChanged(sender: UISegmentedControl) {
     
        timeDatePicker.isHidden = sender.selectedSegmentIndex != 0
        mapView.isHidden = sender.selectedSegmentIndex == 0
        
//        if sender.selectedSegmentIndex == 1 {
//            
//            if CLLocationManager.locationServicesEnabled() {
//                
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//                locationManager.startUpdatingLocation()
//            }
//        }
        
        setting!.time = nil
        setting!.Latitude = nil
        setting!.Longitude = nil
        
        displayLocation(forLatitude: setting!.Latitude, andLongitude: setting!.Longitude)
    }
    
    // Delegate method to resign first reponder on the text field when the user hits return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Delegate method to set the setting name
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        setting!.name = textField.text!
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        displayLocation(forLatitude: manager.location?.coordinate.latitude, andLongitude: manager.location?.coordinate.longitude)
//    }
    
    func displayLocation(forLatitude : Double?, andLongitude : Double?){
        
        if let latitude = forLatitude,
            let longitude = andLongitude {
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            //            annotation.title = "Big Ben"
            //            annotation.subtitle = "London"
            mapView.addAnnotation(annotation)
        }
    }
}





















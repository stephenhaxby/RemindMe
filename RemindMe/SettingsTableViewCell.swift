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

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    @IBOutlet weak var reminderTypeSegmentedControll: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapViewView: UIView!
    
    let locationManager : CLLocationManager
    
    weak var settingsTableViewController: SettingsTableViewController!
    
    var setting: SettingItem? {
        didSet {
            
            if setting != nil {

                
                nameTextField.text = setting!.name
                reminderTypeSegmentedControll.selectedSegmentIndex = setting!.type.rawValue
                
                nameTextField.delegate = self
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        locationManager = CLLocationManager()
        
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameTextField.backgroundColor = UIColor.clear
        
        let pressGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewPressed(_:)))
        pressGesture.delegate = self
        pressGesture.numberOfTapsRequired = 1
        
        if mapViewView != nil {
            
            mapViewView.addGestureRecognizer(pressGesture)
        }
        
        layoutReminder(forSegmentIndex: reminderTypeSegmentedControll.selectedSegmentIndex)
        
        if setting != nil {
            
            //We need to set the frame on initial load because it's set to 0 here and it kills the displayLocation
            let frame = CGRect(x:60, y:89, width:200, height:80 )
            mapView!.frame = frame
            
            switch setting!.type {
                case Constants.ReminderType.dateTime:
                    
                    timeDatePicker.date = setting!.time!
                
                case Constants.ReminderType.location:
                
                    displayLocation(forLatitude: setting!.latitude!, andLongitude: setting!.longitude!)
                
                default:
                    Utilities().displayAlert(heading: "Error", message: "No setting type could be found for \(setting!.name)", inViewController: settingsTableViewController)
            }
        }
    }
    
    // Resign first responder on the text field if the time value changes
    @IBAction func timeValueChanged(_ sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        
        setting!.set(date: timeDatePicker.date)
    }
    
    @IBAction func reminderTypeValueChanged(sender: UISegmentedControl) {
     
        nameTextField.resignFirstResponder()
        
        layoutReminder(forSegmentIndex: sender.selectedSegmentIndex)
        
//        timeDatePicker.isHidden = sender.selectedSegmentIndex != Constants.ReminderType.dateTime.rawValue
//        mapView.isHidden = sender.selectedSegmentIndex == Constants.ReminderType.dateTime.rawValue
//        mapViewView.isHidden = sender.selectedSegmentIndex == Constants.ReminderType.dateTime.rawValue
//        
//        if !mapView.isHidden
//            && setting!.latitude != nil
//            && setting!.longitude != nil {
//        
//            displayLocation(forLatitude: setting!.latitude!, andLongitude: setting!.longitude!)
//        }
    }
    
    func layoutReminder(forSegmentIndex segmentIndex : Int){
        
        timeDatePicker.isHidden = segmentIndex != Constants.ReminderType.dateTime.rawValue
        mapView.isHidden = segmentIndex == Constants.ReminderType.dateTime.rawValue
        mapViewView.isHidden = segmentIndex == Constants.ReminderType.dateTime.rawValue
        
        reminderTypeSegmentedControll.tintColor = segmentIndex == Constants.ReminderType.dateTime.rawValue
            ? UIColor.orange
            : UIColor(colorLiteralRed: 0, green: 0.47843137250000001, blue: 1, alpha: 1)
        
        if segmentIndex != Constants.ReminderType.dateTime.rawValue {
            
            locationManager.requestAlwaysAuthorization()
            
            if CLLocationManager.locationServicesEnabled() && setting!.latitude == nil && setting?.longitude == nil {
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = manager.location!.coordinate.latitude
        let longitude = manager.location!.coordinate.longitude
        
        setting!.set(latitude: latitude, longitude: longitude)
        
        locationManager.stopUpdatingLocation()
        
        displayLocation(forLatitude: latitude, andLongitude: longitude)
    }
    
    func viewPressed(_ gestureRecognizer: UIGestureRecognizer) {
        
        settingsTableViewController.performSegue(withIdentifier: "mapSegue", sender: self)
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

    func displayLocation(forLatitude latitude : Double, andLongitude longitude : Double){
        
        mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.setCenter(location, animated: true)
        
        mapView.camera.altitude = 1035
        
//            var span = MKCoordinateSpan(latitudeDelta: 126, longitudeDelta: 179)
//            var region = MKCoordinateRegion(center: location, span: span)
//            
//            mapView.setRegion(region, animated: true)
//            
//            span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//            region = MKCoordinateRegion(center: location, span: span)
//
//            //var testRegion = mapView.regionThatFits(region)
//            
//            mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        //            annotation.title = "Big Ben"
        //            annotation.subtitle = "London"
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        //As we a in another thread, post back to the main thread so we can update the UI
        DispatchQueue.main.async { () -> Void in
            
            let errorAlert = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            
            errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
                { (action: UIAlertAction!) in
                    
            }))
            
            self.settingsTableViewController.present(errorAlert, animated: true, completion: nil)
        }
    }
}





















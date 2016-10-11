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

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    @IBOutlet weak var reminderTypeSegmentedControll: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapViewView: UIView!
    
    weak var settingsTableViewController: SettingsTableViewController!
    
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
        
    }
    
    // Resign first responder on the text field if the time value changes
    @IBAction func timeValueChanged(_ sender: AnyObject) {
        
        nameTextField.resignFirstResponder()
        
        setting!.time = timeDatePicker.date
    }
    
    @IBAction func reminderTypeValueChanged(sender: UISegmentedControl) {
     
        layoutReminder(forSegmentIndex: sender.selectedSegmentIndex)
        
        timeDatePicker.isHidden = sender.selectedSegmentIndex != 0
        mapView.isHidden = sender.selectedSegmentIndex == 0
        mapViewView.isHidden = sender.selectedSegmentIndex == 0
        
        setting!.time = nil
        setting!.Latitude = nil
        setting!.Longitude = nil
        
        displayLocation(forLatitude: setting!.Latitude, andLongitude: setting!.Longitude)
    }
    
    func layoutReminder(forSegmentIndex segmentIndex : Int){
        
        timeDatePicker.isHidden = segmentIndex != 0
        mapView.isHidden = segmentIndex == 0
        mapViewView.isHidden = segmentIndex == 0
    }
    
    func viewPressed(_ gestureRecognizer: UIGestureRecognizer) {
        
        settingsTableViewController.performSegue(withIdentifier: "mapSegue", sender: self.setting)
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

    func displayLocation(forLatitude : Double?, andLongitude : Double?){
        
        if let latitude = forLatitude,
            let longitude = andLongitude {
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let span = MKCoordinateSpanMake(0.1, 0.1)
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





















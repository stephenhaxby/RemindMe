//
//  NavigationController.swift
//  RemindMe
//
//  Created by Stephen Haxby on 27/06/2016.
//  Copyright © 2016 Stephen Haxby. All rights reserved.
//

import UIKit

class NavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .orangeColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: Create an image of like one pixel that's white.
        
        navigationBar.setBackgroundImage(UIImage(named: "WhiteDot"), forBarMetrics:UIBarMetrics.Default)
        //navigationBar.translucent = true
        //navigationBar.shadowImage = UIImage()
        //setNavigationBarHidden(false, animated:true)
        
        //navigationBar.barTintColor = .redColor()
        
        navigationBar.tintColor = .orangeColor()
    }
}

//
//  WelcomeViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let backendless = Backendless.sharedInstance()
    var currentUser: BackendlessUser?
    
    
    override func viewWillAppear(animated: Bool) {
        
        backendless.userService.setStayLoggedIn(true)
        
        currentUser = backendless.userService.currentUser
        
        if currentUser != nil {
            
            dispatch_async(dispatch_get_main_queue()){ // make sure UI changing will happend in the main queue 
                
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            vc.selectedIndex = 0
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

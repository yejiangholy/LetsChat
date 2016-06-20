//
//  LoginViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let backendless = Backendless.sharedInstance()
    
    var email:String?
    var password:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: IBActions
    
    @IBAction func loginBarButtonPressed(sender: UIBarButtonItem) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.email = emailTextField.text
            self.password = passwordTextField.text
            
            // log in user 
            loginUser(email!, password: password!)
        } else {
            // warning to user
            
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    func loginUser(email:String, password: String)
    {
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) -> Void in
            
            ProgressHUD.showSuccess("logged in")
            
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
            //segue to recents view 
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            vc.selectedIndex = 0
            ProgressHUD.dismiss()
            
        }) { (fault:Fault!) -> Void in
            print("could't login user \(fault)")
        }
    }
}

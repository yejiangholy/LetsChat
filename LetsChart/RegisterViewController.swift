//
//  RegisterViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    
    var newUser:BackendlessUser?
    var email:String?
    var username:String?
    var password:String?
    var avatarImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newUser = BackendlessUser()

            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   //MARK: IBActions
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.show("Registering...")
            
            email = emailTextField.text
            username = usernameTextField.text
            password = passwordTextField.text
            
            register(self.email!, username: self.username!, password: self.password!, avatarImage: self.avatarImage)
            
        } else{
            //worning to user ..
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    //MARK: Backendless user registration 
    func register(email:String , username:String , password: String , avatarImage: UIImage?)
    {
        if avatarImage == nil{
            newUser!.setProperty("Avatar", object: "")
        }
        
        newUser!.email  = email
        newUser!.name = username
        newUser!.password = password
        
        backendless.userService.registering(newUser, response: {(registerUser: BackendlessUser!) -> Void in
            
            ProgressHUD.dismiss() // dismiss log in animation 
            
              //log in new user 
            self.loginUser(email, username: username, password: password)
            
            //empty text fields
             self.emailTextField.text = ""
             self.passwordTextField.text = ""
             self.usernameTextField.text = ""
            
            }, error: {(fault: Fault!)-> Void in
                 print("Server reported an error, could't register new user: \(fault)")})
    }
    
    func loginUser(email:String, username:String, password:String)
    {
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) -> Void in
            
              //segue to recents view controller 
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            
             vc.selectedIndex = 0
            
        }) { (fault:Fault!) -> Void in
                print("Server reported an error: \(fault)")
        }
    }
    
    
}

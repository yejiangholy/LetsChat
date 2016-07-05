//
//  TermsOfServiceViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/23/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {


    
    
    @IBOutlet weak var TitleTextField: UITextField!
    
    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TitleTextField.enabled = false
        mainTextView.editable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func CancelButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  OtherUtilities.swift
//  LetsChart
//
//  Created by JiangYe on 7/1/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import Foundation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
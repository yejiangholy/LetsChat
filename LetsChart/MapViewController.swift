//
//  MapViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/18/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var region = MKCoordinateRegion()
        
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region,animated:true)
        
        let annotation = MKPointAnnotation()
        mapView.addAnnotation(annotation)
        annotation.coordinate = location.coordinate
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}

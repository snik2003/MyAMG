//
//  MapDealerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class MapDealerViewController: InnerViewController, MKMapViewDelegate {

    var delegate: ServiceDealerViewController!
    var delegate2: Tab4ViewController!
    var delegate3: PartInDealerViewController!
    
    var showroom = AMGShowroom(json: JSON.null)
    var fromCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "На карте"
        if delegate2 != nil { backButton.isHidden = true }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.delegate = self
        mapView.mapType = .standard
        
        let annotation = MKPointAnnotation()
        annotation.title = "\(showroom.name)"
        annotation.subtitle = "\(showroom.address)"
        annotation.coordinate = CLLocationCoordinate2DMake(Double(showroom.latitude)!, Double(showroom.longitude)!)

        var region = MKCoordinateRegion()
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.2
        span.longitudeDelta = 0.2
        
        let location = CLLocationCoordinate2DMake(Double(showroom.latitude)!, Double(showroom.longitude)!)
        region.span = span
        region.center = location
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: false)
        mapView.regionThatFits(region)
        mapView.selectAnnotation(annotation, animated: false)
    }
    
    override func backButtonAction(sender: UIButton) {
        if delegate != nil { delegate.isUpdateLocation = false }
        if delegate2 != nil { delegate2.isUpdateLocation = false }
        if delegate3 != nil { delegate3.isUpdateLocation = false }
        super.backButtonAction(sender: sender)
    }
    
    override func closeButtonAction(sender: UIButton) {
        if delegate2 != nil { delegate2.isUpdateLocation = false }
        super.closeButtonAction(sender: sender)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let defaultPinID = "AMGMapPinDefault"
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: defaultPinID)
        pinView.canShowCallout = false
        pinView.image = UIImage(named: "locator")
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    @IBAction func getRouteAction() {
        if fromCoordinates != nil {
            let urlString = "http://maps.apple.com/maps?daddr=\(showroom.latitude),\(showroom.longitude)&saddr=\(fromCoordinates.latitude),\(fromCoordinates.longitude)"
            
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

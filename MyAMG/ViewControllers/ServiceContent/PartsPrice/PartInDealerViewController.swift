//
//  PartInDealerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 22/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class PartInDealerViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var part: AMGPartSearch!
    var stock: AMGPartObject!
    
    @IBOutlet weak var partNameLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var partsInStockLabel: UILabel!
    @IBOutlet weak var stockNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager: CLLocationManager!
    var isUpdateLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addressCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "phoneCell")
        
        titleLabel.text = "Наличие у дилера"
        
        if let part = self.part, let stock = self.stock {
            partNameLabel.text = part.name.capitalizeName()
            articleLabel.text = part.article
            priceLabel.text = priceToString(priceString: stock.price)
            
            partsInStockLabel.text = "\(stock.partsInStock) шт. в наличии"
            partsInStockLabel.textColor = .black
            
            stockNameLabel.text = stock.stockName
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isUpdateLocation = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for view in cell.subviews {
                if view is UIButton { view.removeFromSuperview() }
            }
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 48))
            button.tag = indexPath.section
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(mapDealer(sender:)), for: .touchUpInside)
            cell.addSubview(button)
            
            let mapImage = UIImageView()
            mapImage.frame = CGRect(x: 20, y: 10.5, width: 27, height: 27)
            mapImage.image = UIImage(named: "map")
            button.addSubview(mapImage)
            
            let label = UILabel()
            label.frame = CGRect(x: 60, y: 0, width: screenWidth - 95, height: 48)
            label.text = stock.address
            label.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textAlignment = .left
            label.textColor = .black
            label.clipsToBounds = true
            button.addSubview(label)
            
            let arrowImage = UIImageView()
            arrowImage.frame = CGRect(x: screenWidth - 28, y: 17.5, width: 8, height: 13)
            arrowImage.image = UIImage(named: "rightArrow")
            button.addSubview(arrowImage)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
            separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
            button.addSubview(separator)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for view in cell.subviews {
                if view is UIButton { view.removeFromSuperview() }
            }
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 48))
            button.tag = indexPath.section
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(phoneDealer(sender:)), for: .touchUpInside)
            cell.addSubview(button)
            
            let mapImage = UIImageView()
            mapImage.frame = CGRect(x: 20, y: 10.5, width: 27, height: 27)
            mapImage.image = UIImage(named: "phoneRed")
            button.addSubview(mapImage)
            
            let label = UILabel()
            label.frame = CGRect(x: 60, y: 0, width: screenWidth - 95, height: 48)
            label.text = stock.phone
            label.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textAlignment = .left
            label.textColor = .black
            button.addSubview(label)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
            separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
            button.addSubview(separator)
            
            return cell
        default:
            return UITableViewCell()
        }
    }

    @objc func phoneDealer(sender: UIButton) {
        showTelPromptWithString(phone: stock.phone)
    }
    
    @objc func mapDealer(sender: UIButton) {
        initLocationManager()
    }
    
    func initLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            isUpdateLocation = false
            showAttention(message: ServiceDealerViewController().locationServicesError)
            return
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        showHUD()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        hideHUD()
        isUpdateLocation = false
        showAttention(message: ServiceDealerViewController().locationServicesError)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        hideHUD()
        manager.stopUpdatingLocation()
        
        if !isUpdateLocation {
            isUpdateLocation = true
            let mapVC = MapDealerViewController()
            if let coordinates = manager.location?.coordinate {
                mapVC.fromCoordinates = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
            mapVC.delegate3 = self
            mapVC.showroom = convertStockInShowroom(stock: stock)
            mapVC.modalPresentationStyle = .overCurrentContext
            self.present(mapVC, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            hideHUD()
        }
    }
    
    func convertStockInShowroom(stock: AMGPartObject) -> AMGShowroom {
        let showroom = AMGShowroom(json: JSON.null)
        
        showroom.name = stock.stockName
        showroom.address = stock.address
        showroom.longitude = "\(stock.longitude)"
        showroom.latitude = "\(stock.latitude)"
        
        return showroom
    }
}

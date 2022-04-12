//
//  Tab4ViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class Tab4ViewController: TabItemViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    let screenName = "test_drive_controller"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet var headerCell: UITableViewCell!
    @IBOutlet var addressCell: UITableViewCell!
    @IBOutlet var doneButtonCell: UITableViewCell!
    
    @IBOutlet weak var doneButtonLeadingConstraint: NSLayoutConstraint!
    
    var showroom = AMGShowroom(json: JSON.null)
    var cellData: [TestDriveProperty] = []
    
    var locationManager: CLLocationManager!
    var isUpdateLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YMReport(message: screenName)
        
        getShowroom()
        addressLabel.text = showroom.address
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "textCell")
        
        let data1 = TestDriveProperty(index: 0)
        let data2 = TestDriveProperty(index: 1)
        let data3 = TestDriveProperty(index: 2)
        let data4 = TestDriveProperty(index: 3)
        cellData = [data1,data2,data3,data4]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if screenHeight < 600 { doneButtonLeadingConstraint.constant = 30}
    }
    
    func getShowroom() {
        showroom.address = "Территория Учебного центра АО «Мерседес-Бенц РУС» Москва, МО, Мытищинский район, 85-й км МКАД, пересечение с Алтуфьевским шоссе, ТПЗ «Алтуфьево», Автомобильный проезд, вл. 5, стр. 1-9. Проезд со стороны ТЦ «Весна»"
        showroom.latitude = "55.917404"
        showroom.longitude = "37.584445"
        showroom.phone = "+7(985)234-81-81"
    }
    
    @IBAction func phoneAction() {
        YMReport(message: screenName, parameters: ["action":"call_for_test_drive_request"])
        showTelPromptWithString(phone: showroom.phone)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case cellData.count + 1:
            return 2
        default:
            let data = cellData[section - 1]
            if data.isOpen {
                if data.isList {
                    return data.list.count
                }
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section > 0 && section <= cellData.count { return 48 }
        
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 36 + 2 * screenWidth / 3
        }
        
        if indexPath.section == cellData.count + 1 {
            switch indexPath.row {
            case 0:
                return 85
            case 1:
                return 140
            default:
                return 0
            }
        }
        
        let data = cellData[indexPath.section - 1]
        if data.isOpen {
            if data.isList {
                return 26
            }
            
            if data.subtitle == "" { return 0 }
            
            let size = CGSize(width: screenWidth - 53, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 15)]
            
            let height = data.subtitle.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
            return height / 16 * 22
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return headerCell
        }
        
        if indexPath.section == cellData.count + 1 {
            if indexPath.row == 0 {
                return addressCell
            } else if indexPath.row == 1 {
                return doneButtonCell
            }
        }
        
        let data = cellData[indexPath.section - 1]
        if data.isOpen {
            if data.isList {
                let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
                cell.backgroundColor = .clear
                
                for view in cell.subviews {
                    if view is UIButton { view.removeFromSuperview() }
                }
                
                let data = cellData[indexPath.section - 1]
                let object = data.list[indexPath.row]
                
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 26))
                button.setTitle("", for: .normal)
                button.addTarget(self, action: #selector(headerButtonAction(sender:)), for: .touchUpInside)
                cell.addSubview(button)
                
                let titleLabel = UILabel()
                titleLabel.frame = CGRect(x: 50, y: 0, width: screenWidth - 70, height: 26)
                titleLabel.text = object.name
                titleLabel.font = UIFont(name: "DaimlerCS-Regular", size: 15)
                titleLabel.numberOfLines = 1
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.contentScaleFactor = 8
                titleLabel.textAlignment = .left
                titleLabel.textColor = UIColor(white: 1, alpha: 0.7)
                button.addSubview(titleLabel)
                
                let arrowImage = UIImageView()
                arrowImage.tag = 1000
                arrowImage.frame = CGRect(x: 33, y: 11, width: 5, height: 4)
                arrowImage.image = UIImage(named: "marker")
                button.addSubview(arrowImage)
                
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
                cell.backgroundColor = .clear
                
                for view in cell.subviews {
                    if view is UILabel { view.removeFromSuperview() }
                }
                
                let data = cellData[indexPath.section - 1]
                
                let size = CGSize(width: screenWidth - 53, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 15)]
                
                let height = data.subtitle.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
                
                let label = UILabel()
                label.frame = CGRect(x: 33, y: 0, width: size.width, height: height / 16 * 22)
                label.text = data.subtitle
                label.font = UIFont(name: "DaimlerCS-Regular", size: 15)
                label.numberOfLines = 0
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.textAlignment = .left
                label.textColor = UIColor(white: 1, alpha: 0.7)
                
                let style = NSMutableParagraphStyle()
                style.minimumLineHeight = 22
                style.maximumLineHeight = 22
                style.alignment = .left
                let attr = [NSAttributedString.Key.paragraphStyle: style];
                
                label.attributedText = NSAttributedString(string: label.text!, attributes: attr)
                cell.addSubview(label)
                
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 && section <= cellData.count {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 48))
            view.backgroundColor = .clear
            
            let index = section - 1
            let data = cellData[index]
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 48))
            button.backgroundColor = .black
            button.tag = index
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(headerButtonAction(sender:)), for: .touchUpInside)
            view.addSubview(button)
            
            let titleLabel = UILabel()
            titleLabel.frame = CGRect(x: 20, y: 0, width: screenWidth - 43, height: 48)
            titleLabel.text = data.title
            titleLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            titleLabel.numberOfLines = 0
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.textAlignment = .left
            titleLabel.textColor = .white
            button.addSubview(titleLabel)
            
            let arrowImage = UIImageView()
            arrowImage.tag = 1000
            arrowImage.frame = CGRect(x: screenWidth - 33, y: 20, width: 13, height: 8)
            if data.isOpen {
                arrowImage.image = UIImage(named: "upArrow")
            } else {
                arrowImage.image = UIImage(named: "downArrow")
            }
            button.addSubview(arrowImage)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
            separator.backgroundColor = UIColor(white: 1, alpha: 0.2)
            button.addSubview(separator)
            
            return view
        }
        
        return UIView()
    }
    
    @objc func headerButtonAction(sender: UIButton) {
        let data = cellData[sender.tag]
        data.isOpen = !data.isOpen
        
        tableView.reloadData()
        if let arrowImage = sender.viewWithTag(1000) as? UIImageView {
            UIView.animate(withDuration: 0.5, animations: {
                arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            })
        }
    }
    
    @IBAction func mapDealer() {
        YMReport(message: screenName, parameters: ["action":"show_address_on_map"])
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
            mapVC.delegate2 = self
            mapVC.showroom = showroom
            mapVC.modalPresentationStyle = .overCurrentContext
            self.present(mapVC, animated: true, completion: { self.fadeView.isHidden = false })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            hideHUD()
        }
    }
}

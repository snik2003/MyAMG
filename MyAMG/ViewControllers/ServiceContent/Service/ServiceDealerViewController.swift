//
//  ServiceDealerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import MapKit

class ServiceDealerViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    let screenName = "service_select_dealer"
    
    var cars: [AMGUserCar] = []
    
    let locationServicesError = "Не удалось определить ваши координаты. Активируйте службу геолокации для текущего приложения в настройках iPhone."
    
    var showrooms: [AMGShowroom] = []
    var selectedShowroom: AMGShowroom!
    
    var locationManager: CLLocationManager!
    var isUpdateLocation = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderButton: AMGButton!
    @IBOutlet weak var dealerNameLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addressCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "phoneCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "orderCell")
        
        backButton.isHidden = true
        titleLabel.text = "Заявка на сервис"
        dealerNameLabel.text = AMGUser.shared.dealerName
        orderButton.addTarget(self, action: #selector(orderToService(sender:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isUpdateLocation = false
        if showrooms.count > 1 {
            orderButton.isHidden = true
            tableViewBottomConstraint.constant = 90
        }
    }
    
    @objc func orderToService(sender: UIButton) {
        if cars.count > 1 {
            let alert = UIAlertController(title: "Выберите автомобиль:", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            for userCar in cars {
                let action = UIAlertAction(title: userCar.nModel, style: .default, handler: { action in
                    
                    self.showHUD()
                    AMGDataManager().getServiceResultForCar(userCar, success: { isCarFind in
                        if isCarFind {
                            AMGDataManager().getServiceShedule(showroomID: self.showrooms[sender.tag].id, success: { shedules, managers in
                                AMGDataManager().getWorkTypeForShowroom(showroom: nil /*self.showrooms[sender.tag]*/, success: { workTypes in
                                    OperationQueue.main.addOperation {
                                        self.hideHUD()
                                        
                                        self.YMReport(message: self.screenName, parameters: ["action":"service_order"])
                                        
                                        let orderVC = ServiceOrderViewController()
                                        orderVC.showroom = self.showrooms[sender.tag]
                                        orderVC.shedules = shedules
                                        orderVC.managers = managers
                                        orderVC.workTypes = workTypes
                                        orderVC.userCar = userCar
                                        orderVC.modalPresentationStyle = .overCurrentContext
                                        self.present(orderVC, animated: true, completion: nil)
                                    }
                                }, failure: {
                                    OperationQueue.main.addOperation {
                                        self.hideHUD()
                                        self.showServerError()
                                    }
                                })
                            }, failure: {
                                OperationQueue.main.addOperation {
                                    self.hideHUD()
                                    self.showServerError()
                                }
                            })
                        } else {
                            OperationQueue.main.addOperation {
                                self.hideHUD()
                                let message = "Для автомобиля \(userCar.nModel) запись на сервис в мобильном приложении недоступна."
                                self.YMReport(message: self.screenName, parameters: ["error":message])
                                self.showAttention(message: message)
                            }
                        }
                    }, failure: {
                        OperationQueue.main.addOperation {
                            self.hideHUD()
                            self.showServerError()
                        }
                    })
                })
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
            
        } else if cars.count == 1 {
            showHUD()
            
            AMGDataManager().getServiceResultForCar(self.cars.first!, success: { isCarFind in
                if isCarFind {
                    AMGDataManager().getServiceShedule(showroomID: self.showrooms[sender.tag].id, success: { shedules, managers in
                        AMGDataManager().getWorkTypeForShowroom(showroom: nil /*self.showrooms[sender.tag]*/, success: { workTypes in
                            OperationQueue.main.addOperation {
                                self.hideHUD()
                                
                                self.YMReport(message: self.screenName, parameters: ["action":"service_order"])
                                
                                let orderVC = ServiceOrderViewController()
                                orderVC.showroom = self.showrooms[sender.tag]
                                orderVC.shedules = shedules
                                orderVC.managers = managers
                                orderVC.workTypes = workTypes
                                orderVC.userCar = self.cars.first
                                orderVC.modalPresentationStyle = .overCurrentContext
                                self.present(orderVC, animated: true, completion: nil)
                            }
                        }, failure: {
                            OperationQueue.main.addOperation {
                                self.hideHUD()
                                self.showServerError()
                            }
                        })
                    }, failure: {
                        OperationQueue.main.addOperation {
                            self.hideHUD()
                            self.showServerError()
                        }
                    })
                } else {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        let message = "Для автомобиля \(self.cars.first!.nModel) запись на сервис в мобильном приложении недоступна."
                        self.YMReport(message: self.screenName, parameters: ["error":message])
                        self.showAttention(message: message)
                    }
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.showServerError()
                }
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return showrooms.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showrooms.count > 1 { return 3 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 { return 100 }
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let showroom = showrooms[indexPath.section]
        
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
            label.frame = CGRect(x: 60, y: 2, width: screenWidth - 95, height: 44)
            label.text = "\(showroom.address)"
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
            label.text = "\(showroom.phone)"
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
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for view in cell.subviews {
                if view is UIButton { view.removeFromSuperview() }
            }
            
            let button = AMGButton()
            button.frame = CGRect(x: 50, y: 12, width: screenWidth - 100, height: 48)
            button.tag = indexPath.section
            button._color = UIColor(red: 217/255, green: 37/255, blue: 43/255, alpha: 1)
            button._margin = 22
            button.setTitle("Записаться на сервис", for: .normal)
            button.addTarget(self, action: #selector(orderToService(sender:)), for: .touchUpInside)
            cell.addSubview(button)
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func phoneDealer(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"call_dealer"])
        
        let showroom = showrooms[sender.tag]
        showTelPromptWithString(phone: showroom.phone)
    }
    
    @objc func mapDealer(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"showroom_on_map"])
        
        selectedShowroom = showrooms[sender.tag]
        initLocationManager()
    }
    
    @IBAction func changeDealerAction() {
        YMReport(message: screenName, parameters: ["action":"change_my_dealer"])
        
        let dealerVC = ChangeDealerViewController()
        dealerVC.delegate = self
        dealerVC.modalPresentationStyle = .overCurrentContext
        self.present(dealerVC, animated: true, completion: nil)
    }
    
    func initLocationManager() {
        if !CLLocationManager.locationServicesEnabled() {
            isUpdateLocation = false
            showAttention(message: locationServicesError)
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
        showAttention(message: locationServicesError)
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
            mapVC.delegate = self
            mapVC.showroom = selectedShowroom!
            mapVC.modalPresentationStyle = .overCurrentContext
            self.present(mapVC, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            hideHUD()
        }
    }
}

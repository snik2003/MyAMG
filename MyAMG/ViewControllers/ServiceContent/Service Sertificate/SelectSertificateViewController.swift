//
//  SelectSertificateViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 05/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectSertificateViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "select_service_certificate"
    let maximumCarAge = 2
    
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var selectCarButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectCarButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCarButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var infoCell: UITableViewCell!
    @IBOutlet var commentCell: UITableViewCell!
    
    var selectedIndexPath: IndexPath!
    
    var order = AMGSSOrder(json: JSON.null)
    var ssTypes: [AMGSSType] = []
    
    var userCar: AMGUserCar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        tableView.register(SertificateCell.self, forCellReuseIdentifier: "sertificateCell")
        
        backButton.isHidden = true
        titleLabel.text = "Сервисный Сертификат"
        
        carLabel.text = ""
        if let car = AMGUser.shared.registrationCars.first {
            carLabel.text = car.nModel
            userCar = car
        }
        
        if AMGUser.shared.registrationCars.count <= 1 {
            selectCarButton.isHidden = true
            selectCarButtonTopConstraint.constant = 0
            selectCarButtonHeightConstraint.constant = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCarForSS()
    }
    
    func checkCarForSS() {
        
        ssTypes = []
        tableView.reloadData()
        
        if !isCarAllowedToGetCertificate() {
            let message = "Сервисный Сертификат доступен только для авто не старше \(maximumCarAge) лет"
            YMReport(message: screenName, parameters: ["warning":message])
            showAttention(message: message)
            return
        }
        
        showHUD()
        AMGDataManager().getSSEngineTypesForCar(userCar, success: { isCarForSS, carClassId, engine in
            if isCarForSS {
                self.order = AMGSSOrder(json: JSON.null)
                self.order.classId = carClassId
                self.order.vin = self.userCar.VIN
                self.order.engineTypeId = engine!.id
                self.order.periodId = 2
                
                AMGDataManager().getSSTypesForEngineType(engineTypeID: self.order.engineTypeId, success: { types in
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        
                        self.ssTypes = types
                        if types.count > 0 {
                            self.tableView.reloadData()
                            if self.tableView.numberOfRows(inSection: 0) > 0 {
                                self.selectedIndexPath = IndexPath(row: 0, section: 0)
                                self.order.scTypeId = types[0].id
                                self.tableView.selectRow(at: self.selectedIndexPath, animated: true, scrollPosition: .top)
                            }
                        }
                    }
                }, failure: {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["serverError":"getSSTypesForEngineType"])
                    self.showServerError()
                })
            } else {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    let message = "Расчет стоимости для выбранного класса автомобиля недоступен из мобильного приложения"
                    self.YMReport(message: self.screenName, parameters: ["warning":message])
                    self.showAttention(message: message)
                }
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["serverError":"getSSEngineTypesForCar"])
                self.showServerError()
            }
        })
    }
    
    func isCarAllowedToGetCertificate() -> Bool {
        let components = Calendar.current.component(.year, from: Date())
        
        if let year = Int(userCar.year) {
            if components - year <= maximumCarAge { return true }
        }
        
        return false
    }
    
    @IBAction func calculatePriceAction() {
        
        if !CheckConnection() {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connection"])
            return
        }
        
        showHUD()
        AMGDataManager().getSSPrices(order: order, success: { orderWithPrice in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                self.YMReport(message: self.screenName, parameters: ["action":"service_sertificate_price"])
                
                orderWithPrice.classId = self.order.classId
                orderWithPrice.vin = self.order.vin
                orderWithPrice.engineTypeId = self.order.engineTypeId
                orderWithPrice.periodId = self.order.periodId
                orderWithPrice.scTypeId = self.order.scTypeId
                
                let priceVC = SertificatePriceViewController()
                priceVC.sertName = self.ssTypes[self.selectedIndexPath.row].text
                priceVC.className = self.userCar.nModel
                priceVC.order = orderWithPrice
                priceVC.userCar = self.userCar
                priceVC.modalPresentationStyle = .overCurrentContext
                self.present(priceVC, animated: true, completion: nil)
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["serverError":"getSSPrices"])
                self.showServerError()
            }
        })
    }
    
    @IBAction func selectCarAction() {
        if AMGUser.shared.registrationCars.count > 1 {
            let alert = UIAlertController(title: "Выберите автомобиль:", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            for car in AMGUser.shared.registrationCars {
                let action = UIAlertAction(title: car.nModel, style: .default, handler: { action in
                    self.YMReport(message: self.screenName, parameters: ["action":"change_car"])
                    self.userCar = car
                    self.carLabel.text = car.nModel
                    self.checkCarForSS()
                })
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoSertificateAction() {
        YMReport(message: screenName, parameters: ["action":"service_certificate_info"])
        
        let infoVC = InfoSertificateViewController()
        infoVC.delegate = self
        infoVC.ssTypes = self.ssTypes
        infoVC.modalPresentationStyle = .overCurrentContext
        self.present(infoVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if ssTypes.count > 0 { return 2 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return ssTypes.count }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 0 { return 60 }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let size = CGSize(width: screenWidth - 40, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 14)]
            
            return commentLabel.text!.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height + 115
        }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let type = ssTypes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "sertificateCell", for: indexPath) as! SertificateCell
            
            cell.nameLabel.text = type.text
            cell.priceLabel.text = ""
            
            return cell
        } else {
            switch indexPath.row {
            case 0:
                return infoCell
            case 1:
                return commentCell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { selectedIndexPath = indexPath }
        order.scTypeId = ssTypes[indexPath.row].id
        tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
    }
}

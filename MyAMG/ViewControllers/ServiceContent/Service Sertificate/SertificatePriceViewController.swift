//
//  SertificatePriceViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 06/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class SertificatePriceViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "service_certificate_price"
    
    var sertName = ""
    var className = ""
    
    @IBOutlet weak var sertLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var phoneCell: UITableViewCell!
    @IBOutlet var commentCell: UITableViewCell!
    
    var selectedPrice: AMGSSPrice!
    var selectedIndexPath: IndexPath!
    
    var order: AMGSSOrder!
    var showroom: AMGShowroom!
    
    var userCar: AMGUserCar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        tableView.register(SertificateCell.self, forCellReuseIdentifier: "sertificateCell")
        
        titleLabel.text = "Стоимость Сертификата"
        sertLabel.text = sertName
        classLabel.text = className
        
        var information = order.descr
        for str in order.footNotes {
            information = "\(information)\n\n\(str)"
        }
        commentLabel.text = information
        
        periodLabel.text = ""
        if order.arrPrice.count > 0 {
            periodLabel.text = "Срок: \(order.arrPrice[0].generalRun)"
            selectedPrice = order.arrPrice[0]
            selectedIndexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getShowrooms()
    }
    
    @IBAction func sendOrderAction() {
        if !CheckConnection() {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connection"])
            return
        }
        
        order.engineGeneralRun = selectedPrice.technicalInspections
        order.showRoomId = showroom.id
        order.showRoomName = showroom.name
        
        order.cityId = AMGUser.shared.dealerCityId
        order.cityName = AMGUser.shared.dealerCityName
        
        YMReport(message: screenName, parameters: ["action":"service_certificate_order"])
        
        let orderVC = SertificateOrderViewController()
        orderVC.order = order
        orderVC.sertName = sertLabel.text!
        orderVC.periodName = periodLabel.text!
        
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.allowsFloats = false
        if let priceString = numFormatter.string(from: NSNumber(value: selectedPrice.price)) {
            orderVC.priceName = "Стоимость: \(priceString) ₽"
        }
        
        orderVC.userCar = userCar
    
        orderVC.modalPresentationStyle = .overCurrentContext
        self.present(orderVC, animated: true, completion: nil)
    }
    
    func getShowrooms() {
        showHUD()
        AMGDataManager().getShowroomsForDealer(dealerId: AMGUser.shared.dealerId, success: { showrooms in
            OperationQueue.main.addOperation {
                self.hideHUD()
                if showrooms.count > 0 { self.showroom = showrooms.first }
            }
        }, failure: {
            self.hideHUD()
        })
    }
    
    @IBAction func phoneDealer() {
        YMReport(message: screenName, parameters: ["action":"call_dealer"])
        showTelPromptWithString(phone: showroom.phone)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return order.arrPrice.count }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 { return 64 }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let size = CGSize(width: screenWidth - 40, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 14)]
            
            return commentLabel.text!.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height + 95
        }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let price = order.arrPrice[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "sertificateCell", for: indexPath) as! SertificateCell
            
            cell.nameLabel.text = price.generalRun
            
            let numFormatter = NumberFormatter()
            numFormatter.numberStyle = .decimal
            numFormatter.allowsFloats = false
            if let priceString = numFormatter.string(from: NSNumber(value: price.price)) {
                cell.priceLabel.text = "\(priceString) ₽"
            }
            
            return cell
        } else {
            switch indexPath.row {
            case 0:
                return phoneCell
            case 1:
                return commentCell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedIndexPath = indexPath
            selectedPrice = order.arrPrice[indexPath.row]
            periodLabel.text = "Срок: \(selectedPrice.generalRun)"
        }
        tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

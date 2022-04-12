//
//  ServiceCalcResultViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class ServiceCalcResultViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "service_calculator_result"
    
    var noAffilateText = "* - информация о конечной стоимости и объеме сервисного обслуживания может быть предоставлена официальным дилером при наличии информации о VIN коде автомобиля.\n\nРекомендованные розничные цены в рублях, включая НДС. Действительны с {date} года.\n\nСтоимость нормо-часа работ указана по информации от дилера. Точные сведения о цене нормо-часа можно получить, обратившись к дилеру по телефону (по адресу).\n\nДанная информация является ориентировочной и не представляет собой оферту, определяемую положениями статей 435, 437 Гражданского Кодекса РФ."
    
    var request: AMGSPCalculationRequest!
    var result: AMGSPCalculationResult!
    var showroom: AMGShowroom!
    var userCar: AMGUserCar!
    
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var mainCell: AMGTableViewCell!
    @IBOutlet var totalCell: AMGTableViewCell!
    @IBOutlet var recomendCell: AMGTableViewCell!
    
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var mainListLabel: UILabel!
    @IBOutlet weak var mainPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var numberFormatter = NumberFormatter()
    var dateFormatter = DateFormatter()
    
    var totalPrice = 0
    var comment = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        tableView.register(SertificateCell.self, forCellReuseIdentifier: "plusCell")
        
        bChangedFormData = true
        titleLabel.text = "Стоимость сервиса"
        
        carLabel.text = userCar.nModel
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        noAffilateText = noAffilateText.replacingOccurrences(of: "{date}", with: dateFormatter.string(from: Date()))
        
        if result.mainOptions.count > 0 {
            mainTextLabel.text = result.serviceMainName
            
            totalPrice = result.price
            if let priceString = numberFormatter.string(from: NSNumber(value: result.price)) {
                mainPriceLabel.text = "\(priceString) ₽"
            }
            
            mainListLabel.text = ""
            for index in 0..<result.mainOptions.count {
                mainListLabel.text = "\(mainListLabel.text!)\(result.mainOptions[index].name.uppercased())"
                if index != result.mainOptions.count-1 { mainListLabel.text = "\(mainListLabel.text!)\n" }
            }
            
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 20
            style.maximumLineHeight = 20
            let attributtes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 11), NSAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.6)]
            
            mainListLabel.attributedText = NSAttributedString(string: mainListLabel.text!, attributes: attributtes as [NSAttributedString.Key : Any])
            mainListLabel.sizeToFit()
        }
        
        if let priceString = numberFormatter.string(from: NSNumber(value: totalPrice)) {
            totalPriceLabel.text = "Итого*: \(priceString) ₽"
        }
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 16
        style.maximumLineHeight = 16
        let attributtes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14), NSAttributedString.Key.foregroundColor: UIColor(white: 0.55, alpha: 1)]
        
        commentLabel.attributedText = NSAttributedString(string: noAffilateText, attributes: attributtes as [NSAttributedString.Key : Any])
        commentLabel.sizeToFit()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if result.plusOptions.count > 0 { return 1 }
            return 0
        case 2:
            return result.plusOptions.count
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if result.mainOptions.count > 0 {
                let size = CGSize(width: screenWidth - 80, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 11)]
                
                var height = mainListLabel.text!.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height / 16 * 20
                
                height += 5 + 24 + 8 + 8 + 48 + 15
                return height
            }
            
            return 0
        case 1:
            return 48
        case 2:
            return 48
        case 3:
            let size = CGSize(width: screenWidth - 40, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 14)]
            
            var height = noAffilateText.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
            
            height += 5 + 40 + 15 + 30 + 48 + 48 + 30 + 50 + 30
            return height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if result.mainOptions.count > 0 { return mainCell }
            return UITableViewCell()
        case 1:
            return recomendCell
        case 2:
            let option = result.plusOptions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "plusCell", for: indexPath) as! SertificateCell
            
            cell.nameLabel.numberOfLines = 0
            cell.nameLabel.text = option.name
            if option.isSpecialOffer {
                cell.nameLabel.text = "\(option.name) (специальная цена)"
            }
            
            if let priceString = numberFormatter.string(from: NSNumber(value: option.price)) {
                cell.priceLabel.text = "\(priceString) ₽"
            }
            
            return cell
        case 3:
            return totalCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SertificateCell {
            cell.setSelected(true, animated: true)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            updateTotalPrice()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SertificateCell {
            cell.setSelected(false, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            updateTotalPrice()
        }
    }
    
    func updateTotalPrice() {
        totalPrice = result.price
        comment = "ВЫБРАННЫЕ УСЛУГИ:"
        
        if totalPrice == 0 {
            YMReport(message: screenName, parameters: ["warning":"total_price_equals_zero"])
        }
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                totalPrice += result.plusOptions[indexPath.row].price
                comment = "\(comment)  \(result.plusOptions[indexPath.row].name),"
            }
        }
        
        if let priceString = numberFormatter.string(from: NSNumber(value: totalPrice)) {
            totalPriceLabel.text = "Итого*: \(priceString) ₽"
            comment = "\(comment)  общая стомость работ: \(priceString) руб"
        }
    }
    
    @IBAction func sendEmailAction() {
        
        if !CheckConnection() { return }
        
        let order = AMGSPEmailOrder(request: request)
        order.email = AMGUser.shared.email
        
        showAlertWithDoubleActions(title: "Подтверждение отправки", text: "Отправить результаты расчета на email \(AMGUser.shared.email)?", title1: "Да", title2: "Нет", completion: {
            
            let order = AMGSPEmailOrder(request: self.request)
            order.email = AMGUser.shared.email
            order.servicePlusIds = self.servicePlusArray()
            
            self.showHUD()
            AMGDataManager().requestServicePriceEmail(order: order, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["action":"service_price_sent_email"])
                    self.showAlertWithTitle(title: "Внимание!", text: "Расчет выслан на указанный в вашем профиле email.")
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["serverError":"requestServicePriceEmail"])
                    self.showServerError()
                }
            })
        }, completion2: {})
    }
    
    func servicePlusArray() -> [Int] {
        var servicePlusIds: [Int] = []
    
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                let option = result.plusOptions[indexPath.row]
                servicePlusIds.append(option.id)
            }
        }
    
        return servicePlusIds
    }

    @IBAction func serviceOrderAction() {
        
        if !CheckConnection() { return }
        
        showHUD()
        AMGDataManager().getServiceResultForCar(userCar, success: { isCarFind in
            if isCarFind {
                AMGDataManager().getServiceShedule(showroomID: self.showroom.id, success: { shedules, managers in
                    AMGDataManager().getWorkTypeForShowroom(showroom: nil /*self.showroom*/, success: { workTypes in
                        OperationQueue.main.addOperation {
                            self.hideHUD()
                            
                            self.YMReport(message: self.screenName, parameters: ["action":"service_order"])
                            
                            let orderVC = ServiceOrderViewController()
                            orderVC.isServicePrice = true
                            orderVC.showroom = self.showroom
                            orderVC.shedules = shedules
                            orderVC.managers = managers
                            orderVC.workTypes = workTypes
                            orderVC.userCar = self.userCar
                            orderVC.comment = self.comment
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
                    let message = "Для автомобиля \(self.userCar.nModel) расчет в мобильном приложении недоступен."
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
    
    @IBAction func showAllOptionsAction() {
        YMReport(message: screenName, parameters: ["action":"show_all_options"])
        
        let detailVC = ServiceCalcDetailViewController()
        detailVC.options = result.detailOptions
        detailVC.modalPresentationStyle = .overCurrentContext
        self.present(detailVC, animated: true, completion: nil)
    }
}

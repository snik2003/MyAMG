//
//  SertificateOrderViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 07/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class SertificateOrderViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "service_certificate_order"
    
    var sertName = ""
    var priceName = ""
    var periodName = ""
    
    var order: AMGSSOrder!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: MMFormPhoneTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var vinTextField: UITextField!
    @IBOutlet weak var regnumTextField: UITextField!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    @IBOutlet var vinCell: AMGTableViewCell!
    @IBOutlet var regnumCell: AMGTableViewCell!
    @IBOutlet var lastNameCell: AMGTableViewCell!
    @IBOutlet var firstNameCell: AMGTableViewCell!
    @IBOutlet var phoneCell: AMGTableViewCell!
    @IBOutlet var emailCell: AMGTableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    
    @IBOutlet var orderCell: UITableViewCell!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sertLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    var userCar: AMGUserCar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        bChangedFormData = true
        titleLabel.text = "Заявка на Сертификат"
        
        sertLabel.text = sertName
        priceLabel.text = priceName
        periodLabel.text = periodName
        
        lastNameTextField.text = AMGUser.shared.lastName
        firstNameTextField.text = AMGUser.shared.firstName
        phoneTextField.text = phoneTextField.formatPhone(String(AMGUser.shared.phone.suffix(10)))
        emailTextField.text = AMGUser.shared.email
        vinTextField.text = userCar.VIN
        regnumTextField.text = userCar.regNumber
        
        cityLabel.text = order.cityName
        cityLabel.textColor = .black
        
        dealerLabel.text = order.showRoomName
        dealerLabel.textColor = .black
        
        lastNameTextField.isEnabled = false
        firstNameTextField.isEnabled = false
        phoneTextField.isEnabled = false
        emailTextField.isEnabled = false
        vinTextField.isEnabled = false
    }

    @IBAction func sendOrder() {
        
        YMReport(message: screenName, parameters: ["action":"send_order"])
        
        if !CheckConnection() {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connection"])
            return
        }
        
        showAlertWithDoubleActions(title: "Подтверждение отправки заявки", text: "Заявка с Вашими контактными данными будет отправлена дилеру", title1: "Да", title2: "Отмена", completion: {
            
            self.showHUD()
            AMGDataManager().sendSSOrder(order: self.order, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["action":"sent_successfully"])
                    self.showAlert(WithTitle: "Заявка отправлена!", andMessage: "Наш менеджер свяжется с Вами для уточнения деталей", completion: {
                        if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            if let vc = tabbarController.selectedViewController as? TabItemViewController {
                                vc.fadeView.isHidden = true
                            }
                        }
                        
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    })
                }
            }, failure: { errorMessage in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["error":errorMessage])
                    self.showAttention(message: errorMessage)
                }
            })
        }, completion2: {})
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 6 || indexPath.row == 9 { return 30 }
        if indexPath.row == 10 { return 140 }
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return lastNameCell
        case 1:
            return firstNameCell
        case 2:
            return phoneCell
        case 3:
            return emailCell
        case 4:
            return vinCell
        case 5:
            return regnumCell
        case 6:
            return emptyCell
        case 7:
            return cityCell
        case 8:
            return dealerCell
        case 9:
            return emptyCell
        case 10:
            return orderCell
        default:
            return UITableViewCell()
        }
    }

}

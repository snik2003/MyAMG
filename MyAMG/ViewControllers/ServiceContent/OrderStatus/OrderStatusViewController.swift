//
//  OrderStatusViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class OrderStatusViewController: InnerViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    let keyDealerOrderNumber = "keyDealerOrderNumber"
    let keyOrderNumber = "keyOrderNumber"
    
    @IBOutlet weak var orderNumberTextField: UITextField!
    @IBOutlet weak var orderDealerNumberTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var orderNumberSeparator: UIView!
    @IBOutlet weak var orderDealerNumberSeparator: UIView!
    
    @IBOutlet var orderNumberCell: AMGTableViewCell!
    @IBOutlet var orderDealerNumberCell: AMGTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.isHidden = true
        titleLabel.text = "Статус заказа"
        
        orderNumberTextField.delegate = self
        orderDealerNumberTextField.delegate = self
        
        if let orderDealerNumber = UserDefaults.standard.value(forKey: keyDealerOrderNumber) {
            orderDealerNumberTextField.text = orderDealerNumber as? String
        }
        
        if let orderNumber = UserDefaults.standard.value(forKey: keyOrderNumber) {
            orderNumberTextField.text = orderNumber as? String
        }
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + 20, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func checkOrderStatusAction() {
        
        if !CheckConnection() { return }
        
        if !isValidForms() {
            tableView.reloadData()
            return
        }
        
        tableView.reloadData()
        
        showHUD()
        AMGDataManager().getOrderStatus(orderDealerNumber: orderDealerNumberTextField.text!, orderNumber: orderNumberTextField.text!, success: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.saveOrderData()
                self.showAlert(WithTitle: "Статус заказа", andMessage: "Получена информация по заказу от сервера. Раздел в стадии разработки.", completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showAttention(message: "Не удалось получить данные от сервера. Проверьте правильность введенных данных и повторите попытку.")
            }
        })
    }
    
    func saveOrderData() {
        UserDefaults.standard.set(orderDealerNumberTextField.text, forKey: keyDealerOrderNumber)
        UserDefaults.standard.set(orderNumberTextField.text, forKey: keyOrderNumber)
        UserDefaults.standard.synchronize()
    }
    
    func isValidForms() -> Bool {
        
        orderDealerNumberCell.setValidated(validated: true)
        orderNumberCell.setValidated(validated: true)
        
        if let orderDealerNumber = orderDealerNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if (orderDealerNumber.isEmpty) {
                orderDealerNumberCell.setValidated(validated: false)
                showAttention(message: "Все поля обязательны для заполнения")
                return false
            }
        }
        
        if let orderNumber = orderNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if (orderNumber.isEmpty) {
                orderNumberCell.setValidated(validated: false)
                showAttention(message: "Все поля обязательны для заполнения")
                return false
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        bChangedFormData = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == orderDealerNumberTextField) {
            orderNumberTextField.becomeFirstResponder()
        } else if (textField == orderNumberTextField) {
                self.view.endEditing(true)
        }
        
        return true
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
        switch indexPath.row {
        case 0:
            if !orderDealerNumberCell.isValidated { return 98 }
            return 48
        case 1:
            if !orderNumberCell.isValidated { return 98 }
            return 48
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            orderDealerNumberSeparator.setStatusSeparator(isValidated: orderDealerNumberCell.isValidated)
            return orderDealerNumberCell
        case 1:
            orderNumberSeparator.setStatusSeparator(isValidated: orderNumberCell.isValidated)
            return orderNumberCell
        default:
            return UITableViewCell()
        }
    }
}

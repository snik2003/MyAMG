//
//  PartDetailViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class PartDetailViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    var part: AMGPartSearch!
    
    @IBOutlet weak var partNameLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var partsInStockLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var citySeparator: UIView!
    @IBOutlet weak var dealerSeparator: UIView!
    
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    @IBOutlet weak var doneButton: AMGButton!
    
    var selectedCity: AMGPartObject?
    var selectedDealer: AMGPartObject?
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Запасная часть"
        
        if let part = self.part {
            partNameLabel.text = part.name.capitalizeName()
            articleLabel.text = part.article
            priceLabel.text = priceToString(priceString: part.price)
            
            if part.partsInStock > 0 {
                partsInStockLabel.text = "\(part.partsInStock) шт. в наличии"
                partsInStockLabel.textColor = .black
                
                selectedCity = AMGPartObject(json: JSON.null)
                selectedCity?.name = "Все города"
                
                selectedDealer = AMGPartObject(json: JSON.null)
                selectedDealer?.name = "Все дилеры"
                
                cityLabel.text = selectedCity?.name
                cityLabel.textColor = .black
                
                dealerLabel.text = selectedDealer?.name
                dealerLabel.textColor = .black
                
                detailLabel.isHidden = false
                doneButton.isHidden = false
                
                tableView.isHidden = false
                tableView.delegate = self
                tableView.dataSource = self
            }
        }
        
        if CheckConnectionWithoutAlert() {
            AMGDataManager().addPartInHistory(article: part.article)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    @IBAction func doneButtonAction() {
        
        if !CheckConnection() { return }
        
        if (!isValidForms()) {
            tableView.reloadData()
            return
        }
        
        tableView.reloadData()
        
        if selectedDealer?.srvId == 0 {
            let dealerVC = PartDealersViewController()
            dealerVC.part = self.part
            dealerVC.modalPresentationStyle = .overCurrentContext
            self.present(dealerVC, animated: true, completion: nil)
        } else {
            let dealerID = selectedDealer?.srvId
            if let stock = part.stocks.filter({ $0.dealerId == dealerID }).last {
                let detailVC = PartInDealerViewController()
                detailVC.part = self.part
                detailVC.stock = stock
                detailVC.modalPresentationStyle = .overCurrentContext
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    }
    
    func getDealersInSelectedCity() -> [AMGPartObject] {
        
        if selectedCity?.srvId == 0 {
            return part.dealers.filter({ $0.name != "Все дилеры" })
        }
        
        let cityID = selectedCity?.srvId
        return part.dealers.filter({ $0.cityId == cityID })
    }
    
    func isValidForms() -> Bool {
        
        cityCell.isValidated = true
        dealerCell.isValidated = true
        
        if (cityLabel.text == "Выберите город" || selectedCity == nil) {
            cityCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if (dealerLabel.text == "Выберите дилера" || selectedDealer == nil) {
            dealerCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
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
            if cityCell.isValidated { return 48 }
            return 98
        case 1:
            if dealerCell.isValidated { return 48 }
            return 98
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            citySeparator.setStatusSeparator(isValidated: cityCell.isValidated)
            return cityCell
        case 1:
            dealerSeparator.setStatusSeparator(isValidated: dealerCell.isValidated)
            return dealerCell
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func cityButtonAction() {
        self.pickerType = PickerType.CityTypePicker
        self.loadPicker()
    }
    
    @IBAction func dealerButtonAction() {
        
        if (selectedCity == nil) {
            showAttention(message: "Пожалуйста, выберите сначала город")
            return
        }
        
        if let part = self.part {
            if (part.dealers.count == 0) {
                self.showAttention(message: "К сожалению, в этом городе нет дилеров Mercedes-Benz. Выберите другой город.")
                    
                self.cityLabel.text = "Выберите город"
                self.cityLabel.textColor = UIColor(white: 0, alpha: 0.3)
                self.selectedCity = nil
                self.dealerLabel.text = "Выберите дилера"
                self.dealerLabel.textColor = UIColor(white: 0, alpha: 0.3)
                self.selectedDealer = nil
            } else {
                self.pickerType = PickerType.DealerTypePicker
                self.loadPicker()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerType {
        case PickerType.CityTypePicker:
            return part.cities.count
        case PickerType.DealerTypePicker:
            if selectedCity?.srvId == 0 { return part.dealers.count }
            let dealers = part.dealers.filter({ $0.cityId == selectedCity?.srvId })
            return dealers.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerType {
        case PickerType.CityTypePicker:
            return part.cities[row].name
        case PickerType.DealerTypePicker:
            if selectedCity?.srvId == 0 { return part.dealers[row].name }
            let dealers = part.dealers.filter({ $0.cityId == selectedCity?.srvId })
            return dealers[row].name
        default:
            return ""
        }
    }
    
    @objc func donePickerAction() {
        
        switch pickerType {
        case PickerType.CityTypePicker:
            cityCell.setValidated(validated: true)
            selectedCity = part.cities[pickerView.selectedRow(inComponent: 0)]
            cityLabel.text = selectedCity?.name
            cityLabel.textColor = .black
            
            if selectedCity?.cityId == 0 {
                selectedDealer?.srvId = 0
                selectedDealer?.name = "Все дилеры"
                
                dealerLabel.text = selectedDealer?.name
            }
            
            tableView.reloadData()
            cancelPickerAction()
        case PickerType.DealerTypePicker:
            dealerCell.setValidated(validated: true)
            if selectedCity?.srvId == 0 {
                selectedDealer = part.dealers[pickerView.selectedRow(inComponent: 0)]
            } else {
                let dealers = part.dealers.filter({ $0.cityId == selectedCity?.srvId })
                selectedDealer = dealers[pickerView.selectedRow(inComponent: 0)]
            }
            
            dealerLabel.text = selectedDealer?.name
            dealerLabel.textColor = .black
            tableView.reloadData()
            cancelPickerAction()
        default:
            cancelPickerAction()
        }
    }
    
    func loadPicker() {
        self.view.endEditing(true)
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.isHidden = false
        toolbar.isHidden = false
        fadeView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height - 206, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height - 250, width: bounds.width, height: 44)
        })
    }
    
    @objc func cancelPickerAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.fadeView.isHidden = true
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44)
        }, completion: { finished in
            self.toolbar.isHidden = true
            self.pickerView.isHidden = true
        })
    }
    
    func makePickerView() {
        let bounds = view.bounds
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206))
        pickerView.backgroundColor = .lightGray
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(donePickerAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPickerAction))
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44))
        toolbar.tintColor = .red
        toolbar.barTintColor = .darkText
        toolbar.sizeToFit()
        toolbar.items = [cancelButton, spaceButton, doneButton]
        
        fadeView = UIView(frame: bounds)
        fadeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        
        pickerView.isHidden = true
        toolbar.isHidden = true
        fadeView.isHidden = true
        
        view.addSubview(fadeView)
        view.addSubview(toolbar)
        view.addSubview(pickerView)
    }
}

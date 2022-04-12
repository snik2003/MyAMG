//
//  ChangeDealerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChangeDealerViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    let screenName = "change_my_dealer"
    
    var delegate: ServiceDealerViewController!
    var isForProfile = false
    
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var dealerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var citySeparator: UIView!
    @IBOutlet weak var dealerSeparator: UIView!
    
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    var cities: [AMGObject] = []
    var dealers: [AMGObject] = []
    
    var selectedCity: AMGObject?
    var selectedDealer: AMGObject?
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Поменять дилера"
        if isForProfile { titleLabel.text = "Мой дилер" }
        
        selectedCity = AMGObject(json: JSON.null)
        selectedCity?.id = AMGUser.shared.dealerCityId
        selectedCity?.name = AMGUser.shared.dealerCityName
        
        cityLabel.text = selectedCity?.name
        cityLabel.textColor = .black
        
        selectedDealer = AMGObject(json: JSON.null)
        selectedDealer?.id = AMGUser.shared.dealerId
        selectedDealer?.name = AMGUser.shared.dealerName
        
        dealerLabel.text = selectedDealer?.name
        dealerLabel.textColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    @IBAction func doneButtonAction() {
        YMReport(message: screenName, parameters: ["action":"done"])
        
        if (!CheckConnection()) {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connections"])
            return
        }
        
        if (!isValidForms()) {
            tableView.reloadData()
            return
        }
        
        if bChangedFormData == false {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        showAlertWithDoubleActions(title: "Внимание!", text: "Вы уверены, что хотите сменить дилера?", title1: "Да", title2: "Нет", completion: {
            
            self.showHUD()
            AMGUserManager().updateUserDealer(dealerID: self.selectedDealer!.id, success: {
                AMGDataManager().getShowroomsForDealer(dealerId: self.selectedDealer!.id, success: { showrooms in
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        
                        self.YMReport(message: self.screenName, parameters: ["action":"done_successfully"])
                        
                        AMGUser.shared.dealerCityId = self.selectedCity!.id
                        AMGUser.shared.dealerCityName = self.selectedCity!.name
                        AMGUser.shared.dealerId = self.selectedDealer!.id
                        AMGUser.shared.dealerName = self.selectedDealer!.name
                        AMGUser.shared.saveCurrentUser()
                        
                        if self.delegate != nil {
                            self.delegate.showrooms = showrooms
                            if showrooms.count > 1 {
                                self.delegate.orderButton.isHidden = true
                                self.delegate.tableViewBottomConstraint.constant = 90
                            } else {
                                self.delegate.orderButton.isHidden = false
                                self.delegate.tableViewBottomConstraint.constant = 170
                            }
                            self.delegate.dealerNameLabel.text = AMGUser.shared.dealerName
                            self.delegate.tableView.reloadData()
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.YMReport(message: self.screenName, parameters: ["error":"dealer_change_failed"])
                        self.showServerError()
                    }
                })
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["error":"dealer_change_failed"])
                    self.showServerError()
                }
            })
        }, completion2: {})
    }
    
    func isValidForms() -> Bool {
        
        cityCell.isValidated = true
        dealerCell.isValidated = true
        
        if (cityLabel.text == "Выберите город" || selectedCity == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            cityCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if (dealerLabel.text == "Выберите дилера" || selectedDealer == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            dealerCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            if (cityCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 1:
            if (dealerCell.isValidated) {
                return 48
            } else {
                return 98
            }
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
        
        showHUD()
        AMGDataManager().getCitiesNames(success: { cities in
            self.hideHUD()
            self.cities = cities
            self.pickerType = PickerType.CityTypePicker
            OperationQueue.main.addOperation {
                self.loadPicker()
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    @IBAction func dealerButtonAction() {
        
        if (selectedCity == nil) {
            showAttention(message: "Пожалуйста, выберите сначала город")
            return
        }
        
        showHUD()
        AMGDataManager().getDealersNames(cityID: Int32(selectedCity!.id), success: { dealers in
            self.hideHUD()
            
            OperationQueue.main.addOperation {
                if (dealers.count == 0) {
                    self.showAttention(message: "К сожалению, в этом городе нет дилеров Mercedes-Benz. Выберите другой город.")
                    
                    self.cityLabel.text = "Выберите город"
                    self.cityLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedCity = nil
                    self.dealerLabel.text = "Выберите дилера"
                    self.dealerLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedDealer = nil
                } else {
                    self.dealers = dealers
                    self.pickerType = PickerType.DealerTypePicker
                    self.loadPicker()
                }
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerType {
        case PickerType.CityTypePicker:
            return cities.count
        case PickerType.DealerTypePicker:
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
            return cities[row].name
        case PickerType.DealerTypePicker:
            return dealers[row].name
        default:
            return ""
        }
    }
    
    @objc func donePickerAction() {
        
        bChangedFormData = true
        
        switch pickerType {
        case PickerType.CityTypePicker:
            cityCell.setValidated(validated: true)
            selectedCity = cities[pickerView.selectedRow(inComponent: 0)]
            cityLabel.text = selectedCity?.name
            cityLabel.textColor = .black
            
            dealerLabel.text = "Выберите дилера"
            dealerLabel.textColor = UIColor(white: 0, alpha: 0.3)
            selectedDealer = nil
            
            tableView.reloadData()
            cancelPickerAction()
        case PickerType.DealerTypePicker:
            dealerCell.setValidated(validated: true)
            selectedDealer = dealers[pickerView.selectedRow(inComponent: 0)]
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

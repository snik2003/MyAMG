//
//  ServiceCalcOptionsViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 09/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class ServiceCalcOptionsViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    let screenName = "service_calculator_settings"
    
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var selectCarButton: UIButton!
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var bodyTypeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var classCell: AMGTableViewCell!
    @IBOutlet var yearCell: AMGTableViewCell!
    @IBOutlet var modelCell: AMGTableViewCell!
    @IBOutlet var bodyTypeCell: AMGTableViewCell!
    @IBOutlet var sliderCell: AMGTableViewCell!
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    @IBOutlet var calculateCell: UITableViewCell!
    
    @IBOutlet weak var slider: MMSlider!
    
    @IBOutlet weak var selectCarButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCarButtonHeightConstraint: NSLayoutConstraint!
    
    var userCar: AMGUserCar!
    var result: AMGServicePriceCarResult!
    var order = AMGSPCalculationRequest()
    
    var selectedCity: AMGObject!
    var selectedShowroom: AMGShowroom!
    
    var cities: [AMGObject] = []
    var showrooms: [AMGShowroom] = []
    
    var numberFormatter = NumberFormatter()
    
    var overallValue = 0
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        backButton.isHidden = true
        titleLabel.text = "Калькулятор сервиса"
        
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
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        showHUD()
        AMGDataManager().getServicePriceCityAndDealerForCurrentUser(success: { cityID, cityName, showroom in
            self.hideHUD()
            
            OperationQueue.main.addOperation {
                if cityName != nil {
                    self.selectedCity = AMGObject(json: JSON.null)
                    self.selectedCity.id = cityID
                    self.selectedCity.name = cityName!
                    
                    self.cityLabel.text = cityName!
                    self.cityLabel.textColor = .black
                }
                
                if showroom.id != 0 {
                    self.selectedShowroom = showroom
                    self.dealerLabel.text = showroom.name
                    self.dealerLabel.textColor = .black
                    
                    self.order.showRoomId = showroom.id
                }
            }
        }, failure: {
            self.hideHUD()
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCarForServicePrice()
    }
    
    func checkCarForServicePrice() {
        
        showHUD()
        AMGDataManager().getServicePriceCarResult(userCar, success: { res in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                if let result = res {
                    if result.completlyFound {
                        self.result = result
                        
                        self.order.className = result.className
                        self.order.classSysName = result.classSysName
                        self.classLabel.text = result.className
                        self.classLabel.textColor = .black
                        
                        self.order.yearId = result.yearId
                        self.order.year = result.yearName
                        self.yearLabel.text = result.yearName
                        self.yearLabel.textColor = .black
                        
                        self.bodyTypeLabel.text = result.bodyTypeName
                        self.bodyTypeLabel.textColor = .black
                        
                        self.order.modelId = self.userCar.idModel
                        self.order.modelName = self.userCar.nModel
                        self.modelLabel.text = self.userCar.nModel
                        self.modelLabel.textColor = .black
                        
                        self.updateMileageSliderWithModel()
                        self.tableView.reloadData()
                        return
                    }
                }
                
                self.result = nil
                self.tableView.reloadData()
                
                let message = "Для автомобиля \(self.userCar.nModel) расчет в мобильном приложении недоступен."
                self.YMReport(message: self.screenName, parameters: ["error":message])
                self.showAttention(message: message)
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["serverError":"getServicePriceCarResult"])
                self.showServerError()
            }
        })
    }
    
    @IBAction func calculateButtonAction() {
        
        YMReport(message: screenName, parameters: ["action":"next"])
        
        if (!CheckConnection()) {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connections"])
            return
        }
        
        if (!isValidForms()) {
            tableView.reloadData()
            return
        }
        
        showHUD()
        AMGDataManager().getServicePriceCalculation(request: order, success: { spResult in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["action":"service_calculator_result"])
                
                let resultVC = ServiceCalcResultViewController()
                resultVC.request = self.order
                resultVC.result = spResult
                resultVC.userCar = self.userCar
                resultVC.showroom = self.selectedShowroom
                resultVC.modalPresentationStyle = .overCurrentContext
                self.present(resultVC, animated: true, completion: nil)
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["serverError":"getServicePriceCalculation"])
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
                    self.checkCarForServicePrice()
                })
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
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
        
        if (dealerLabel.text == "Выберите дилера" || selectedShowroom == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            dealerCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if result == nil { return 0 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 4 { return 72 }
        if indexPath.section == 1 && indexPath.row == 2 { return 100 }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            if (cityCell.isValidated) {
                return 48
            } else {
                return 98
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if (dealerCell.isValidated) {
                return 48
            } else {
                return 98
            }
        }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return classCell
            case 1:
                return yearCell
            case 2:
                return bodyTypeCell
            case 3:
                return modelCell
            case 4:
                return sliderCell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                return cityCell
            case 1:
                return dealerCell
            case 2:
                return calculateCell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func runSliderValueChanged(sender: UISlider) {
        updateMileagesAndLabelsRoundCarMileage(roundCarMileage: true)
    }
    
    func updateMileagesAndLabelsRoundCarMileage(roundCarMileage: Bool) {
        var roundedValue = Int(slider.value)
        
        if roundCarMileage { roundedValue = Int(slider.value / 500) * 500 }
        if roundedValue == 0 { roundedValue = 500 }
    
        var serviceRoundedValue = 0
        for index in 0..<result.mileageItems.count {
            let serviceValue = result.mileageItems[index] + Double(overallValue)
            if Double(roundedValue) <= serviceValue {
                serviceRoundedValue = Int(result.mileageItems[index])
                break
            }
        }
        
        order.mileage = serviceRoundedValue
        order.carMileage = roundedValue
        
        if let mileage = numberFormatter.string(from: NSNumber(value: roundedValue)) {
            mileageLabel.text = "\(mileage) км"
        } else {
            mileageLabel.text = "500 км"
        }
    }
    
    func updateMileageSliderWithModel() {
        if result != nil {
    
            overallValue = 1000
            if result.engineType == 2 { overallValue = 1500 }
            
            slider.minimumValue = 0
            if let maxValue = result.mileageItems.max() {
                slider.maximumValue = Float(maxValue)
            } else {
                slider.maximumValue = 200000
            }
            
            slider.value = 0
            runSliderValueChanged(sender: slider)
        }
    }

    @IBAction func cityButtonAction() {
        
        showHUD()
        AMGDataManager().getServicePriceCities(success: { cities in
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
        AMGDataManager().getServicePriceShowroomsForCityId(selectedCity!.id, success: { showrooms in
            self.hideHUD()
            
            OperationQueue.main.addOperation {
                if (showrooms.count == 0) {
                    self.showAttention(message: "К сожалению, в этом городе нет дилеров Mercedes-Benz. Выберите другой город.")
                    
                    self.cityLabel.text = "Выберите город"
                    self.cityLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedCity = nil
                    self.dealerLabel.text = "Выберите дилера"
                    self.dealerLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedShowroom = nil
                } else {
                    self.showrooms = showrooms
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
            return showrooms.count
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
            return showrooms[row].name
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
            selectedShowroom = nil
            
            tableView.reloadData()
            cancelPickerAction()
        case PickerType.DealerTypePicker:
            dealerCell.setValidated(validated: true)
            selectedShowroom = showrooms[pickerView.selectedRow(inComponent: 0)]
            dealerLabel.text = selectedShowroom?.name
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

//
//  RegAutoViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 14/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

enum PickerType {
    case UnknownTypePicker
    case YearsTypePicker
    case ClassTypePicker
    case ModelTypePicker
    case CityTypePicker
    case DealerTypePicker
    case WorkTypePicker
    case WorkDatePicker
    case ManagerPicker
    case SalonTypePicker
    case EngineTypePicker
    case DrivePicker
    case SortPicker
}

class RegAutoViewController: InnerViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    let screenName = "registrtion_car_and_dealer"
    
    let minCarRegistrationYear = 2000
    @IBOutlet weak var regnumTextField: UITextField!
    
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var doneButton: AMGButton!
    
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var classButton: UIButton!
    @IBOutlet weak var modelButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var dealerButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var yearSeparator: UIView!
    @IBOutlet weak var classSeparator: UIView!
    @IBOutlet weak var modelSeparator: UIView!
    @IBOutlet weak var regnumSeparator: UIView!
    @IBOutlet weak var citySeparator: UIView!
    @IBOutlet weak var dealerSeparator: UIView!
    
    @IBOutlet var yearCell: AMGTableViewCell!
    @IBOutlet var classCell: AMGTableViewCell!
    @IBOutlet var modelCell: AMGTableViewCell!
    @IBOutlet var regnumCell: AMGTableViewCell!
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    @IBOutlet var doneCell: UITableViewCell!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var regnumLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    var years: [String] = []
    var classes: [AMGObject] = []
    var models: [AMGObject] = []
    var cities: [AMGObject] = []
    var dealers: [AMGObject] = []
    
    var selectedClass: AMGObject?
    var selectedModel: AMGObject?
    var selectedCity: AMGObject?
    var selectedDealer: AMGObject?
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    var validationResult: AMGValidationResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Мой AMG"
        bChangedFormData = true
        
        regnumTextField.delegate = self
        
        let fullString = agreeLabel.text
        let coloredString = "обработку"
        let rangeOfColoredString = (fullString! as NSString).range(of: coloredString)
        let attributedString = NSMutableAttributedString(string:fullString!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red],
                                       range: rangeOfColoredString)
        agreeLabel.attributedText = attributedString
        agreeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAgreement)))
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        years = yearsArray()
        
        if validationResult != nil {
            if validationResult.city.name != "" {
                selectedCity = AMGObject(json: JSON.null)
                selectedCity?.id = validationResult.city.id
                selectedCity?.name = validationResult.city.name
                
                cityLabel.text = selectedCity?.name
                cityLabel.textColor = .black
            }
            
            if validationResult.dealer.name != "" {
                selectedDealer = AMGObject(json: JSON.null)
                selectedDealer?.id = validationResult.dealer.id
                selectedDealer?.name = validationResult.dealer.name
                
                dealerLabel.text = selectedDealer?.name
                dealerLabel.textColor = .black
            }
            
            if validationResult.userCar.idClass != 0 {
                selectedClass = AMGObject(json: JSON.null)
                selectedClass?.id = validationResult.userCar.idClass
                selectedClass?.name = validationResult.userCar.nClass
                
                classLabel.text = selectedClass?.name
                classLabel.textColor = .black
            }
            
            if validationResult.userCar.idModel != 0 {
                selectedModel = AMGObject(json: JSON.null)
                selectedModel?.id = validationResult.userCar.idModel
                selectedModel?.name = validationResult.userCar.nModel
                
                modelLabel.text = selectedModel?.name
                modelLabel.textColor = .black
            }
            
            if validationResult.userCar.year != "" && validationResult.userCar.year != "0" {
                yearLabel.text = validationResult.userCar.year
                yearLabel.textColor = .black
                
                if let car = AMGUser.shared.registrationCars.first {
                    car.year = validationResult.userCar.year
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
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
    
    @IBAction func agreeButtonAction(sender: UIButton) {
        if (sender.tag == 0) {
            sender.tag = 1;
            YMReport(message: screenName, parameters: ["action":"agree_personal_data"])
            sender.setImage(UIImage(named: "checked"), for: .normal)
            doneButton.alpha = 1
            doneButton.isEnabled = true
        } else {
            sender.tag = 0;
            YMReport(message: screenName, parameters: ["action":"not_agree_personal_data"])
            sender.setImage(UIImage(named: "unchecked"), for: .normal)
            doneButton.alpha = 0.7
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func doneButton(sender: UIButton) {
        
        YMReport(message: screenName, parameters: ["action":"next"])
        
        if (!CheckConnection()) { return }
        
        if (!isValidForms()) {
            tableView.reloadData()
            return
        }
        
        if let car = AMGUser.shared.registrationCars.first {
            car.regNumber = regnumTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
            if let object = selectedClass {
                car.idClass = object.id
                car.nClass = object.name
            }
            
            if let object = selectedModel {
                car.idModel = object.id
                car.nModel = object.name
            }
        }
        
        if let object = selectedCity {
            AMGUser.shared.dealerCityId = object.id
            AMGUser.shared.dealerCityName = object.name
        }
        
        if let object = selectedDealer {
            AMGUser.shared.dealerId = object.id
            AMGUser.shared.dealerName = object.name
        }
        
        let consentVC = ConsentViewController()
        consentVC.validationResult = validationResult
        consentVC.modalPresentationStyle = .overCurrentContext
        self.present(consentVC, animated: true, completion: nil)
    }
    
    @objc func openAgreement() {
        YMReport(message: screenName, parameters: ["action":"read_agreement_personal_data"])
        
        let appVC = AboutAppViewController()
        appVC.modalPresentationStyle = .overCurrentContext
        self.present(appVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            if (yearCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 1:
            if (classCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 2:
            if (modelCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 3:
            if (regnumCell.isValidated) {
                return 58
            } else {
                return 108
            }
        case 4:
            if (cityCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 5:
            if (dealerCell.isValidated) {
                return 48
            } else {
                return 98
            }
        case 6:
            return 160
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            yearSeparator.setStatusSeparator(isValidated: yearCell.isValidated)
            return yearCell
        case 1:
            classSeparator.setStatusSeparator(isValidated: classCell.isValidated)
            return classCell
        case 2:
            modelSeparator.setStatusSeparator(isValidated: modelCell.isValidated)
            return modelCell
        case 3:
            regnumSeparator.setStatusSeparator(isValidated: regnumCell.isValidated)
            return regnumCell
        case 4:
            citySeparator.setStatusSeparator(isValidated: cityCell.isValidated)
            return cityCell
        case 5:
            dealerSeparator.setStatusSeparator(isValidated: dealerCell.isValidated)
            return dealerCell
        default:
            return doneCell
        }
    }
    
    func isValidForms() -> Bool {
        
        yearCell.isValidated = true
        classCell.isValidated = true
        modelCell.isValidated = true
        regnumCell.isValidated = true
        cityCell.isValidated = true
        dealerCell.isValidated = true
        
        if (yearLabel.text == "Укажите год выпуска") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            yearCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if (classLabel.text == "Укажите класс" || selectedClass == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            classCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if (modelLabel.text == "Укажите модель" || selectedModel == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            modelCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if let number = regnumTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            if (number.isEmpty) {
                YMReport(message: screenName, parameters: ["warning":"empty_fields"])
                regnumCell.setValidated(validated: false)
                regnumLabel.text = "Укажите гос. номер"
                tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                showAttention(message: "Пожалуйста, укажите регистрационный номер автомобиля.\n\n * Формат номера А000АА00[0],\nможет содержать только \nцифры и буквы кириллицы")
                return false
            }
            
            let testNumber = NSPredicate(format: "SELF MATCHES %@", "[АВЕКМНОРСТУХ][0-9]{3}[АВЕКМНОРСТУХ]{2}[0-9]{2}([0-9])?")
            if !(number.count > 7 && number.count < 10 && testNumber.evaluate(with: number)) {
                regnumCell.setValidated(validated: false)
                regnumLabel.text = "Гос. номер введен некорректно"
                tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                showAttention(message: "Регистрационный номер автомобиля введен некорректно.\n\n * Формат номера А000АА00[0],\nможет содержать только \nцифры и буквы кириллицы")
                regnumTextField.becomeFirstResponder()
                return false
            }
        }
        
        if (cityLabel.text == "Выберите город" || selectedCity == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            cityCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        if (dealerLabel.text == "Выберите дилера" || selectedDealer == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            dealerCell.setValidated(validated: false)
            tableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
            showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == regnumTextField) {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        bChangedFormData = true
        
        if textField == regnumTextField && textField.textInputMode?.primaryLanguage != "ru-RU" {
            showAttention(message: "Пожалуйста, переключите клавиатуру на русский язык.")
        }
        
        if (textField == regnumTextField) {
            
            if (string.count == 0) {
                return true
            }
            
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789АВЕКМНОРСТУХ") && (prospectiveText.count <= 9)
            
        }
        
        return true
    }
    
    @IBAction func yearsButtonAction() {
        pickerType = PickerType.YearsTypePicker
        loadPicker()
    }
    
    @IBAction func classButtonAction() {
        showHUD()
        AMGDataManager().getClassesNames(success: { classes in
            self.hideHUD()
            self.classes = classes
            self.pickerType = PickerType.ClassTypePicker
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
    
    @IBAction func modelButtonAction() {
        
        if (selectedClass == nil) {
            showAttention(message: "Пожалуйста, укажите сначала класс автомобиля")
            return
        }
        
        showHUD()
        AMGDataManager().getModelsNames(classID: Int32(selectedClass!.id), success: { models in
            self.hideHUD()
    
            OperationQueue.main.addOperation {
                if (models.count == 0) {
                    self.showAttention(message: "К сожалению, для этого класса моделей не найдено. Выберите другой класс.")
                    
                    self.classLabel.text = "Укажите класс"
                    self.classLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedClass = nil
                    self.modelLabel.text = "Укажите модель"
                    self.modelLabel.textColor = UIColor(white: 0, alpha: 0.3)
                    self.selectedModel = nil
                } else {
                    self.models = models
                    self.pickerType = PickerType.ModelTypePicker
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
    
    func yearsArray() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
    
        var years: [String] = []
        if let currentYear = Int(dateFormatter.string(from: Date())) {
            let allowableNumbersArrayCount = currentYear - minCarRegistrationYear + 1;
            
            for index in  0..<allowableNumbersArrayCount {
                years.append("\(currentYear-index)")
            }
        }
    
        return years
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerType {
        case PickerType.YearsTypePicker:
            return years.count
        case PickerType.ClassTypePicker:
            return classes.count
        case PickerType.ModelTypePicker:
            return models.count
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
        case PickerType.YearsTypePicker:
            return years[row]
        case PickerType.ClassTypePicker:
            return classes[row].name
        case PickerType.ModelTypePicker:
            return models[row].name
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
        case PickerType.YearsTypePicker:
            yearCell.setValidated(validated: true)
            yearLabel.text = years[pickerView.selectedRow(inComponent: 0)]
            yearLabel.textColor = .black
            
            if let car = AMGUser.shared.registrationCars.first {
                car.year = years[pickerView.selectedRow(inComponent: 0)]
            }
            
            tableView.reloadData()
            cancelPickerAction()
        case PickerType.ClassTypePicker:
            classCell.setValidated(validated: true)
            selectedClass = classes[pickerView.selectedRow(inComponent: 0)]
            classLabel.text = selectedClass?.name
            classLabel.textColor = .black
            
            modelLabel.text = "Укажите модель"
            modelLabel.textColor = UIColor(white: 0, alpha: 0.3)
            selectedModel = nil
            
            tableView.reloadData()
            cancelPickerAction()
        case PickerType.ModelTypePicker:
            modelCell.setValidated(validated: true)
            selectedModel = models[pickerView.selectedRow(inComponent: 0)]
            modelLabel.text = selectedModel?.name
            modelLabel.textColor = .black
            tableView.reloadData()
            cancelPickerAction()
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
            self.pickerView.layer.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206)
            self.toolbar.layer.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44)
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

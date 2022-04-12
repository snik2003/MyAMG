//
//  MyAutoViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 19/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ViewTypeMode {
    case ViewMode
    case AddCarMode
}

class MyAutoViewController: InnerViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    var screenName = "my_car"
    
    var delegateController: Tab3ViewController!
    let minCarRegistrationYear = 2000
    
    var viewMode = ViewTypeMode.ViewMode
    var car = AMGUserCar(json: JSON.null)
    var indexCar = 0
    
    var validationResult: AMGValidationResult!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var vinCell: AMGTableViewCell!
    @IBOutlet var regnumCell: AMGTableViewCell!
    @IBOutlet var classCell: AMGTableViewCell!
    @IBOutlet var modelCell: AMGTableViewCell!
    @IBOutlet var yearCell: AMGTableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    
    @IBOutlet weak var vinTextField: UITextField!
    @IBOutlet weak var regnumTextField: UITextField!
    
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var regnumLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var vinSeparator: UIView!
    @IBOutlet weak var regnumSeparator: UIView!
    @IBOutlet weak var classSeparator: UIView!
    @IBOutlet weak var modelSeparator: UIView!
    @IBOutlet weak var yearSeparator: UIView!
    
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var classButton: UIButton!
    @IBOutlet weak var modelButton: UIButton!
    
    @IBOutlet weak var deleteCarButton: UIButton!
    @IBOutlet weak var doneCarButton: UIButton!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    
    var ignoreFakeVIN = false
    var ignoreSAPFakeVIN = false
    
    var vinIdentificationFinished = false
    
    var years: [String] = []
    var classes: [AMGObject] = []
    var models: [AMGObject] = []
    
    var selectedClass: AMGObject?
    var selectedModel: AMGObject?
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vinTextField.delegate = self
        regnumTextField.delegate = self
        
        self.titleLabel.text = "Добавить автомобиль"
        self.backButton.isHidden = true
        
        years = yearsArray()
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        if (viewMode == ViewTypeMode.ViewMode) {
            self.titleLabel.text = "Мой AMG"
            
            vinTextField.text = car.VIN
            regnumTextField.text = car.regNumber
            yearLabel.text = car.year
            classLabel.text = car.nClass
            modelLabel.text = car.nModel
            
            yearLabel.textColor = .black
            classLabel.textColor = .black
            modelLabel.textColor = .black
            
            selectedClass = AMGObject(json: JSON.null)
            selectedClass?.id = car.idClass
            selectedClass?.name = car.nClass
            
            selectedModel = AMGObject(json: JSON.null)
            selectedModel?.id = car.idModel
            selectedModel?.name = car.nModel
        }
        
        if (viewMode == ViewTypeMode.AddCarMode) {
            screenName = "my_car_create"
            deleteCarButton.isHidden = true
            doneButtonBottomConstraint.constant = 50
            doneCarButton.setTitle("Далее", for: .normal)
        }
        
        YMReport(message: screenName)
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
    
    @IBAction func doneButtonAction() {
        self.view.endEditing(true)
        
        if let object = selectedClass {
            car.idClass = object.id
            car.nClass = object.name
        }
        
        if let object = selectedModel {
            car.idModel = object.id
            car.nModel = object.name
        }
        
        for userCar in AMGUser.shared.registrationCars {
            if car.VIN == userCar.VIN && car.idSrv != userCar.idSrv {
                YMReport(message: screenName, parameters: ["warning":"vin_already_exists"])
                showAttention(message: "Автомобиль с таким VIN уже добавлен")
                return
            }
        }
        
        isValidForms(containsError: { containsError in
            if containsError {
                self.tableView.reloadData()
                return
            }
            
            self.car.VIN = self.vinTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.car.regNumber = self.regnumTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.car.year = self.yearLabel.text!
            
            if self.viewMode == .ViewMode {
                if (!self.ignoreFakeVIN) {
                    self.findCarInSAPAndCompareCarData()
                    return
                }
                
                self.validationResult = nil
                self.editCar()
            } else if self.viewMode == .AddCarMode {
                if (!self.vinIdentificationFinished && !self.ignoreFakeVIN) {
                    self.findCarInSAPAndTryFillFields()
                    return
                }
                
                self.addCar()
            }
        })
    }
    
    func findCarInSAPAndCompareCarData() {
        showHUD()
        AMGAutorizationManager().checkVIN(vin: car.VIN, success: { result in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                if result.userCar.idClass == 0 {
                    self.validationResult = nil
                    self.editCar()
                    return
                }
                
                if !(self.car.idModel == result.userCar.idModel && self.car.idClass == result.userCar.idClass) {
                    self.YMReport(message: self.screenName, parameters: ["warning":"vin_match_another_car"])
                    self.showAlertWithDoubleActions(title: "Внимание!", text: "Этому VIN соответствуют другие данные об автомобиле. Обновить данные на форме или сохранить имеющиеся?", title1: "Обновить", title2: "Сохранить" , completion: {
                        
                        self.validationResult = result
                        
                        let saveID = self.car.idSrv
                        self.car = result.userCar
                        self.car.idSrv = saveID
                        
                        self.selectedClass = AMGObject(json: JSON.null)
                        self.selectedClass?.id = self.car.idClass
                        self.selectedClass?.name = self.car.nClass
                        self.classLabel.text = self.car.nClass
                        self.classLabel.textColor = .black
                        
                        if !self.car.nModel.isEmpty {
                            self.selectedModel = AMGObject(json: JSON.null)
                            self.selectedModel?.id = self.car.idModel
                            self.selectedModel?.name = self.car.nModel
                            self.modelLabel.text = self.car.nModel
                            self.modelLabel.textColor = .black
                        }
                        
                        if !self.car.year.isEmpty && self.car.year != "0" {
                            self.yearLabel.text = self.car.year
                            self.yearLabel.textColor = .black
                        }
                    }, completion2: {
                        self.validationResult = nil
                        self.editCar()
                        return
                    })
                } else {
                    self.validationResult = result
                    self.editCar()
                    return
                }
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func findCarInSAPAndTryFillFields() {
        
        showHUD()
        AMGAutorizationManager().checkVIN(vin: car.VIN, success: { result in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                if result.userCar.idClass == 0 {
                    self.YMReport(message: self.screenName, parameters: ["warning":"vin_not_found"])
                    self.showAlertWithDoubleActions(title: "Внимание!", text: "К сожалению, введенный VIN не найден. Пожалуйста, проверьте и исправьте написание.\nЕсли VIN введен корректно, перейдите к следующему шагу и заполните информацию о вашем автомобиле.", title1: "Исправить VIN", title2: "Продолжить", completion: {
                        self.vinTextField.becomeFirstResponder()
                    }, completion2: {
                        self.vinIdentificationFinished = true
                        self.doneCarButton.setTitle("Готово", for: .normal)
                        self.tableView.reloadData()
                    })
                    
                    return
                }
                
                self.validationResult = result
                self.car = result.userCar
                
                self.selectedClass = AMGObject(json: JSON.null)
                self.selectedClass?.id = self.car.idClass
                self.selectedClass?.name = self.car.nClass
                self.classLabel.text = self.car.nClass
                self.classLabel.textColor = .black
                
                if !self.car.nModel.isEmpty {
                    self.selectedModel = AMGObject(json: JSON.null)
                    self.selectedModel?.id = self.car.idModel
                    self.selectedModel?.name = self.car.nModel
                    self.modelLabel.text = self.car.nModel
                    self.modelLabel.textColor = .black
                }
                
                if !self.car.year.isEmpty && self.car.year != "0" {
                    self.yearLabel.text = self.car.year
                    self.yearLabel.textColor = .black
                }
                
                self.vinIdentificationFinished = true
                self.doneCarButton.setTitle("Готово", for: .normal)
                self.tableView.reloadData()
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func editCar() {
        showHUD()
        
        AMGUserManager().updateUserCar(car: car, result: validationResult, success: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                AMGUser.shared.registrationCars[self.indexCar] = self.car
                AMGUser.shared.saveCurrentUser()
                
                self.delegateController.cars = AMGUser.shared.registrationCars
                self.delegateController.pageControl.numberOfPages = AMGUser.shared.registrationCars.count
                self.delegateController.carImages.removeAll()
                self.delegateController.tableView.reloadData()
                self.YMReport(message: self.screenName, parameters: ["action":"edit_car_successfully"])
                
                self.showAlert(WithTitle: "Внимание!", andMessage: "Данные об автомобиле успешно сохранены", completion: {
                    self.dismiss(animated: true, completion: {
                        if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            if let vc = tabbarController.selectedViewController as? TabItemViewController {
                                vc.fadeView.isHidden = true
                            }
                        }
                    })
                })
            }
        }, failure: { errorMessage in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["error":errorMessage])
                self.showAttention(message: errorMessage)
            }
        })
    }
    
    func addCar() {
        showHUD()
        
        AMGUserManager().addUserCar(car: car, result: validationResult, success: { id in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.car.idSrv = id
                AMGUser.shared.registrationCars.append(self.car)
                AMGUser.shared.saveCurrentUser()
                self.delegateController.cars = AMGUser.shared.registrationCars
                self.delegateController.tableView.reloadData()
                self.YMReport(message: self.screenName, parameters: ["action":"add_car_successfully"])
                self.dismiss(animated: true, completion: {
                    if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                        if let vc = tabbarController.selectedViewController as? TabItemViewController {
                            vc.fadeView.isHidden = true
                        }
                    }
                })
            }
        }, failure: { errorMessage in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["error":errorMessage])
                self.showAttention(message: errorMessage)
            }
        })
    }
    
    @IBAction func scanVINAction() {
        self.view.endEditing(true)
        
        YMReport(message: screenName, parameters: ["action":"recognize_vin"])
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let scanVC = CaptureVINViewController()
            scanVC.delegate = self
            scanVC.modalPresentationStyle = .overCurrentContext
            self.present(scanVC, animated: true)
        } else {
            YMReport(message: screenName, parameters: ["warning":"camera_unavialable"])
            showAttention(message: "Камера на данном устройстве не найдена. Сканирование VIN номера невозможно.")
        }
    }
    
    @IBAction func deleteCarButtonAction() {
    
        if AMGUser.shared.registrationCars.count == 1 {
            YMReport(message: screenName, parameters: ["warning":"at_least_one"])
            showAttention(message: "У Вас должен быть как минимум один автомобиль")
            return
        }
        
        if !CheckConnection() { return }
        
        showAlertWithDoubleActions(title: "Внимание!", text: "Вы действительно хотите удалить автомобиль?", title1: "Нет", title2: "Да", completion: {}, completion2: {
            
            self.showHUD()
            AMGUserManager().deleteUserCar(carID: self.car.idSrv, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    
                    AMGUser.shared.registrationCars = AMGUser.shared.registrationCars.filter({ $0.idSrv != self.car.idSrv })
                    AMGUser.shared.saveCurrentUser()
                    self.delegateController.cars = AMGUser.shared.registrationCars
                    self.delegateController.tableView.reloadData()
                    self.YMReport(message: self.screenName, parameters: ["action":"delete_car_successfully"])
                    self.dismiss(animated: true, completion: {
                        if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            if let vc = tabbarController.selectedViewController as? TabItemViewController {
                                vc.fadeView.isHidden = true
                            }
                        }
                    })
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["serverError":"deleteCar"])
                    self.showServerError()
                }
            })
        })
    }
    
    func isValidForms(containsError: @escaping (Bool)->()) {
        
        vinCell.isValidated = true
        yearCell.isValidated = true
        classCell.isValidated = true
        modelCell.isValidated = true
        regnumCell.isValidated = true
        
        if let vinText = vinTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if (vinText.isEmpty) {
                showAttention(message: "Пожалуйста, введите VIN номер автомобиля.")
                vinCell.setValidated(validated: false)
                containsError(true)
                return
            }
            
            if (vinText.count != 17) {
                YMReport(message: screenName, parameters: ["warning":"wrong_vin"])
                showAttention(message: "VIN введен некорректно.\nПроверьте правильность ввода.")
                vinCell.setValidated(validated: false)
                containsError(true)
                return
            }
            
            if !checkVinIsValid(vinString: vinText) && !ignoreFakeVIN {
                YMReport(message: screenName, parameters: ["warning":"wrong_vin"])
                showAlertWithDoubleActions(title: "Внимание!", text: "Возможно VIN номер введен неправильно", title1: "Исправить", title2: "Продолжить", completion: {
                    
                    self.vinTextField.becomeFirstResponder()
                }, completion2: {
                    self.ignoreFakeVIN = true
                    self.vinIdentificationFinished = true
                    self.doneCarButton.setTitle("Готово", for: .normal)
                    self.tableView.reloadData()
                })
                
                containsError(true)
                return
            }
        
            if viewMode == .AddCarMode && !vinIdentificationFinished {
                containsError(false)
                return
            }
            
            if let number = regnumTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                
                if (number.isEmpty) {
                    regnumCell.setValidated(validated: false)
                    YMReport(message: screenName, parameters: ["warning":"empty_fields"])
                    regnumLabel.text = "Укажите гос. номер"
                    tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                    showAttention(message: "Пожалуйста, укажите регистрационный номер автомобиля.\n\n * Формат номера А000АА00[0],\nможет содержать только \nцифры и буквы кириллицы")
                    containsError(true)
                    return
                }
                
                let testNumber = NSPredicate(format: "SELF MATCHES %@", "[АВЕКМНОРСТУХ][0-9]{3}[АВЕКМНОРСТУХ]{2}[0-9]{2}([0-9])?")
                if !(number.count > 7 && number.count < 10 && testNumber.evaluate(with: number)) {
                    regnumCell.setValidated(validated: false)
                    regnumLabel.text = "Гос. номер введен некорректно"
                    tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                    showAttention(message: "Регистрационный номер автомобиля введен некорректно.\n\n * Формат номера А000АА00[0],\nможет содержать только \nцифры и буквы кириллицы")
                    regnumTextField.becomeFirstResponder()
                    containsError(true)
                    return
                }
            }
            
            if (yearLabel.text == "Укажите год выпуска") {
                YMReport(message: screenName, parameters: ["warning":"empty_fields"])
                yearCell.setValidated(validated: false)
                tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
                containsError(true)
                return
            }
            
            if (classLabel.text == "Укажите класс" || selectedClass == nil) {
                YMReport(message: screenName, parameters: ["warning":"empty_fields"])
                classCell.setValidated(validated: false)
                tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
                showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
                containsError(true)
                return
            }
            
            if (modelLabel.text == "Укажите модель" || selectedModel == nil) {
                YMReport(message: screenName, parameters: ["warning":"empty_fields"])
                modelCell.setValidated(validated: false)
                tableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                showErrorWithTitle(title: "Внимание!", error: "Все поля обязательны для заполнения")
                containsError(true)
                return
            }
        }
        
        containsError(false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewMode == .AddCarMode && !vinIdentificationFinished { return 1 }
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            if vinCell.isValidated {
                return 48
            } else {
                return 98
            }
        case 1:
            if regnumCell.isValidated {
                return 48
            } else {
                return 98
            }
        case 2:
            return 32
        case 3:
            if yearCell.isValidated {
                return 48
            } else {
                return 98
            }
        case 4:
            if classCell.isValidated {
                return 48
            } else {
                return 98
            }
        case 5:
            if modelCell.isValidated {
                return 48
            } else {
                return 98
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            vinSeparator.setStatusSeparator(isValidated: vinCell.isValidated)
            return vinCell
        case 1:
            regnumSeparator.setStatusSeparator(isValidated: regnumCell.isValidated)
            return regnumCell
        case 2:
            return emptyCell
        case 3:
            yearSeparator.setStatusSeparator(isValidated: yearCell.isValidated)
            return yearCell
        case 4:
            classSeparator.setStatusSeparator(isValidated: classCell.isValidated)
            return classCell
        case 5:
            modelSeparator.setStatusSeparator(isValidated: modelCell.isValidated)
            return modelCell
        default:
            return UITableViewCell()
        }
    }
    
    func resetCarData() {
        validationResult = nil;
        car = AMGUserCar(json: JSON.null)
        
        yearCell.isValidated = true
        classCell.isValidated = true
        modelCell.isValidated = true
        regnumCell.isValidated = true
        
        regnumTextField.text = ""
        
        yearLabel.text = "Укажите год выпуска"
        yearLabel.textColor = UIColor(white: 0, alpha: 0.3)
        
        classLabel.text = "Укажите класс"
        classLabel.textColor = UIColor(white: 0, alpha: 0.3)
        
        modelLabel.text = "Укажите модель"
        modelLabel.textColor = UIColor(white: 0, alpha: 0.3)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == vinTextField && !vinIdentificationFinished {
            doneButtonAction()
        }
        
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
        
        if (textField == vinTextField) {
            ignoreFakeVIN = false
            ignoreSAPFakeVIN = false
            
            if viewMode == .AddCarMode && vinIdentificationFinished {
                vinIdentificationFinished = false
                ignoreFakeVIN = false
                resetCarData()
                doneCarButton.setTitle("Далее", for: .normal)
                tableView.reloadData()
            }
            
            if (string.count == 0) {
                return true
            }
            
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ") && prospectiveText.count <= 17
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == vinTextField && viewMode == .ViewMode && car.isSapResponsed()) {
            
            self.showAlertWithDoubleActions(title: "VIN изменить нельзя", text: "Вы можете добавить автомобиль с другим VIN", title1: "Добавить", title2: "Отмена", completion: {
                
                let autoVC = MyAutoViewController()
                autoVC.delegateController = self.delegateController
                autoVC.viewMode = ViewTypeMode.AddCarMode
                autoVC.modalPresentationStyle = .overCurrentContext
                self.present(autoVC, animated: true, completion: nil)
                
            }, completion2: {})
            
            return false
        }
        
        return true
    }
    
    @IBAction func yearsButtonAction() {
        pickerType = PickerType.YearsTypePicker
        loadPicker()
    }
    
    @IBAction func classButtonAction() {
        self.view.endEditing(true)
        
        if (viewMode == .AddCarMode && (validationResult?.sapResponse) != nil)  ||
            (viewMode == .ViewMode && car.isSapResponsed()) {
            
            showAlertWithDoubleActions(title: "Внимание!", text: "Данные о текущем автомобиле будут утеряны после смены класса автомобиля. Вы хотите изменить класс?", title1: "Изменить", title2: "Отмена", completion: {
                self.selectClassBlock()
            }, completion2: {})
        } else {
            selectClassBlock()
        }
    }
    
    func selectClassBlock() {
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
        self.view.endEditing(true)
        
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

//
//  ServiceOrderViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class ServiceOrderViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    let screenName = "service_order"
    
    var isServicePrice = false
    
    var showroom: AMGShowroom!
    var userCar: AMGUserCar!
    var comment = ""
    
    @IBOutlet weak var workTypeLabel: UILabel!
    @IBOutlet weak var workDateLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: MMFormPhoneTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var vinTextField: UITextField!
    @IBOutlet weak var regnumTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var workTypeCell: AMGTableViewCell!
    @IBOutlet var workDateCell: AMGTableViewCell!
    @IBOutlet var managerCell: AMGTableViewCell!
    
    @IBOutlet var yearCell: AMGTableViewCell!
    @IBOutlet var classCell: AMGTableViewCell!
    @IBOutlet var modelCell: AMGTableViewCell!
    @IBOutlet var lastNameCell: AMGTableViewCell!
    @IBOutlet var firstNameCell: AMGTableViewCell!
    @IBOutlet var middleNameCell: AMGTableViewCell!
    @IBOutlet var phoneCell: AMGTableViewCell!
    @IBOutlet var emailCell: AMGTableViewCell!
    @IBOutlet var vinCell: AMGTableViewCell!
    @IBOutlet var regnumCell: AMGTableViewCell!
    @IBOutlet var addressCell: AMGTableViewCell!
    
    @IBOutlet var nextCell: UITableViewCell!
    
    @IBOutlet weak var workTypeButton: UIButton!
    
    @IBOutlet weak var workTypeSeparator: UIView!
    @IBOutlet weak var workDateSeparator: UIView!
    @IBOutlet weak var managerSeparator: UIView!
    
    var selectedWorkType: AMGObject!
    var workTypes: [AMGObject] = []
    
    var shedules: [AMGServiceShedule] = []
    var selectedDate: Date!
    var selectedInterval: AMGServiceTimeInterval!
    var selectedTimeInterval = ""
    
    var managers: [AMGServiceManager] = []
    var selectedManager: AMGServiceManager!
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Заявка на сервис"
        
        yearLabel.text = userCar.year
        yearLabel.textColor = .black
        classLabel.text = userCar.nClass
        classLabel.textColor = .black
        modelLabel.text = userCar.nModel
        modelLabel.textColor = .black
        addressLabel.text = showroom.address
        
        if showroom.address == "" {
            addressNameLabel.text = "Дилер"
            addressLabel.text = showroom.name
        }
        
        lastNameTextField.text = AMGUser.shared.lastName
        firstNameTextField.text = AMGUser.shared.firstName
        middleNameTextField.text = AMGUser.shared.middleName
        phoneTextField.text = phoneTextField.formatPhone(String(AMGUser.shared.phone.suffix(10)))
        emailTextField.text = AMGUser.shared.email
        vinTextField.text = userCar.VIN
        regnumTextField.text = userCar.regNumber
        
        shedules = getAllAvialableDates()
        
        if isServicePrice {
            bChangedFormData = true
            selectedWorkType = AMGObject(json: JSON.null)
            if let workType = workTypes.filter({ $0.name == "Техническое обслуживание" }).first {
                selectedWorkType.id = workType.id
                selectedWorkType.name = workType.name
            }
            workTypeLabel.text = selectedWorkType.name
            workTypeLabel.textColor = .black
            workTypeButton.isEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    override func backButtonAction(sender: UIButton) {
        if isServicePrice {
            dismiss(animated: true, completion: nil)
            return
        }
        
        super.backButtonAction(sender: sender)
    }
    
    @IBAction func sendServiceOrder() {
        
        YMReport(message: screenName, parameters: ["action":"send"])
        
        if !CheckConnection() {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connection"])
            return
        }
        
        if !isValidForms() {
            tableView.reloadData()
            return
        }
        
        tableView.reloadData()
        
        let order = AMGServiceOrder()
        
        order.lastName = AMGUser.shared.lastName
        order.firstName = AMGUser.shared.firstName
        order.middleName = AMGUser.shared.middleName
        order.phone = AMGUser.shared.phone
        order.email = AMGUser.shared.email
        
        if AMGUser.shared.gender == Gender.Female.rawValue { order.gender = 1 }
        else { order.gender = 0 }
        
        order.userCarId = userCar.idSrv
        order.classSysName = userCar.nClass
        order.carModel = userCar.nModel
        order.carYearRelease = userCar.year
        order.carVin = userCar.VIN
        order.carRegNumber = userCar.regNumber
        
        order.showRoomId = showroom.id
        order.dateTime = Date()
        if let date = selectedDate, let interval = selectedInterval {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: date)
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            order.dateTime = formatter.date(from: "\(dateString) \(interval.intervalFrom)") ?? Date()
        }
        
        order.serviceTypeId = selectedWorkType.id
        order.serviceName = selectedWorkType.name
        
        order.comment = ""
        if isServicePrice { order.comment = self.comment }
        
        if managers.count > 0 || shedules.count > 0 {
            order.toType = managers.count == 0 ? 1 : 2
        } else {
            order.toType = 0
        }
    
        if let managerID = Int(selectedManager.managerID) {
            order.dealerConsultantId = managerID
        }
        
        showAlertWithDoubleActions(title: "Подтверждение отправки заявки", text: "Заявка с Вашими контактными данными будет отправлена дилеру", title1: "Да", title2: "Отмена", completion: {
            
            self.showHUD()
            AMGDataManager().sendServiceOrder(car: self.userCar, order: order, success: {
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
    
    func getAllAvialableDates() -> [AMGServiceShedule] {
        
        var unionShedule: [AMGServiceShedule] = []
        
        for manager in self.managers {
            for schedule in manager.shedules {
                if !unionShedule.contains(where: { $0.date == schedule.date }) {
                    if schedule.numberOfFreeIntervals() > 0 {
                        unionShedule.append(schedule)
                    }
                }
            }
        }
        
        return unionShedule
    }
    
    func filteredManagersBySelectedDate() -> [AMGServiceManager] {
        var filteredManagers: [AMGServiceManager] = []
        
        for manager in managers {
            for schedule in manager.shedules {
                if schedule.date == selectedDate {
                    for interval in schedule.timeIntervals {
                        if interval.intervalAsString == selectedTimeInterval && interval.isFree {
                            filteredManagers.append(manager)
                        }
                    }
                }
            }
        }
    
        return filteredManagers
    }
    
    func isValidForms() -> Bool {
        
        workTypeCell.isValidated = true
        workDateCell.isValidated = true
        managerCell.isValidated = true
        
        if (workTypeLabel.text == "Укажите вид работ" || selectedWorkType == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            workTypeCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (workDateLabel.text == "Выберите дату работ" || selectedDate == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            workDateCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (managerLabel.text == "Выберите менеджера" || selectedManager == nil) {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            managerCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 6
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if workTypeCell.isValidated { return 48 }
                return 98
            case 1:
                if workDateCell.isValidated { return 48 }
                return 98
            case 2:
                if managerCell.isValidated { return 48 }
                return 98
            default:
                return 0
            }
        case 1:
            return 48
        case 2:
            return 48
        case 3:
            return 48
        case 4:
            return 140
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                workTypeSeparator.setStatusSeparator(isValidated: workTypeCell.isValidated)
                return workTypeCell
            }
            if indexPath.row == 1 {
                workDateSeparator.setStatusSeparator(isValidated: workDateCell.isValidated)
                return workDateCell
            }
            if indexPath.row == 2 {
                managerSeparator.setStatusSeparator(isValidated: managerCell.isValidated)
                return managerCell
            }
        case 1:
            if indexPath.row == 0 { return yearCell }
            if indexPath.row == 1 { return classCell }
            if indexPath.row == 2 { return modelCell }
        case 2:
            if indexPath.row == 0 { return lastNameCell }
            if indexPath.row == 1 { return firstNameCell }
            if indexPath.row == 2 { return phoneCell }
            if indexPath.row == 3 { return emailCell }
            if indexPath.row == 4 { return vinCell }
            if indexPath.row == 5 { return regnumCell }
        case 3:
            return addressCell
        case 4:
            return nextCell
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 && showroom.address == "" { return 0.0001 }
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    @IBAction func workTypeButtonAction() {
        pickerType = PickerType.WorkTypePicker
        loadPicker()
    }
    
    @IBAction func workDateButtonAction() {
        let dateVC = CalendarViewController()
        dateVC.delegate = self
        dateVC.shedules = self.shedules
        dateVC.modalPresentationStyle = .overCurrentContext
        self.present(dateVC, animated: true, completion: nil)
    }
    
    @IBAction func managerButtonAction() {
        let managerVC = SelectManagerViewController()
        managerVC.delegate = self
        if selectedDate == nil {
            managerVC.managers = managers
        } else {
            managerVC.managers = filteredManagersBySelectedDate()
        }
        managerVC.modalPresentationStyle = .overCurrentContext
        self.present(managerVC, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerType {
        case PickerType.WorkTypePicker:
            return workTypes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerType {
        case PickerType.WorkTypePicker:
            return workTypes[row].name
        default:
            return ""
        }
    }
    
    @objc func donePickerAction() {
        
        bChangedFormData = true
        
        switch pickerType {
        case PickerType.WorkTypePicker:
            workTypeCell.setValidated(validated: true)
            selectedWorkType = workTypes[pickerView.selectedRow(inComponent: 0)]
            workTypeLabel.text = selectedWorkType?.name
            workTypeLabel.textColor = .black
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

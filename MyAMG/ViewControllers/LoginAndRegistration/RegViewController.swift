//
//  RegViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegViewController: InnerViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var screenName = "registration_personal_data"
    
    var editDataMode = false
    
    @IBOutlet weak var vinTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var phoneTextField: MMFormPhoneTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pass1TextField: UITextField!
    @IBOutlet weak var pass2TextField: UITextField!
    @IBOutlet weak var oldPassTextField: UITextField!
    
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var oldPassLabel: UILabel!
    
    @IBOutlet weak var vinSeparator: UIView!
    @IBOutlet weak var lastNameSeparator: UIView!
    @IBOutlet weak var firstNameSeparator: UIView!
    @IBOutlet weak var middleNameSeparator: UIView!
    @IBOutlet weak var phoneSeparator: UIView!
    @IBOutlet weak var emailSeparator: UIView!
    @IBOutlet weak var pass1Separator: UIView!
    @IBOutlet weak var pass2Separator: UIView!
    @IBOutlet weak var oldPassSeparator: UIView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var vinScanButton: UIButton!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var vinCell: AMGTableViewCell!
    @IBOutlet var genderCell: AMGTableViewCell!
    @IBOutlet var lastNameCell: AMGTableViewCell!
    @IBOutlet var firstNameCell: AMGTableViewCell!
    @IBOutlet var middleNameCell: AMGTableViewCell!
    @IBOutlet var ageCell: AMGTableViewCell!
    @IBOutlet var phoneCell: AMGTableViewCell!
    @IBOutlet var emailCell: AMGTableViewCell!
    @IBOutlet var passCell: AMGTableViewCell!
    @IBOutlet var oldPassCell: AMGTableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    @IBOutlet var nextCell: UITableViewCell!
    
    var userCar = AMGUserCar(json: JSON.null)
    var validationResult: AMGValidationResult!
    
    var ignorePhoneCheck = false
    var ignoreFakeVIN = false
    var ignoreSAPFakeVIN = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.isHidden = true
        titleLabel.text = "Регистрация"
        
        vinTextField.delegate = self
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
        middleNameTextField.delegate = self
        ageTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        oldPassTextField.delegate = self
        pass1TextField.delegate = self
        pass2TextField.delegate = self
        
        if (editDataMode) {
            screenName = "my_personal_data"
            backButton.isHidden = false
            titleLabel.text = "Мои данные"
            
            lastNameTextField.text = AMGUser.shared.lastName
            firstNameTextField.text = AMGUser.shared.firstName
            middleNameTextField.text = AMGUser.shared.middleName
            phoneTextField.text = phoneTextField.formatPhone(String(AMGUser.shared.phone.suffix(10)))
            emailTextField.text = AMGUser.shared.email
            
            emailTextField.isEnabled = false
            
            if (AMGUser.shared.salutation.lowercased() == "господин") {
                segmented.selectedSegmentIndex = 0
            } else {
                segmented.selectedSegmentIndex = 1
            }
            
            nextButton.setTitle("Сохранить изменения", for: .normal)
        }
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        segmented.layer.cornerRadius = 0
        segmented.layer.borderWidth = 0;
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:10)!,NSAttributedString.Key.foregroundColor:UIColor.black], for: .normal)
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:11)!,NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmented.removeBorders()
        
        YMReport(message: screenName)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        bChangedFormData = true
        
        if (textField == ageTextField) {
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.count <= 2
        }
        
        if (textField == vinTextField) {
            ignoreFakeVIN = false
            ignoreSAPFakeVIN = false
            
            if (string.count == 0) {
                return true
            }
            
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ") && prospectiveText.count <= 17
        }
        
        if (textField == firstNameTextField || textField == middleNameTextField || textField == lastNameTextField) {
            
            if (string.count == 0) {
                return true
            }
            
            let regex = "[^а-яА-ЯёЁ -]+"
            if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: string) {
                showAttention(message: "Пожалуйста, переключите клавиатуру на русский язык.")
                return false
            } else {
                return true
            }
        }
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (editDataMode) {
            if (textField == lastNameTextField) {
                firstNameTextField.becomeFirstResponder()
            } else if (textField == firstNameTextField) {
                middleNameTextField.becomeFirstResponder()
            } else if (textField == middleNameTextField) {
                phoneTextField.becomeFirstResponder()
            } else if (textField == phoneTextField) {
                oldPassTextField.becomeFirstResponder()
            } else if (textField == oldPassTextField) {
                pass1TextField.becomeFirstResponder()
            } else if (textField == pass1TextField) {
                pass2TextField.becomeFirstResponder()
            } else if (textField == pass2TextField) {
                self.view.endEditing(true);
                nextButtonAction()
            }
        } else {
            if (textField == vinTextField) {
                lastNameTextField.becomeFirstResponder()
            } else if (textField == lastNameTextField) {
                firstNameTextField.becomeFirstResponder()
            } else if (textField == firstNameTextField) {
                middleNameTextField.becomeFirstResponder()
            } else if (textField == middleNameTextField) {
                ageTextField.becomeFirstResponder()
            } else if (textField == ageTextField) {
                phoneTextField.becomeFirstResponder()
            } else if (textField == phoneTextField) {
                emailTextField.becomeFirstResponder()
            } else if (textField == emailTextField) {
                pass1TextField.becomeFirstResponder()
            } else if (textField == pass1TextField) {
                pass2TextField.becomeFirstResponder()
            } else if (textField == pass2TextField) {
                self.view.endEditing(true);
                nextButtonAction()
            }
        }
        
        return true
    }
    
    @IBAction func nextButtonAction() {
        
        self.YMReport(message: self.screenName, parameters: ["action":"next"])
        
        if (!CheckConnection()) { return }
        
        if (!isValidForms()) {
            tableView.reloadData()
            return
        }
        
        tableView.reloadData()
        
        AMGUser.shared.lastName = self.lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        AMGUser.shared.firstName = self.firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        AMGUser.shared.middleName = self.middleNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        AMGUser.shared.phone = self.phoneTextField.getPhone()
        AMGUser.shared.email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (segmented.selectedSegmentIndex == 0) {
            AMGUser.shared.gender = Gender.Male.rawValue
            AMGUser.shared.salutation = self.segmented.titleForSegment(at: 0)!
        } else if (segmented.selectedSegmentIndex == 1) {
            AMGUser.shared.gender = Gender.Female.rawValue
            AMGUser.shared.salutation = self.segmented.titleForSegment(at: 1)!
        }
        
        if (self.editDataMode) {
            let oldPassword = self.oldPassTextField.text
            let newPassword = self.pass1TextField.text
            
            if (self.bChangedFormData) {
                showHUD()
                AMGUserManager().updateUserData(oldPassword: oldPassword, newPassword: newPassword, success: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        if (oldPassword != "" && newPassword != "") {
                            AMGSettings.shared.biometricsText = newPassword!
                        }
                        AMGSettings.shared.biometricsLogin = AMGUser.shared.email
                        AMGSettings.shared.saveSettings()
                        AMGUser.shared.saveCurrentUser()
                        self.showAlert(WithTitle: "Внимание!", andMessage: "Личные данные успешно сохранены", completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                }, failure: { message in
                    OperationQueue.main.addOperation {
                        AMGUser.shared.loadCurrentUser()
                        self.hideHUD()
                        self.showAttention(message: message)
                    }
                })
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        if let age = Int(ageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            AMGUser.shared.age = age
        }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = self.phoneTextField.getPhone()
        
        showHUD()
        AMGAutorizationManager().checkUserWithEmail(email, success: { isRegistered in
            self.hideHUD()
            
            if !isRegistered {
                self.showHUD()
                AMGAutorizationManager().checkUserWithPhone(phone, success: { isPhoneUses in
                    self.hideHUD()
                    
                    if !isPhoneUses {
                        if self.validationResult == nil {
                            if !self.ignoreSAPFakeVIN {
                                self.showHUD()
                                AMGAutorizationManager().checkVIN(vin: self.vinTextField.text!, success: { result in
                                    self.hideHUD()
                                    self.validationResult = result
                                    self.nextStepOfRegistration()
                                }, failure: {
                                    self.hideHUD()
                                    self.nextStepOfRegistration()
                                })
                            } else {
                                self.ignoreSAPFakeVIN = true
                                self.nextStepOfRegistration()
                            }
                        } else {
                            self.nextStepOfRegistration()
                        }
                    } else {
                        self.YMReport(message: self.screenName, parameters: ["warning":"phone_in_use"])
                        OperationQueue.main.addOperation {
                            self.showAttention(message: "Номер \(phone) уже закреплен за другим пользователем!")
                        }
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.showServerError()
                    }
                })
            } else {
                self.YMReport(message: self.screenName, parameters: ["warning":"email_in_use"])
                OperationQueue.main.addOperation {
                    self.showAlertWithYesAndNo(title: "Email уже используется!", text: "Вы проходили регистрацию раньше? Тогда Вам следует авторизоваться", title1: "Ввести другой email", title2: "Авторизоваться", completion: {
                        self.emailTextField.becomeFirstResponder()
                    }, completion2: {
                        let loginVC = LoginViewController()
                        loginVC.modalPresentationStyle = .overCurrentContext
                        self.present(loginVC, animated: true, completion: nil)
                    })
                }
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func nextStepOfRegistration() {
        OperationQueue.main.addOperation {
            if self.validationResult.isVinValid || self.ignoreSAPFakeVIN {
                AMGUser.shared.lastName = self.lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                AMGUser.shared.firstName = self.firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                AMGUser.shared.middleName = self.middleNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                AMGUser.shared.phone = self.phoneTextField.getPhone()
                AMGUser.shared.email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                AMGUser.shared.password = self.pass1TextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.userCar.VIN = self.vinTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                AMGUser.shared.registrationCars.append(self.userCar)
                
                let regVC = RegAutoViewController()
                regVC.validationResult = self.validationResult
                regVC.modalPresentationStyle = .overCurrentContext
                self.present(regVC, animated: true, completion: nil)
            } else {
                self.YMReport(message: self.screenName, parameters: ["warning":"vin_not_found"])
                self.showAlertWithDoubleActions(title: "Внимание!", text: "К сожалению, введенный VIN не найден. Пожалуйста, проверьте и исправьте написание.\nЕсли VIN введен корректно, перейдите к следующему шагу и заполните информацию о вашем автомобиле.", title1: "Исправить", title2: "Продолжить", completion: {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top
                        , animated: true)
                    self.vinTextField.becomeFirstResponder()
                }, completion2: {
                    self.ignoreSAPFakeVIN = true
                    self.validationResult.sapResponse = nil
                    self.nextButtonAction()
                })
            }
        }
    }
    
    @IBAction func scanVINAction() {
        self.view.endEditing(true)
        
        self.YMReport(message: self.screenName, parameters: ["action":"recognize_vin"])
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let scanVC = CaptureVINViewController()
            scanVC.delegate = self
            scanVC.modalPresentationStyle = .overCurrentContext
            self.present(scanVC, animated: true)
        } else {
            showAttention(message: "Камера на данном устройстве не найдена. Сканирование VIN номера невозможно.")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if editDataMode { return 10 }
        return 11
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (editDataMode) {
            switch indexPath.row {
            case 0:
                return 85
            case 1:
                if (lastNameCell.isValidated) {
                    return 48
                }
                return 98
            case 2:
                if (firstNameCell.isValidated) {
                    return 48
                }
                return 98
            case 3:
                if (middleNameCell.isValidated) {
                    return 48
                }
                return 98
            case 4:
                if (phoneCell.isValidated) {
                    return 48
                }
                return 98
            case 5:
                if (emailCell.isValidated) {
                    return 48
                }
                return 98
            case 6:
                return 14
            case 7:
                if (oldPassCell.isValidated) {
                    return 48
                }
                return 98
            case 8:
                if (passCell.isValidated) {
                    return 96
                }
                return 136
            case 9:
                return 100
            default:
                return 0
            }
        }
        
        switch indexPath.row {
        case 0:
            return 100
        case 1:
            return 85
        case 2:
            if (lastNameCell.isValidated) {
                return 48
            }
            return 98
        case 3:
            if (firstNameCell.isValidated) {
                return 48
            }
            return 98
        case 4:
            if (middleNameCell.isValidated) {
                return 48
            }
            return 98
        case 5:
            return 98
        case 6:
            if (phoneCell.isValidated) {
                return 48
            }
            return 98
        case 7:
            if (emailCell.isValidated) {
                return 48
            }
            return 98
        case 8:
            return 14
        case 9:
            if (passCell.isValidated) {
                return 96
            }
            return 136
        case 10:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (editDataMode) {
            switch indexPath.row {
            case 0:
                return genderCell
            case 1:
                lastNameSeparator.setStatusSeparator(isValidated: lastNameCell.isValidated)
                return lastNameCell
            case 2:
                firstNameSeparator.setStatusSeparator(isValidated: firstNameCell.isValidated)
                return firstNameCell
            case 3:
                middleNameSeparator.setStatusSeparator(isValidated: middleNameCell.isValidated)
                return middleNameCell
            case 4:
                phoneSeparator.setStatusSeparator(isValidated: phoneCell.isValidated)
                return phoneCell
            case 5:
                emailSeparator.setStatusSeparator(isValidated: emailCell.isValidated)
                return emailCell
            case 6:
                return emptyCell
            case 7:
                oldPassSeparator.setStatusSeparator(isValidated: oldPassCell.isValidated)
                return oldPassCell
            case 8:
                pass1Separator.setStatusSeparator(isValidated: passCell.isValidated)
                pass2Separator.setStatusSeparator(isValidated: passCell.isValidated)
                return passCell
            default:
                return nextCell
            }
        }
        
        switch indexPath.row {
        case 0:
            vinSeparator.setStatusSeparator(isValidated: vinCell.isValidated)
            if (vinCell.isValidated) {
                vinLabel.textColor = UIColor(white: 140/255, alpha: 1)
            } else {
                vinLabel.textColor = .red
            }
            return vinCell
        case 1:
            return genderCell
        case 2:
            lastNameSeparator.setStatusSeparator(isValidated: lastNameCell.isValidated)
            return lastNameCell
        case 3:
            firstNameSeparator.setStatusSeparator(isValidated: firstNameCell.isValidated)
            return firstNameCell
        case 4:
            middleNameSeparator.setStatusSeparator(isValidated: middleNameCell.isValidated)
            return middleNameCell
        case 5:
            return ageCell
        case 6:
            phoneSeparator.setStatusSeparator(isValidated: phoneCell.isValidated)
            return phoneCell
        case 7:
            emailSeparator.setStatusSeparator(isValidated: emailCell.isValidated)
            return emailCell
        case 8:
            return emptyCell
        case 9:
            pass1Separator.setStatusSeparator(isValidated: passCell.isValidated)
            pass2Separator.setStatusSeparator(isValidated: passCell.isValidated)
            return passCell
        default:
            return nextCell
        }
    }
    
    @IBAction func eyeButtonAction(sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            YMReport(message: screenName, parameters: ["action":"show_password"])
            pass1TextField.isSecureTextEntry = false
            pass2TextField.isSecureTextEntry = false
            oldPassTextField.isSecureTextEntry = false
            sender.setImage(UIImage(named: "eyeOpened"), for: .normal)
        } else if sender.tag == 1 {
            sender.tag = 0
            YMReport(message: screenName, parameters: ["action":"hide_password"])
            pass1TextField.isSecureTextEntry = true
            pass2TextField.isSecureTextEntry = true
            oldPassTextField.isSecureTextEntry = true
            sender.setImage(UIImage(named: "eyeClosed"), for: .normal)
        }
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
    
    func isValidForms() -> Bool {
        
        self.view.endEditing(true);
        
        vinCell.isValidated = true
        lastNameCell.isValidated = true
        firstNameCell.isValidated = true
        middleNameCell.isValidated = true
        phoneCell.isValidated = true
        emailCell.isValidated = true
        passCell.isValidated = true
        oldPassCell.isValidated = true
        
        if let vinText = vinTextField.text, editDataMode == false {
            if (vinText.count != 17) {
                vinCell.setValidated(validated: false)
                showErrorAlert(WithTitle: "Внимание!", andMessage: "VIN введен некорректно.\nПроверьте правильность ввода.", completion: {
                    if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                })
                return false
            }
            
            if (!checkVinIsValid(vinString: vinText) && !ignoreFakeVIN) {
                self.YMReport(message: self.screenName, parameters: ["warning":"wrong_vin"])
                self.showAlertWithDoubleActions(title: "Внимание!", text: "Возможно VIN введен неправильно", title1: "Исправить", title2: "Продолжить", completion: {
                    self.vinCell.setValidated(validated: false)
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.vinTextField.becomeFirstResponder()
                }, completion2: {
                    self.ignoreFakeVIN = true
                    self.nextButtonAction()
                })
                return false
            }
        }
        
        if (lastNameTextField == nil || lastNameTextField.text == "") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            lastNameCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 2 {
                    self.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (firstNameTextField == nil || firstNameTextField.text == "") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            firstNameCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 3 {
                    self.tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (middleNameTextField == nil || middleNameTextField.text == "") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            middleNameCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 4 {
                    self.tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (phoneTextField == nil || phoneTextField.text == "") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            phoneCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 6 {
                    self.tableView.scrollToRow(at: IndexPath(row: 6, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (emailTextField == nil || emailTextField.text == "") {
            YMReport(message: screenName, parameters: ["warning":"empty_fields"])
            emailCell.setValidated(validated: false)
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Все поля обязательны для заполнения", completion: {
                if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 7 {
                    self.tableView.scrollToRow(at: IndexPath(row: 7, section: 0), at: .top, animated: true)
                }
            })
            return false
        }
        
        if (!phoneTextField.isPhoneValid && !ignorePhoneCheck) {
            YMReport(message: screenName, parameters: ["warning":"wrong_phone"])
            showAlertWithDoubleActions(title: "Внимание!", text: "Возможно телефонный номер введен неправильно", title1: "Исправить", title2: "Продолжить", completion: { () -> (Void) in
                self.phoneCell.setValidated(validated: false)
                self.phoneLabel.text = "Телефон введен неправильно"
                self.phoneTextField.becomeFirstResponder()
            }, completion2: { () -> (Void) in
                self.ignorePhoneCheck = true
                self.nextButtonAction()
            })
            return false
        }

        if (!validEmail(emailString: emailTextField.text)) {
            YMReport(message: screenName, parameters: ["warning":"wrong_email"])
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Email адрес введен неправильно", completion: {
                self.emailCell.setValidated(validated: false)
                self.emailLabel.text = "Email введен неправильно"
                self.emailTextField.becomeFirstResponder()
            })
            return false
        }
    
        if (editDataMode && (oldPassTextField.text != "" || pass1TextField.text != "" || pass2TextField.text != "")) {
            if (oldPassTextField.text == "") {
                oldPassLabel.text = "Укажите старый пароль"
                oldPassCell.setValidated(validated: false)
                showAttention(message: "Для смены пароля необходимо указать старый (действующий) пароль.")
                return false
            }
            
            if (pass1TextField.text == "" && pass2TextField.text == "") {
                passLabel.text = "Пароль не может быть пустым"
                passCell.setValidated(validated: false)
                showErrorAlert(WithTitle: "Внимание!", andMessage: passLabel.text!, completion: {})
                return false
            } else if (pass1TextField.text != pass2TextField.text) {
                passLabel.text = "Пароли не совпадают"
                passCell.setValidated(validated: false)
                showErrorAlert(WithTitle: "Внимание!", andMessage: passLabel.text!, completion: {})
                return false
            }
        }
        
        if (!editDataMode) {
            if (pass1TextField.text == "" && pass2TextField.text == "") {
                passLabel.text = "Пароль не может быть пустым"
                passCell.setValidated(validated: false)
                showErrorAlert(WithTitle: "Внимание!", andMessage: passLabel.text!, completion: {})
                return false
            } else if (pass1TextField.text != pass2TextField.text) {
                passLabel.text = "Пароли не совпадают"
                passCell.setValidated(validated: false)
                showErrorAlert(WithTitle: "Внимание!", andMessage: passLabel.text!, completion: {})
                return false
            }
        }
        
        if (segmented.selectedSegmentIndex < 0) {
            askUserForGender(WithMaleCompletion: {
                AMGUser.shared.gender = Gender.Male.rawValue
                AMGUser.shared.salutation = self.segmented.titleForSegment(at: 0)!
                self.segmented.selectedSegmentIndex = 0
                self.nextButtonAction()
            }, WithFemaleCompletion: {
                AMGUser.shared.gender = Gender.Female.rawValue
                AMGUser.shared.salutation = self.segmented.titleForSegment(at: 1)!
                self.segmented.selectedSegmentIndex = 1
                self.nextButtonAction()
            })
        } else if (segmented.selectedSegmentIndex == 0) {
            AMGUser.shared.gender = Gender.Male.rawValue
            AMGUser.shared.salutation = self.segmented.titleForSegment(at: 0)!
        } else if (segmented.selectedSegmentIndex == 1) {
            AMGUser.shared.gender = Gender.Female.rawValue
            AMGUser.shared.salutation = self.segmented.titleForSegment(at: 1)!
        }
        
        return true
    }
    
    @IBAction func segmentedChangedValue() {
        bChangedFormData = true
    }
}

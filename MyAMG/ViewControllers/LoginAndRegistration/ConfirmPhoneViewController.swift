//
//  ConfirmPhoneViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 14/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConfirmPhoneViewController: InnerViewController, UITextFieldDelegate {

    let screenName = "registration_last_step"
    
    var validationResult: AMGValidationResult!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeSeparator: UIView!
    
    @IBOutlet weak var confirmButtonBottomConstraint: NSLayoutConstraint!
    
    var time = 0
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        backButton.isHidden = true
        titleLabel.text = "Подтверждение регистрации"
        bChangedFormData = true
        
        codeTextField.delegate = self
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        activateTimer()
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
            
        if (self.screenHeight > 600) {
            confirmButtonBottomConstraint.constant = kbSize.height + 70
        } else {
            confirmButtonBottomConstraint.constant = kbSize.height + 25
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        confirmButtonBottomConstraint.constant = 110;
    }
    
    @IBAction func confirmButtonAction(sender: UIButton) {
        hideKeyboard()
        
        if (isValidCode()) {
            showHUD()
            APIWrapper().srvUserRegister(smsCode: codeTextField.text!, result: validationResult, success: { response in
                OperationQueue.main.addOperation {
                    self.YMReport(message: self.screenName, parameters: ["action":"registration_successful"])
                    
                    self.hideHUD()
                    guard let data = response, let json = try? JSON(data: data) else { return }
                    
                    self.showAlert(WithTitle: "Благодарим за регистрацию!", andMessage: "Теперь Вам доступны все возможности приложения \"My AMG\"", completion: {
                        AMGUser.shared.userUUID = json["Guid"].stringValue
                        AMGUser.shared.isRegistered = true
                        AMGUser.shared.saveCurrentUser()
                        
                        let helloVC = HelloVideoViewController()
                        helloVC.modalPresentationStyle = .overCurrentContext
                        self.present(helloVC, animated: true)
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
    }
    
    @IBAction func requestButtonAction(sender: UIButton) {
        hideKeyboard()
        
        showHUD()
        API_WRAPPER.srvGetSMSCode(forUser: AMGUser.shared.userUUID, phone: AMGUser.shared.phone, success: { data in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.activateTimer()
                self.showAlertWithTitle(title: "Внимание!", text: "На указанный номер телефона отправлен по SMS проверочный код")
            }
        }, failure: { error in
            OperationQueue.main.addOperation {
                self.hideHUD()
                if let message = error?.localizedDescription {
                    self.showAttention(message: message)
                } else {
                    self.showServerError()
                }
                
            }
        })
        
    }
    
    func isValidCode() -> Bool {
        
        if (codeTextField.text == "") {
            showErrorWithTitle(title: "Внимание!", error: "Пожалуйста, введите код из SMS")
            return false
        }
        
        return true
    }
    
    func activateTimer() {
        
        codeSeparator.setStatusSeparator(isValidated: true)
        codeLabel.text = ""
        codeLabel.textColor = UIColor(white: 140/255, alpha: 1)
        
        requestButton.isHidden = true
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        time = 179
        timer = Timer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func stopTimer() {
        
        if (timer.isValid) {
            timer.invalidate()
            timer = nil;
        
            time = 0
            requestButton.isHidden = false
            
            codeSeparator.setStatusSeparator(isValidated: false)
            codeLabel.text = "Срок действия кода истек"
            codeLabel.textColor = .red
        }
    }
    
    @objc func updateTime() {
    
        if (time == 0) {
            stopTimer()
            return
        }
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .full
        formatter.calendar = calendar
        let formattedString = formatter.string(from: TimeInterval(time))!
        
        codeLabel.text = "Истекает через \(formattedString)"
        codeSeparator.setStatusSeparator(isValidated: true)
        codeLabel.textColor = UIColor(white: 140/255, alpha: 1)
        
        time -= 1
    }

}

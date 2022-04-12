//
//  DeleteUserViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 25/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class DeleteUserViewController: InnerViewController, UITextFieldDelegate {

    let screenName = "delete_profile"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwTextField: UITextField!
    
    @IBOutlet weak var deleteButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Удаление профиля"
        
        emailTextField.delegate = self
        passwTextField.delegate = self
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
        
        if (self.screenHeight > 600) {
            let info = notification.userInfo! as NSDictionary
            let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
            
            deleteButtonBottomConstraint.constant = kbSize.height + 50
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        deleteButtonBottomConstraint.constant = 50;
    }
    
    @IBAction func deleteButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        YMReport(message: screenName, parameters: ["action":"delete_profile"])
        
        if let email = emailTextField.text, let password = passwTextField.text {
            showHUD()
            AMGAutorizationManager().deleteUserWithLogin(login: email, password: password, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    
                    self.YMReport(message: self.screenName, parameters: ["action":"delete_successful"])
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    AMGUser.shared.removeCurrentUser()
                    
                    AMGSettings.shared.biometricsOn = false
                    AMGSettings.shared.biometricsLogin = ""
                    AMGSettings.shared.biometricsText = ""
                    AMGSettings.shared.saveSettings()
                    
                    AMGNews.shared.removeNews()
                    
                    AMGUser.shared.logoutForRegisteredUser()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        bChangedFormData = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            passwTextField.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }


}

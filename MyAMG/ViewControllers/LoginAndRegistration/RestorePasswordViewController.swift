//
//  RestorePasswordViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class RestorePasswordViewController: InnerViewController, UITextFieldDelegate {

    let screenName = "remind"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var restoreButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        titleLabel.text = "Восстановление пароля"
        
        emailTextField.delegate = self
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        bChangedFormData = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @IBAction func restoreButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        showHUD()
        AMGAutorizationManager().remindPasswordWith(email: emailTextField.text!, success: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["action":"reminded_successfully"])
                self.showAlert(WithTitle: "Внимание!", andMessage: "Пароль выслан на Вашу электронную почту", completion: {
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                })
            }
        }, failure: { message in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["error":message])
                self.showAttention(message: message)
            }
        })
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        if (self.screenHeight > 600) {
            let info = notification.userInfo! as NSDictionary
            let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
            
            restoreButtonBottomConstraint.constant = kbSize.height + 20
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        restoreButtonBottomConstraint.constant = 50;
    }

}

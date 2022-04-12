//
//  LoginViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: InnerViewController, UITextFieldDelegate {

    let screenName = "authorization"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        backButton.isHidden = true
        titleLabel.text = "Войти"
        
        emailTextField.delegate = self
        passwTextField.delegate = self
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AMGSettings.shared.biometricsOn {
            if AMGSettings.shared.isTouchIDAvialable() || AMGSettings.shared.isFaceIDAvialable() {
                authorizeUserWithBiometrics()
            }
        }
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
            passwTextField.becomeFirstResponder()
        } else {
            loginButtonAction(sender: loginButton)
        }
        
        return true
    }
    
    @IBAction func loginButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        YMReport(message: screenName, parameters: ["action":"login"])
        
        if let email = emailTextField.text, let password = passwTextField.text {
            showHUD()
            AMGAutorizationManager().authorizeUserWithLogin(login: email, password: password, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    
                    self.YMReport(message: self.screenName, parameters: ["action":"logged_sucessfully"])
                    
                    AMGUser.shared.isRegistered = true
                    AMGUser.shared.saveCurrentUser()
                    
                    AMGSettings.shared.biometricsLogin = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    AMGSettings.shared.biometricsText = password.trimmingCharacters(in: .whitespacesAndNewlines)
                    AMGSettings.shared.saveSettings()
                    
                    if AMGUser.shared.email != AMGUser.testAccount {
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        AMGUser.shared.loginForRegisteredUser()
                    } else {
                        let helloVC = HelloVideoViewController()
                        helloVC.modalPresentationStyle = .overCurrentContext
                        self.present(helloVC, animated: true)
                    }
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
    
    @IBAction func restoreButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        YMReport(message: screenName, parameters: ["action":"remind"])
        
        let restoreVC = RestorePasswordViewController()
        restoreVC.modalPresentationStyle = .overCurrentContext
        self.present(restoreVC, animated: true, completion: nil)
    }
    
    @IBAction func eyeButtonAction(sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            YMReport(message: screenName, parameters: ["action":"show_password"])
            passwTextField.isSecureTextEntry = false
            sender.setImage(UIImage(named: "eyeOpened"), for: .normal)
        } else if sender.tag == 1 {
            sender.tag = 0
            YMReport(message: screenName, parameters: ["action":"hide_password"])
            passwTextField.isSecureTextEntry = true
            sender.setImage(UIImage(named: "eyeClosed"), for: .normal)
        }
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        if (self.screenHeight > 600) {
            let info = notification.userInfo! as NSDictionary
            let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
            
            loginButtonBottomConstraint.constant = kbSize.height + 70
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        loginButtonBottomConstraint.constant = 110;
    }
    
    func authorizeUserWithBiometrics() {
        
        YMReport(message: screenName, parameters: ["action":"login"])
        
        var authError: NSError?
        let context = LAContext()
        
        let login = AMGSettings.shared.biometricsLogin
        let text = AMGSettings.shared.biometricsText
        
        let myLocalizedReasonString = "Пройдите авторизацию для зарегистрированного пользователя \(login)"
        
        if #available(iOS 11.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString, reply: { success, error in
                    
                    if (success) {
                        OperationQueue.main.addOperation {
                            self.showHUD()
                            AMGAutorizationManager().authorizeUserWithLogin(login: login, password: text, success: {
                                OperationQueue.main.addOperation {
                                    self.hideHUD()
                                    
                                    self.YMReport(message: self.screenName, parameters: ["action":"logged_sucessfully"])
                                    
                                    AMGUser.shared.isRegistered = true
                                    AMGUser.shared.saveCurrentUser()
                                    
                                    if AMGUser.shared.email != AMGUser.testAccount {
                                        self.view.window!.rootViewController?.dismiss(animated: false)
                                        AMGUser.shared.loginForRegisteredUser()
                                    } else {
                                        let helloVC = HelloVideoViewController()
                                        helloVC.modalPresentationStyle = .overCurrentContext
                                        self.present(helloVC, animated: true)
                                    }
                                }
                            }, failure: { errorMessage in
                                OperationQueue.main.addOperation {
                                    self.hideHUD()
                                    self.YMReport(message: self.screenName, parameters: ["error":errorMessage])
                                    self.showAttention(message: errorMessage)
                                }
                            })
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            self.emailTextField.becomeFirstResponder()
                        }
                    }
                })
            }
        }
    }
}

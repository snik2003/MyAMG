//
//  InnerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import YandexMobileMetrica

class InnerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var confirmOnlineServicesLabel: UILabel!
    
    var firstAppear = true
    
    var screenHeight: CGFloat = 0
    var screenWidth: CGFloat = 0
    
    var bChangedFormData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if let label = titleLabel {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
        }
        
        if let view = mainView {
            view.isUserInteractionEnabled = true
        }
        
        if let label = confirmOnlineServicesLabel {
            let fullString = label.text
            let coloredString = "онлайн-сервисов"
            let range = (fullString! as NSString).range(of: coloredString)
            
            let attributedString = NSMutableAttributedString(string:fullString!)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: range)
            label.attributedText = attributedString
            
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openOnlineServicesTerms)))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        if (bChangedFormData) {
            showAlertWithDoubleActions(title: "Внимание!", text: "Ваши изменения не будут сохранены.\nВы уверены, что хотите выйти?", title1: "Нет", title2: "Да", completion: {}, completion2: {
                
                if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    if let vc = tabbarController.selectedViewController as? TabItemViewController {
                        vc.fadeView.isHidden = true
                    }
                }
                
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            })
        } else {
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                if let vc = tabbarController.selectedViewController as? TabItemViewController {
                    vc.fadeView.isHidden = true
                }
            }
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func backButtonAction(sender: UIButton) {
        self.view.endEditing(true);
        
        if (bChangedFormData) {
            showAlertWithDoubleActions(title: "Внимание!", text: "Ваши изменения не будут сохранены.\nВы уверены, что хотите выйти?", title1: "Нет", title2: "Да", completion: {}, completion2: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openOnlineServicesTerms() {
        let vc = AgreementViewController()
        vc.type = .AgreementOnlineServices
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true);
    }
    
    func CheckConnection() -> Bool {
        if (!Reachability.shared.isConnectedToNetwork()) {
            showErrorAlert(WithTitle: "Внимание!", andMessage: "Отсутствует подключение к сети", completion: {})
            return false
        }
        return true
    }
    
    func CheckConnectionWithoutAlert() -> Bool {
        if (!Reachability.shared.isConnectedToNetwork()) {
            return false
        }
        return true
    }
    
    func showHUD() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func hideHUD() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().hideActivityIndicator()
        
            if (UIApplication.shared.isIgnoringInteractionEvents) {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func showAlert(WithTitle title: String, andMessage text: String, completion:@escaping ()->(Void)) {
    
        let alertVC = AMGAlertController()
        
        alertVC.typeAlert = TypeAlert.AlertWithTitleAndMessage
        alertVC.header = title
        alertVC.message = text
        
        alertVC.customActionCompletion = {}
        alertVC.cancelActionCompletion = {}
        alertVC.okActionCompletion = completion
        
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }

    func showErrorAlert(WithTitle title: String, andMessage text: String, completion:@escaping ()->(Void)) {
        
        let alertVC = AMGAlertController()
        
        alertVC.typeAlert = TypeAlert.AlertWithErrorMessage
        alertVC.header = title
        alertVC.message = text
        
        alertVC.customActionCompletion = {}
        alertVC.cancelActionCompletion = completion
        alertVC.okActionCompletion = {}
        
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertWithYesAndNo(title: String, text: String, title1: String, title2: String, completion:@escaping ()->(Void), completion2:@escaping ()->(Void)) {
        
        let alertVC = AMGAlertController()
    
        alertVC.typeAlert = TypeAlert.AlertWithYesAndNo;
        
        alertVC.header = title;
        alertVC.message = text;
        
        alertVC.customActionCompletion = {};
        
        alertVC.okActionCompletion = completion;
        alertVC.okActionName = title1;
        
        alertVC.cancelActionCompletion = completion2;
        alertVC.cancelActionName = title2;
        
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showAlertWithDoubleActions(title: String, text: String, title1: String, title2: String, completion:@escaping ()->(Void), completion2:@escaping ()->(Void)) {
        
        let alertVC = AMGAlertController()
        
        alertVC.typeAlert = TypeAlert.AlertWithDoubleActions;
        
        alertVC.header = title;
        alertVC.message = text;
        
        alertVC.action1Completion = completion;
        alertVC.action1Name = title1;
        
        alertVC.action2Completion = completion2;
        alertVC.action2Name = title2;
        
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showAttention(message: String, completion:@escaping ()->(Void)) {
        
        showErrorAlert(WithTitle: "Внимание!", andMessage: message, completion: completion)
    }
    
    func showAlertWithTitle(title: String, text: String) {
        
        showAlert(WithTitle: title, andMessage: text, completion: {})
    }
    
    func showErrorWithTitle(title: String, error: String) {
        
        showErrorAlert(WithTitle: title, andMessage: error, completion: {})
    }
    
    func showAttention(message: String) {
    
        showErrorAlert(WithTitle: "Внимание!", andMessage: message, completion: {})
    }

    func showEmptyFieldMsg(message: String) {
        
        showErrorWithTitle(title: "Поле не заполнено", error: message);
    }
    
    func showError(error: String) {
        
        showErrorWithTitle(title: "Ошибка!", error: error);
    }
    
    func showServerError() {
        showErrorWithTitle(title: "Внимание!", error: "Ошибка при обращении к серверу. Попробуйте повторить позже.")
    }
    
    func askUserForGender(WithMaleCompletion completion:@escaping ()->(), WithFemaleCompletion completion2:@escaping ()->()) {
        
        showAlertWithDoubleActions(title: "Внимание!", text: "Пожалуйста, укажите форму обращения", title1: "Господин", title2: "Госпожа", completion: completion, completion2: completion2)
    }
    
    func validEmail(emailString: String?) -> Bool {
        if let email = emailString, email.count == 0  {
            return false
        }
    
        let regExPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExPattern)
        if (!emailTest.evaluate(with: emailString)) {
            return false
        }
        
        return true
    }
    
    func validPhone(phoneString:String?) -> Bool {
        if let phone = phoneString {
            var phoneNumStr = phone.trimmingCharacters(in: .whitespacesAndNewlines)
            phoneNumStr = phoneNumStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            
            if (phoneNumStr.count < 10 || phoneNumStr.count > 14) {
                return false
            }
            
            return true
        }
        
        return false
    }
    
    func showTelPromptWithString(phone: String) {
        let cleanedString = phone.components(separatedBy: CharacterSet(charactersIn: "0123456789-+()").inverted).joined(separator: "")
        if let escapedPhoneNumber = cleanedString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let str = "telprompt://".appending(escapedPhoneNumber)
            if let phoneLink = URL(string: str) {
                UIApplication.shared.open(phoneLink, options: [:], completionHandler: nil)
            }
        }
    }
    
    func checkVinIsValid(vinString: String) -> Bool {
    
        let defaultPrefixes = ["3AM", "3MB", "4JG", "5DH", "8AB", "8AC", "9BM", "ADB", "KPA", "KPD", "KPG", "LB1", "LE4", "LEN", "MEC", "MHL", "NAB", "NMB", "RLM", "TAW", "TCC", "VAG", "VF9", "VS9", "VSA", "WCD", "WD0", "WD1", "WD2", "WD3", "WD4", "WD5", "WD6", "WD7", "WD8", "WD9", "WDA", "WDB", "WDC", "WDD", "WDF", "WDP", "WDR", "WDW", "WDX", "WDY", "WDZ", "WEB", "WKK", "WME", "WMX", "XDN", "Z9M"];
    
        let vinStr = vinString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (vinStr.count == 0) {
            return false
        }
        
        if (vinStr.count != 17) {
            return false
        }
    
        let start = vinStr.index(vinStr.startIndex, offsetBy: 3)
        let end = vinStr.index(start, offsetBy: 6)
        let range = start..<end
        
        let onlyNumbersPart = vinStr[range]
        if (onlyNumbersPart.rangeOfCharacter(from: .decimalDigits) == nil) {
            return false
        }
        
        let vinPrefix = vinStr.prefix(3).uppercased()
        if (!defaultPrefixes.contains(vinPrefix)) {
            return false
        }
    
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let data = image.pngData()!
        return data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func convertBase64toImage(string: String) -> UIImage? {
        if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func priceToString(priceString: String) -> String {
        
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        
        if let fPrice = Double(priceString), let price = numFormatter.string(from: NSNumber(value: fPrice)) {
            return "\(price) ₽"
        }
        
        return "\(priceString) ₽"
    }
    
    func YMReport(message: String) {
        YMMYandexMetrica.reportEvent(message, onFailure: { _ in })
    }
    
    func YMReport(message: String, parameters: [String: Any]?) {
        
        if parameters != nil {
            YMMYandexMetrica.reportEvent(message, parameters: parameters, onFailure: { _ in })
        } else {
            YMReport(message: message)
        }
    }
    
    func YMReportError(message: String, except: NSException?, onFailure failure: @escaping (Error?)->()) {
        
        YMMYandexMetrica.reportError(message, exception: except, onFailure: { error in
            failure(error)
        })
    }
}

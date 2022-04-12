//
//  ConsentViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 24/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class ConsentViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "advirtising_communications_agreement"
    
    var validationResult: AMGValidationResult!
    
    var isViewMode = false
    
    @IBOutlet weak var text1Label: UILabel!
    @IBOutlet weak var text2Label: UILabel!
    @IBOutlet weak var nextButton: AMGButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var phoneSwitch: UISwitch!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var smsSwitch: UISwitch!
    
    @IBOutlet var phoneCell: UITableViewCell!
    @IBOutlet var emailCell: UITableViewCell!
    @IBOutlet var smsCell: UITableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YMReport(message: screenName)
        
        bChangedFormData = true
        titleLabel.text = "Согласие"
        
        if isViewMode {
            bChangedFormData = false
            titleLabel.text = "Варианты коммуникации"
            
            nextButton.isHidden = true
            text2Label.isHidden = true
            
            text1Label.text = "Вы дали своё разрешение на следующие варианты связи и получения рекламной информации"
            phoneSwitch.isOn = AMGUserConsent.shared.agreePhone
            phoneSwitch.isEnabled = false
            
            emailSwitch.isOn = AMGUserConsent.shared.agreeEmail
            emailSwitch.isEnabled = false
            
            smsSwitch.isOn = AMGUserConsent.shared.agreeSMS
            smsSwitch.isEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if screenHeight < 600 {
            nextButtonBottomConstraint.constant = 80
            tableViewTopConstraint.constant = 10
            subtitleTopConstraint.constant = 10
        }
    }
    
    @IBAction func nextButtonAction() {
        showHUD()
        
        YMReport(message: screenName, parameters: ["action":"next"])
        
        AMGUser.shared.phoneConsent = phoneSwitch.isOn
        AMGUser.shared.emailConsent = emailSwitch.isOn
        AMGUser.shared.smsConsent = smsSwitch.isOn
        
        AMGAutorizationManager().getSMSCode(success: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showAlert(WithTitle: "Внимание!", andMessage: "На указанный номер телефона отправлен по SMS проверочный код", completion: {
                    let regVC = ConfirmPhoneViewController()
                    regVC.validationResult = self.validationResult
                    regVC.modalPresentationStyle = .overCurrentContext
                    self.present(regVC, animated: true, completion: nil)
                })
            }
        }, failure: { errorMessage in
            OperationQueue.main.addOperation {
                self.hideHUD()
                var errMess = errorMessage.replacingOccurrences(of: "[Message:\":\"", with: "")
                errMess = errMess.replacingOccurrences(of: "\"}", with: "")
                self.YMReport(message: self.screenName, parameters: ["error":errMess])
                self.showAttention(message: errMess)
            }
        })
    }
    
    @IBAction func moreButtonAction() {
        let agreeVC = AgreementViewController()
        agreeVC.type = .AgreementConsentAdvertisement
        agreeVC.modalPresentationStyle = .overCurrentContext
        self.present(agreeVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 1
        }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return phoneCell
        case 1:
            return emailCell
        case 2:
            return smsCell
        default:
            return emptyCell
        }
    }
}

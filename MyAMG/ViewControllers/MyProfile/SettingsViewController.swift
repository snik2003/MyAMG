//
//  SettingsViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class SettingsViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "settings"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var biometricSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBOutlet weak var biometricTitleLabel: UILabel!
    @IBOutlet weak var biometricTextLabel: UILabel!
    
    @IBOutlet var pushCell: UITableViewCell!
    @IBOutlet var textCell: UITableViewCell!
    @IBOutlet var biometricCell: UITableViewCell!
    @IBOutlet var text2Cell: UITableViewCell!
    @IBOutlet var soundCell: UITableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Настройки"
        
        pushSwitch.isOn = AMGSettings.shared.pushOn
        soundSwitch.isOn = AMGSettings.shared.soundOn
        
        if (AMGSettings.shared.isTouchIDAvialable()) {
            biometricSwitch.isOn = AMGSettings.shared.biometricsOn
            biometricTitleLabel.text = "Вход по TouchID"
            biometricTextLabel.text = "Активируйте опцию для авторизации в приложении с помощью TouchID"
        } else if (AMGSettings.shared.isFaceIDAvialable()) {
            biometricSwitch.isOn = AMGSettings.shared.biometricsOn
            biometricTitleLabel.text = "Вход по FaceID"
            biometricTextLabel.text = "Активируйте опцию для авторизации в приложении с помощью FaceID"
        } else {
            biometricCell.isHidden = true
            text2Cell.isHidden = true
        }
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        if (sender == pushSwitch) {
            YMReport(message: screenName, parameters: ["action":"switch_push"])
            AMGSettings.shared.pushOn = sender.isOn
            
            if sender.isOn {
                AMGPushConfigurator.defaultConfigurator.registerForPushNotifications()
            } else {
                AMGPushConfigurator.defaultConfigurator.unregisterdForPushNotification()
            }
        } else if (sender == soundSwitch) {
            YMReport(message: screenName, parameters: ["action":"switch_sound"])
            AMGSettings.shared.soundOn = sender.isOn
        } else if (sender == biometricSwitch) {
            if sender.isOn {
                YMReport(message: screenName, parameters: ["action":"switch_biometrics_on"])
                AMGSettings.shared.biometricsOn = sender.isOn
            } else {
                YMReport(message: screenName, parameters: ["action":"switch_biometrics_off"])
                AMGSettings.shared.removeBiometricsSettings()
            }
        }
        
        AMGSettings.shared.saveSettings()
    }
    
    @IBAction func deleteProfileAction() {
        showAlertWithDoubleActions(title: "Внимание!", text: "Профиль текущего пользователя будет удален без возможности восстановления. Вы действительно хотите удалить свой профиль?", title1: "Нет", title2: "Да", completion: {}, completion2: {
            
            self.YMReport(message: self.screenName, parameters: ["action":"delete_profile"])
            
            let deleteVC = DeleteUserViewController()
            deleteVC.modalPresentationStyle = .overCurrentContext
            self.present(deleteVC, animated: true, completion: nil)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 2 || indexPath.row == 3 {
            if !AMGSettings.shared.isTouchIDAvialable() && !AMGSettings.shared.isFaceIDAvialable() { return 0 }
        }
        
        if indexPath.row == 1 || indexPath.row == 3 { return 56 }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return pushCell
        case 1:
            return textCell
        case 2:
            return biometricCell
        case 3:
            return text2Cell
        case 4:
            return soundCell
        default:
            return emptyCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

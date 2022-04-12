//
//  ProfileMasterViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class ProfileMasterViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "profile"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var myDataCell: UITableViewCell!
    @IBOutlet var aboutAppCell: UITableViewCell!
    @IBOutlet var eulaCell: UITableViewCell!
    @IBOutlet var settingsCell: UITableViewCell!
    @IBOutlet var consentCell: UITableViewCell!
    @IBOutlet var logoutCell: UITableViewCell!
    @IBOutlet var myDealerCell: UITableViewCell!
    @IBOutlet var emptyCell: UITableViewCell!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        backButton.isHidden = true
        titleLabel.text = "Профиль"
        nameLabel.text = "\(AMGUser.shared.lastName) \(AMGUser.shared.firstName)"
    }

    @IBAction func editProfileAction() {
        YMReport(message: screenName, parameters: ["action":"edit_my_data"])
        
        let regVC = RegViewController()
        regVC.editDataMode = true
        regVC.modalPresentationStyle = .overCurrentContext
        self.present(regVC, animated: true, completion: nil)
    }
    
    @IBAction func aboutAppAction() {
        YMReport(message: screenName, parameters: ["action":"about_app"])
        
        let agreeVC = AgreementViewController()
        agreeVC.modalPresentationStyle = .overCurrentContext
        self.present(agreeVC, animated: true, completion: nil)
    }
    
    @IBAction func eulaAction() {
        YMReport(message: screenName, parameters: ["action":"read_eula"])
        
        let appVC = AboutAppViewController()
        appVC.modalPresentationStyle = .overCurrentContext
        self.present(appVC, animated: true, completion: nil)
    }
    
    @IBAction func settingsAction() {
        YMReport(message: screenName, parameters: ["action":"settings"])
        
        let setVC = SettingsViewController()
        setVC.modalPresentationStyle = .overCurrentContext
        self.present(setVC, animated: true, completion: nil)
    }
    
    @IBAction func changeDealerAction() {
        YMReport(message: screenName, parameters: ["action":"change_my_dealer"])
        
        let dealerVC = ChangeDealerViewController()
        dealerVC.isForProfile = true
        dealerVC.modalPresentationStyle = .overCurrentContext
        self.present(dealerVC, animated: true, completion: nil)
    }
    
    @IBAction func consentButtonAction() {
        let consentVC = ConsentViewController()
        consentVC.isViewMode = true
        consentVC.modalPresentationStyle = .overCurrentContext
        self.present(consentVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutAction() {
        
        showAlertWithDoubleActions(title: "Выход из аккаунта", text: "При выходе все настройки будут сброшены. Позже Вы сможете вернуться в аккаунт с сохраненными настройками. Вы действительно хотите выйти из аккаунта?", title1: "Да", title2: "Нет", completion: {
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            self.YMReport(message: self.screenName, parameters: ["action":"logout_successfully"])
            
            AMGUser.shared.isRegistered = false
            AMGUser.shared.saveCurrentUser()
            AMGNews.shared.removeNews()
            AMGUser.shared.logoutForRegisteredUser()
        }, completion2: {})
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 4:
            return 20
        case 7:
            //if AMGUser.isOnlyForTest && AMGUser.shared.email == AMGUser.testAccount && AMGUserConsent.shared.isSuccess { return 48 }
            return 48
        case 8:
            return 20
        default:
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return myDataCell
        case 1:
            return myDealerCell
        case 2:
            return settingsCell
        case 3:
            return logoutCell
        case 5:
            return aboutAppCell
        case 6:
            return eulaCell
        case 7:
            //if AMGUser.isOnlyForTest && AMGUser.shared.email == AMGUser.testAccount && AMGUserConsent.shared.isSuccess { return consentCell }
            return consentCell //emptyCell
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

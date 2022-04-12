//
//  AMGUser.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Gender: Int {
    case Undefined = 0
    case Male = 1
    case Female = 2
}

final class AMGUser: Codable {
    
    static let shared = AMGUser(json: JSON.null)
    
    static let testAccount = "pks@test.com"
    static let isOnlyForTest = true
    
    static let testYMApiKey = "2711723b-e96d-4198-9400-7f6a2a60ac32"
    static let prodYMApiKey = "42c8d672-47dc-434f-8440-b4f540348b31"
    
    var userUUID = ""
    var salutation = ""
    var gender = Gender.Undefined.rawValue
    var lastName = ""
    var firstName = ""
    var middleName = ""
    var phone = ""
    var email = ""
    var token = ""
    var password = ""
    var isRegistered = false
    var dealerId = 0
    var dealerName = ""
    var dealerCityId = 0
    var dealerCityName = ""
    var isInSaleNewCars = false
    var isInSaleUsedCars = false
    var isDealerStoa = false
    var defaultDeviceToken = "dd5d5e24f6680ee1d1c30ac50b138e9e256d57f47fe018cb5d9cf617cd9fafe1"
    var phoneConsent = false
    var emailConsent = false
    var smsConsent = false
    var age = 0
    
    var registrationCars: [AMGUserCar] = []
    
    init(json: JSON) {
        self.firstName = json["FirstName"].stringValue
        self.lastName = json["LastName"].stringValue
        self.middleName = json["MiddleName"].stringValue
        self.email = json["Email"].stringValue
        self.phone = json["Phone"].stringValue
        self.salutation = json["Salutation"].stringValue
        self.gender = json["Gender"].intValue
        self.userUUID = json["Guid"].stringValue
        self.dealerId = json["DealerId"].intValue
        self.dealerName = json["DealerName"].stringValue
        self.dealerCityId = json["DealerCityId"].intValue
        self.dealerCityName = json["DealerCityName"].stringValue
        
        if (self.salutation.lowercased() == "господин") {
            self.gender = Gender.Male.rawValue
        } else {
            self.gender = Gender.Female.rawValue
        }
        
        self.registrationCars = []
    }
    
    func printLocal() {
        #if DEBUG
        print("Обращение: \(self.salutation)")
        print("Фамилия: \(self.lastName)")
        print("Имя: \(self.firstName)")
        print("Отчество: \(self.middleName)")
        print("Телефон: \(self.phone)")
        print("Email: \(self.email)")
        print("Пароль: \(self.password)")
        print("Город: \(self.dealerCityName)")
        print("Дилер: \(self.dealerName)")
        #endif
    }
    
    func setUser(user: AMGUser) {
        self.userUUID = user.userUUID
        self.salutation = user.salutation
        self.gender = user.gender
        self.lastName = user.lastName
        self.firstName = user.firstName
        self.middleName = user.middleName
        self.phone = user.phone
        self.email = user.email
        self.token = user.token
        self.password = user.password
        self.isRegistered = user.isRegistered
        self.dealerId = user.dealerId
        self.dealerName = user.dealerName
        self.dealerCityId = user.dealerCityId
        self.dealerCityName = user.dealerCityName
        self.isInSaleNewCars = user.isInSaleNewCars
        self.isInSaleUsedCars = user.isInSaleUsedCars
        self.isDealerStoa = user.isDealerStoa
        
        self.registrationCars = user.registrationCars
        
        if !AMGUser.shared.hasToken() {
            AMGUser.shared.token = AMGUser.shared.defaultDeviceToken
        }
    }
    
    func clearPersonalData() {
        self.lastName = ""
        self.firstName = ""
        self.middleName = ""
        self.phone = ""
        self.email = ""
        self.password = ""
    }
    
    func hasGuid() -> Bool {
        
        return (self.userUUID.count >= 32);
    }
    
    func hasToken() -> Bool {
        
        return (self.token.count > 0);
    }
    
    func saveCurrentUser() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(AMGUser.shared) {
            UserDefaults.standard.set(encoded, forKey: "CurrentUser")
        }
    }
    
    func loadCurrentUser() {
        if let data = UserDefaults.standard.object(forKey: "CurrentUser") as? Data {
            let decoder = JSONDecoder()
            if let currentUser = try? decoder.decode(AMGUser.self, from: data) {
                AMGUser.shared.setUser(user: currentUser)
            }
        }
    }
    
    func removeCurrentUser() {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
        UserDefaults.standard.synchronize()
    }
    
    func loginForRegisteredUser() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = UIApplication.shared.keyWindow
        
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabbarController") as? HomeTabbarController {
            
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window?.rootViewController = tabBarController
                window?.makeKeyAndVisible()
            }, completion: nil)
        }
    }
    
    func logoutForRegisteredUser() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = UIApplication.shared.keyWindow
        
        if let startViewController  = storyboard.instantiateViewController(withIdentifier: "StartViewController") as? StartViewController, let navController = storyboard.instantiateViewController(withIdentifier: "StartNavigationController") as? UINavigationController {
            
            navController.setViewControllers([startViewController], animated: false)
            startViewController.playVideo = false
            
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
                window?.rootViewController = navController
                window?.makeKeyAndVisible()
            }, completion: nil)
            
            
        }
    }
}

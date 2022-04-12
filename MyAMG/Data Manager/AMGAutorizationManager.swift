//
//  AMGAutorizationManager.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGAutorizationManager {
    
    var tokenSent = false
    
    let serverErrorMessage = "Ошибка при обращении к серверу. Попробуйте повторить позже"
    
    func launch() {
        
        if !AMGUser.shared.hasToken() {
            AMGUser.shared.token = AMGUser.shared.defaultDeviceToken
        }
        
        if !AMGUser.shared.hasGuid() {
            API_WRAPPER.srvGetGUID({ data in
                if var guid = String(data: data!, encoding: String.Encoding.utf8) {
                    guid = guid.replacingOccurrences(of: "\"", with: "")
                    if (guid.count > 0) {
                        AMGUser.shared.userUUID = guid
                    }
                }
            }, failure: { _ in })
        }
    }
    
    func checkUserWithEmail(_ email: String, success: @escaping (Bool)->(), failure: @escaping ()->()) {
        API_WRAPPER.srvCheckUser(withEmail: email, success: { response in
            if let data = response, let result = String(data: data, encoding: String.Encoding.utf8) {
                if result == "false" { success(true); return }
            }
            success(false)
        }, failure: { _ in failure() })
    }
    
    func checkUserWithPhone(_ phone: String, success: @escaping (Bool)->(), failure: @escaping ()->()) {
        API_WRAPPER.srvCheckUser(withPhone: phone, success: { response in
            if let data = response, let result = String(data: data, encoding: String.Encoding.utf8) {
                if result == "false" { success(true); return }
            }
            success(false)
        }, failure: { _ in failure() })
    }
    
    func checkVIN(vin: String, success: @escaping (AMGValidationResult)->(), failure: @escaping ()->()) {
        
        let parameters = [
            "FirstName": AMGUser.shared.firstName,
            "MiddleName": AMGUser.shared.middleName,
            "LastName": AMGUser.shared.lastName,
            "Phone": AMGUser.shared.phone,
            "Email": AMGUser.shared.email,
            "Vin": vin
        ]
        
        API_WRAPPER.srvValidateRegistration(parameters, success: { response in
            if let data = response, let json = try? JSON(data: data) {
                //print(json)
                let result = AMGValidationResult(json: json)
                success(result)
                return
            }
            failure()
        }, failure: { _ in
            failure()
        })
    }
    
    func remindPasswordWith(email: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        let login = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if login.count == 0 {
            failure("Введите Email, на который будет выслан пароль.")
            return
        }
        
        API_WRAPPER.srvRemindUserPassword(withLogin: login, success: { response in
            if let data = response, let result = String(data: data, encoding: String.Encoding.utf8) {
                if result == "true" { success(); return }
            }
            failure("Email не существует.\nПроверьте правильность ввода данных")
        }, failure: { _ in
            failure(self.serverErrorMessage)
        })
    }
    
    func getSMSCode(success: @escaping ()->(), failure: @escaping (String)->()) {
        
        API_WRAPPER.srvGetSMSCode(forUser: AMGUser.shared.userUUID, phone: AMGUser.shared.phone, success: { _ in
            success()
        }, failure: { error in
            if let message = error?.localizedDescription {
                failure(message)
            } else {
                failure(self.serverErrorMessage)
            }
        })
        
    }
    func authorizeUserWithLogin(login: String, password: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        let login = login.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (login.count == 0 || password.count == 0) {
            failure("Не указан email/пароль.\nВведите данные")
            return
        }
        
        API_WRAPPER.srvAuthorizeUser(withLogin: login, password: password, token: AMGUser.shared.token, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure("Неверный email/пароль.\nПроверьте правильность ввода данных.")
                return
            }
            
            let newUser = AMGUser(json: json["XAppUser"])
            AMGUser.shared.setUser(user: newUser)
            
            let newUserCars = json["XUserCars"].compactMap { AMGUserCar(json: $0.1) }
            AMGUser.shared.registrationCars = newUserCars
            
            AMGSettings.shared.pushOn = json["XAppUser"]["IsPushEnabled"].boolValue
            AMGSettings.shared.saveSettings()
            
            let newCarsIds = json["FavouritesNewCars"].arrayValue.map({ $0.intValue })
            let usedCarsIds = json["FavouritesUsedCars"].arrayValue.map({ $0.intValue })
            
            AMGDataManager().readUserFavouriteCars(newCarIds: newCarsIds, usedCarIds: usedCarsIds, success: { newCars, usedCars in
                
                AMGFavouriteCars.shared.newCars = newCars
                AMGFavouriteCars.shared.usedCars = usedCars
                
                success()
            }, failure: {
                failure(self.serverErrorMessage)
            })
        }, failure: { _ in
            failure(self.serverErrorMessage)
        })
    }
    
    func deleteUserWithLogin(login: String, password: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        let login = login.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (login.count == 0 || password.count == 0) {
            failure("Не указан email/пароль.\nВведите данные")
            return
        }
        
        API_WRAPPER.srvAuthorizeUser(withLogin: login, password: password, token: AMGUser.shared.token, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure("Неверный email/пароль.\nПроверьте правильность ввода данных.")
                return
            }
            
            let deleteUser = AMGUser(json: json["XAppUser"])
            API_WRAPPER.srvDeleteUser(withId: deleteUser.userUUID, success: { _ in
                success()
            }, failure: { _ in
                failure(self.serverErrorMessage)
            })
        }, failure: { _ in
            failure(self.serverErrorMessage)
        })
    }
}

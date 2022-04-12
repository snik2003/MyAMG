//
//  AMGUserManager.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGUserManager {
    
    let serverErrorMessage = "Ошибка при обращении к серверу. Попробуйте повторить позже"
    
    func getUserData(success: @escaping ()->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetUserData(AMGUser.shared.userUUID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let newUser = AMGUser(json: json["XAppUser"])
            AMGUser.shared.setUser(user: newUser)
            let newUserCars = json["XUserCars"].compactMap { AMGUserCar(json: $0.1) }
            AMGUser.shared.registrationCars = newUserCars
            AMGUser.shared.isRegistered = true
            AMGUser.shared.saveCurrentUser()
            
            AMGSettings.shared.pushOn = json["XAppUser"]["IsPushEnabled"].boolValue
            AMGSettings.shared.saveSettings()
            
            let newCarsIds = json["FavouritesNewCars"].arrayValue.map({ $0.intValue })
            let usedCarsIds = json["FavouritesUsedCars"].arrayValue.map({ $0.intValue })
            
            AMGDataManager().readUserFavouriteCars(newCarIds: newCarsIds, usedCarIds: usedCarsIds, success: { newCars, usedCars in
                
                AMGFavouriteCars.shared.newCars = newCars
                AMGFavouriteCars.shared.usedCars = usedCars
                
                success()
            }, failure: {
                failure()
            })
        }, failure: { _ in
            failure()
        })
    }
    
    
    
    func updateUserData(oldPassword: String?, newPassword: String?, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        var parameters = [
            "Salutation": AMGUser.shared.salutation,
            "Gender": AMGUser.shared.gender,
            "FirstName": AMGUser.shared.firstName,
            "MiddleName": AMGUser.shared.middleName,
            "LastName": AMGUser.shared.lastName,
            "Phone": AMGUser.shared.phone,
            "Email": AMGUser.shared.email,
            "DealerCityId": AMGUser.shared.dealerCityId,
            "DealerCityName": AMGUser.shared.dealerCityName,
            ] as [String : Any]
        
        if let old = oldPassword { parameters["OldPassword"] = old }
        if let new = newPassword { parameters["NewPassword"] = new }
        
        API_WRAPPER.srvUpdateUser(parameters, userGUID: AMGUser.shared.userUUID, success: { response in
            success()
        }, failure: { error in
            if let message = error?.localizedDescription {
                failure(message)
            } else {
                failure(self.serverErrorMessage)
            }
        })
    }
    
    func loadUserCarAdditionalInfo(car: AMGUserCar, success: @escaping (URL)->(), failure: @escaping ()->()) {
        API_WRAPPER.srvGetCarAdditionalInfo(Int32(car.idSrv), userGUID: AMGUser.shared.userUUID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else { return }
            
            car.fillAdditionalInfoFromJSON(json: json["CarData"])
            let images = json["Images"].arrayValue.map({ $0.string })
            if let image = images.first, let url = URL(string: image!) {
                success(url)
                return
            } else {
                if let url = URL(string: json["Image"].stringValue) {
                    success(url)
                    return
                }
            }
            failure()
        }, failure: { error in
            failure()
        })
    }
    
    func addUserCar(car: AMGUserCar, result: AMGValidationResult?, success: @escaping (Int)->(), failure: @escaping (String)->()) {
        var parameters = [
            "MBModelId": car.idModel,
            "VIN": car.VIN,
            "RegistrationNumber": car.regNumber,
            "YearOfRelease": car.year
            ] as [String : Any]
        
        if let sapResponse = result?.sapResponse {
            parameters["SapResponse"] = sapResponse
        }
        
        API_WRAPPER.srvAddCar(parameters, forUser: AMGUser.shared.userUUID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure(self.serverErrorMessage)
                return
            }
            
            let id = json["Id"].intValue
            success(id)
        }, failure: { error in
            if let message = error?.localizedDescription {
                failure(message)
            } else {
                failure(self.serverErrorMessage)
            }
        })
    }
    
    func updateUserCar(car: AMGUserCar, result: AMGValidationResult?, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        var parameters = [
            "MBModelId": car.idModel,
            "VIN": car.VIN,
            "RegistrationNumber": car.regNumber,
            "YearOfRelease": car.year
            ] as [String : Any]
        
        if let sapResponse = result?.sapResponse {
            parameters["SapResponse"] = sapResponse
        }
        
        API_WRAPPER.srvUpdateCar(parameters, suffix: "\(car.idSrv)", forUser: AMGUser.shared.userUUID, success: { _ in
            success()
        }, failure: { error in
            if let message = error?.localizedDescription {
                failure(message)
            } else {
                failure(self.serverErrorMessage)
            }
        })
    }
    
    func deleteUserCar(carID: Int, success: @escaping ()->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvDeleteCar(Int32(carID), forUser: AMGUser.shared.userUUID, success: { response in
            success()
        }, failure: { error in
            failure()
        })
    }
    
    func updateUserDealer(dealerID: Int, success: @escaping ()->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvSetDealer(Int32(dealerID), forUser: AMGUser.shared.userUUID, success: { response in
            success()
        }, failure: { error in
            failure()
        })
    }
}

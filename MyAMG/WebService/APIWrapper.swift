//
//  APIWrapper.swift
//  MyAMG
//
//  Created by Сергей Никитин on 15/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIWrapper {
    
    func srvGetParts(order: AMGPartSearch, success: @escaping (Data?) -> (), failure: @escaping (Error?) -> ()) {
        
        let parameters = [
            "article": order.article,
            "guid": AMGUser.shared.userUUID,
            "latitude": order.latitude,
            "longitude": order.longitude] as [String : Any]
        
        API_WRAPPER.srvPartsSearch(parameters, success: success, failure: failure)
    }
    
    func srvUserRegister(smsCode: String, result: AMGValidationResult, success: @escaping (Data?) -> (), failure: @escaping (String) -> ()) {
        
        var carDataParameters: [String : Any]
        if let car = AMGUser.shared.registrationCars.first {
            carDataParameters = [
                "MBModelId": car.idModel,
                "VIN": car.VIN,
                "RegistrationNumber": car.regNumber,
                "YearOfRelease": car.year
            ]
        } else {
            carDataParameters = [:]
        }
        
        var parameters = [
            "Email": AMGUser.shared.email,
            "Password": AMGUser.shared.password,
            "FirstName": AMGUser.shared.firstName,
            "Phone": AMGUser.shared.phone,
            "LastName": AMGUser.shared.lastName,
            "DealerCityId": AMGUser.shared.dealerCityId,
            "DealerCityName": AMGUser.shared.dealerCityName,
            "MiddleName": AMGUser.shared.middleName,
            "Gender": AMGUser.shared.gender,
            "DealerId": AMGUser.shared.dealerId,
            "Token": AMGUser.shared.defaultDeviceToken,
            "UserGuid": AMGUser.shared.userUUID,
            "CarData": carDataParameters,
            "DeviceType": "iPhone",
            "DeviceId": UIDevice.current.identifierForVendor?.uuidString as Any,
            "SMSCode": smsCode,
            "phoneConsent": AMGUser.shared.phoneConsent,
            "emailConsent": AMGUser.shared.emailConsent,
            "smsConsent": AMGUser.shared.smsConsent
        ]
        
        if let sapResponse = result.sapResponse {
            parameters["SapResponse"] = sapResponse
        }
        
        if AMGUser.shared.age > 0 {
            parameters["Age"] = AMGUser.shared.age
        }
        
        API_WRAPPER.amgUserRegistration(with: parameters, success: success, failure: { error in
            if let message = error?.localizedDescription {
                failure(message)
            } else {
                failure("Ошибка при обращении к серверу. Попробуйте повторить позже")
            }
        })
    }
}

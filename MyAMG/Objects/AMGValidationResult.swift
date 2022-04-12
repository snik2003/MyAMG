//
//  AMGValidationResult.swift
//  MyAMG
//
//  Created by Сергей Никитин on 30/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGValidationResult {
    
    var isUserValid = false
    var isVinValid = false
    
    var userCar = AMGUserCar(json: JSON.null)
    
    var city = AMGObject(json: JSON.null)
    var dealer = AMGObject(json: JSON.null)
    
    var sapResponse: [String: Any]?
    
    init(json: JSON) {
        self.isUserValid = json["UserVerified"].boolValue
        self.isVinValid = json["VinVerified"].boolValue
        
        self.city = AMGObject(json: json["DealerData"]["City"])
        self.dealer = AMGObject(json: json["DealerData"]["Dealer"])
        
        let userCarBrand = AMGObject(json: json["CarData"]["Brand"])
        userCar.idMarka = userCarBrand.id
        userCar.nMarka = userCarBrand.name
        
        let userCarClass = AMGObject(json: json["CarData"]["Class"])
        userCar.idClass = userCarClass.id
        userCar.nClass = userCarClass.name
        
        let userCarModel = AMGObject(json: json["CarData"]["Model"])
        userCar.idModel = userCarModel.id
        userCar.nModel = userCarModel.name
        
        userCar.year = json["CarData"]["Year"].stringValue
        userCar.VIN = json["CarData"]["VIN"].stringValue
        
        sapResponse = json["SapResponse"].dictionaryObject
    }
}

//
//  AMGUserCar.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGUserCar: Codable {
    
    static let amgInSaleNewClasses = [7,9,10,11,13,15,16,18,20,22,23,27,30,37,38,49,50,52,53,56,57,58,59,61,62,72]
    static let amgInSaleUsedClasses = [1,5,6,7,8,10,11,12,13,15,17,18,19,22,24,26,34,39,40,43,44]
    
    var idTable: Int = 0
    var idSrv: Int = 0
    var idMarka: Int = 0
    var idClass: Int = 0
    var idModel: Int = 0
    var nMarka: String = ""
    var nClass: String = ""
    var nModel: String = ""
    var VIN: String = ""
    var regNumber: String = ""
    var year: String = ""
    var kaskoName: String = ""
    var kaskoNumber: String = ""
    var kaskoPhone: String = ""
    var osagoName: String = ""
    var osagoNumber: String = ""
    var osagoPhone: String = ""
    var osagoExpirationDate: String = ""
    var kaskoExpirationDate: String = ""
    
    var modelYear = ""
    var manufactureDate = ""
    var bodyTypeCode = ""
    var bodyTypeName = ""
    var baumuster = ""
    var engineVolume = ""
    var fuelType = ""
    var enginePower = ""
    var drive = ""
    var steeringWheel = ""
    var bodyColorName = ""
    var bodyColorCode = ""
    var salonColorName = ""
    var salonColorCode = ""
    var imageURLs: [String] = []
    var equipments: [AMGEquipmentGroup] = []

    init(json: JSON) {
        self.idSrv = json["Id"].intValue
        self.idMarka = json["BrandId"].intValue
        self.nMarka = json["BrandName"].stringValue
        self.idClass = json["MBClassId"].intValue
        self.nClass = json["MBClassName"].stringValue
        self.idModel = json["MBModelId"].intValue
        self.nModel = json["MBModelName"].stringValue
        self.regNumber = json["RegistrationNumber"].stringValue
        self.VIN = json["VIN"].stringValue
        self.year = json["YearOfRelease"].stringValue
        self.kaskoName = json["InsuranceKaskoName"].stringValue
        self.kaskoNumber = json["InsuranceKaskoNumber"].stringValue
        self.kaskoPhone = json["InsuranceKaskoPhone"].stringValue
        self.kaskoExpirationDate = json["InsuranceKaskoExpiration"].stringValue
        self.osagoName = json["InsuranceOsagoName"].stringValue
        self.osagoNumber = json["InsuranceOsagoNumber"].stringValue
        self.osagoPhone = json["InsuranceOsagoPhone"].stringValue
        self.osagoExpirationDate = json["InsuranceOsagoExpiration"].stringValue
    }
    
    func fillAdditionalInfoFromJSON(json: JSON) {
        self.modelYear = json["ModelYear"].stringValue
        self.manufactureDate = json["ManufactureDate"].stringValue
        self.bodyTypeCode = json["BodyTypeCode"].stringValue
        self.bodyTypeName = json["BodyType"].stringValue.lowercased()
        self.baumuster = json["Baumuster"].stringValue
        self.engineVolume = json["EngineDisplacement"].stringValue
        if self.engineVolume != "" { self.engineVolume = "\(self.engineVolume) куб. см." }
        
        let fuelTypeId = json["FuelType"].intValue
        switch (fuelTypeId) {
        case 0:
            self.fuelType = ""
        case 1:
            self.fuelType = "бензин"
        case 2:
            self.fuelType = "дизель"
        default:
            self.fuelType = "гибрид"
        }
        
        self.enginePower = json["EngineHp"].stringValue
        self.drive = driveFromCode(code: json["EngineDriveType"].stringValue)
        self.steeringWheel = json["SteeringWheelPosition"].stringValue
        self.bodyColorCode = json["BodyColorCode"].stringValue
        self.bodyColorName = json["BodyColorName"].stringValue
        self.salonColorCode = json["TrimCode"].stringValue
        self.salonColorName = json["TrimName"].stringValue
        
        self.equipments = json["EquipmentGroups"].compactMap({ AMGEquipmentGroup(json: $0.1) })

    }
    
    func driveFromCode(code: String) -> String {
        if code == "FWD" { return "Передний" }
        if code == "RWD" { return "Задний" }
        if code == "4WD" || code == "AWD" { return "Полный" }
        return ""
    }
    
    func isSapResponsed() -> Bool {
        if !self.modelYear.isEmpty || !self.manufactureDate.isEmpty || !self.baumuster.isEmpty || !self.bodyTypeCode.isEmpty || !self.bodyTypeName.isEmpty || !self.engineVolume.isEmpty || !self.enginePower.isEmpty || !self.drive.isEmpty || !self.bodyColorCode.isEmpty || !self.bodyColorName.isEmpty || !self.salonColorCode.isEmpty || !self.salonColorName.isEmpty || self.equipments.count > 0 { return true }
        
        return false
    }
}

class AMGEquipment: Codable {
    var name = ""
    var code = ""
    var identifier = 0
    
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.code = json["Code"].stringValue
        self.identifier = json["Id"].intValue
    }
}

class AMGEquipmentGroup: Codable {
    var name = ""
    var identifier = 0
    var equipments: [AMGEquipment] = []
    
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.identifier = json["Id"].intValue
        self.equipments = json["Equipments"].compactMap({ AMGEquipment(json: $0.1) })
    }
}


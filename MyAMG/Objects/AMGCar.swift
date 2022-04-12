//
//  AMGCar.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGCar: Codable {
    var idTable = 0
    var srvId = 0
    var nClass = ""
    var nModel = ""
    var cost = ""
    var colorBody = ""
    var monthManufacture = ""
    var yearManufacture = ""
    var listImage = ""
    var priceUrl = ""
    var salon = ""
    var orderNumber = ""
    var action = false
    var run = ""
    var status = ""
    var description = ""
    var equipments: [String] = []
    var images: [String] = []
    var dealerId = 0
    var dealer = ""
    var cityId = 0
    var city = ""
    var dealerAddress = ""
    var dealerPhone = ""
    var engineVolume = ""
    var basePrice = ""
    var optionsPrice = ""

    var salonTypeId = 0
    var baseBodyColorId = 0
    var baseSalonFurnishId = 0
    
    var modelSysName = ""
    var showroomId = 0
    
    // Added for used
    var engineType = ""
    var enginePower = ""
    var drive = ""
    
    var bodyType = ""
    var transmission = ""
    var steeringWheel = ""
    
    var isCertified = false
    
    init(json: JSON, isNew: Bool) {
        if isNew {
            self.srvId = json["Id"].intValue
            self.nClass = json["MBClassInfo"]["Name"].stringValue
            if self.nClass == "" { self.nClass = json["Model"].stringValue }
            self.nModel = json["Engine"].stringValue
            self.monthManufacture = json["MonthManufacture"].stringValue
            self.yearManufacture = json["YearManufacture"].stringValue
            self.colorBody = json["BodyColor"].stringValue
            self.cost = json["FinalPrice"].stringValue
            self.priceUrl = json["Url"].stringValue
            self.action = json["FullPrice"].stringValue != json["FinalPrice"].stringValue
            self.salon = json["SalonFurnish"].stringValue
            self.dealerId = json["DealerId"].intValue
            self.cityId = json["CityId"].intValue
            self.dealer = json["Dealer"].stringValue
            self.city = json["City"].stringValue
            self.listImage = json["ListImageExteriorBig"].stringValue
            if self.listImage.isEmpty { self.listImage = json["ListImage"].stringValue }
            
            self.salonTypeId = json["SalonTypeId"].intValue
            self.baseBodyColorId = json["BaseBodyColorId"].intValue
            self.baseSalonFurnishId = json["BaseSalonFurnishId"].intValue
            
            self.modelSysName = json["MBClassInfo"]["SysName"].stringValue
            if self.modelSysName == "" { self.modelSysName = json["ModelSysName"].stringValue }
            self.showroomId = json["ShowRoomId"].intValue
            
            if self.listImage == "" {
                self.images = json["Images"].arrayValue.map({ $0.stringValue })
                if self.images.count > 0 { self.listImage = self.images[0] }
            }
        }
        
        if !isNew {
            self.srvId = json["Id"].intValue
            self.nClass = json["MBClass"].stringValue
            self.isCertified = json["Certified"].boolValue
            
            self.nModel = json["Model"].stringValue
            
            self.yearManufacture = json["Year"].stringValue
            self.colorBody = json["Color"].stringValue
            self.cost = json["Price"].stringValue
            self.action = false
            self.dealer = json["Dealer"].stringValue
            self.dealerAddress = json["Address"].stringValue
            self.city = json["City"].stringValue
            self.engineVolume = json["Displacement"].stringValue
            self.equipments = []
            self.dealerPhone = json["Phone"].stringValue
            self.run = json["Run"].stringValue
            self.status = json["CarStatus"].stringValue
            self.description = json["Description"].stringValue
            
            self.enginePower = json["Horse-power"].stringValue
            self.engineType = json["Engine-type"].stringValue
            self.drive = json["Gear-type"].stringValue
            self.bodyType = json["Body-type"].stringValue
            self.transmission = json["Transmission"].stringValue
            self.steeringWheel = json["Steering-wheel"].stringValue
            
            if let image = json["MobileImages"].arrayValue.map({ $0["LinkSmall"].stringValue }).first {
                self.listImage = image }
            
            if let image = json["Images"].arrayValue.filter({ $0["IsDefault"].boolValue == true }).map({ $0["Link"].stringValue }).first {
                self.listImage = image
            }
        
            self.images = json["MobileImages"].arrayValue.map({ $0["LinkBig"].stringValue })
            
            self.equipments = json["Equipments"].arrayValue.map({ $0["Name"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines).capitalizeName() })
            if self.equipments.count == 0 {
                self.equipments = json["EquipmentText"].stringValue.replacingOccurrences(of: " \r", with: "").trimmingCharacters(in: .whitespacesAndNewlines).capitalizeName().components(separatedBy: .newlines)
            }
        }
    }
    
    func readNewCarDetails(json: JSON) {
        self.orderNumber = json["OrderNumber"].stringValue
        self.engineVolume = json["EngineVolume"].stringValue
        self.basePrice = json["BasePrice"].stringValue
        self.optionsPrice = json["OptionsPrice"].stringValue
        self.dealerPhone = json["DealerPhone"].stringValue
        
        self.images = json["Images"].arrayValue.map({ $0.stringValue })
        if self.images.count > 0 { self.listImage = self.images[0] }
        
        self.equipments = json["Equipments"].arrayValue.map({ $0.stringValue })
    }
}

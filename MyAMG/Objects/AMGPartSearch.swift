//
//  AMGPartSearch.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGPartSearch {
    var partNumber = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    var article = ""
    var name = ""
    var price = ""
    var wasNotFound = false
    var partsInStock = 0
    
    var cities: [AMGPartObject] = []
    var dealers: [AMGPartObject] = []
    var stocks: [AMGPartObject] = []

    var isHistory = false
    
    init(json: JSON) {
        self.article = json["Article"].stringValue
        self.name = json["NameRU"].stringValue
        if self.name == "" { self.name = json["NameDE"].stringValue }
        if self.name == "" { self.name = json["PartName"].stringValue }
        self.wasNotFound = json["WasNotFound"].boolValue
        self.partsInStock = json["PartsInStock"].intValue
        self.price = json["Price"].stringValue
        
        if !self.wasNotFound {
            self.cities = json["Cities"].compactMap { AMGPartObject(json: $0.1) }
            self.dealers = json["Dealers"].compactMap { AMGPartObject(json: $0.1) }
            self.stocks = json["StocksList"].compactMap { AMGPartObject(json: $0.1) }
        }
    }
}

class AMGPartObject {
    var srvId = 0
    var cityId = 0
    var dealerId = 0
    var name = ""
    var stockName = ""
    var address = ""
    var phone = ""
    var price = ""
    var partsInStock = 0
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    
    init(json: JSON) {
        self.srvId = json["Value"].intValue
        self.cityId = json["CityId"].intValue
        self.dealerId = json["DealerId"].intValue
        self.name = json["Text"].stringValue
        self.stockName = json["Name"].stringValue
        self.address = json["Address"].stringValue
        self.phone = json["Phone"].stringValue
        self.price = json["Price"].stringValue
        self.partsInStock = json["PartsInStock"].intValue
        self.latitude = json["Latitude"].doubleValue
        self.longitude = json["Longitude"].doubleValue
    }
}

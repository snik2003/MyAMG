//
//  AMGNewFilter.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SortOrder: Int {
    case Ascending = 0
    case Descending = 1
}

class AMGECFCity: AMGObject {
    var dealers: [AMGObject] = []
    
    override init(json: JSON) {
        super.init(json: json)
        self.dealers = json["DealersList"].compactMap({ AMGObject(json: $0.1) })
    }
}

class AMGColorObject: AMGObject {
    var color: UIColor?
    
    override init(json: JSON) {
        super.init(json: json)
        
        if json["RGB"].stringValue.isEmpty {
            self.color = nil
            return
        }
        
        let RGBArray = json["RGB"].stringValue.components(separatedBy: ",")
        if RGBArray.count < 3 {
            self.color = nil
            return
        }
        
        if let red = Int(RGBArray[0]), let green = Int(RGBArray[1]), let blue = Int(RGBArray[2]) {
            self.color = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
            return
        }
        
        self.color = nil
    }
}

class AMGECFModel {
    var name = ""
    var engineIdentifiers: [Double] = []
    
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.engineIdentifiers = json["EngineIds"].arrayValue.map({ $0.doubleValue })
    }
}

class AMGNewFilter {
    var cities: [AMGECFCity] = []
    var selectedCityId = 0
    
    var dealers: [AMGObject] = []
    var selectedDealerId = 0
    
    var classId = 0
    
    var models: [AMGECFModel] = []
    var selectedModelIds: [Double] = []
    
    var minimalPrice = 0.0
    var maximumPrice = 0.0
    var scalePrice = 0.0
    var selectedMinimalPrice = 0.0
    var selectedMaximumPrice = 0.0
    
    var bodyColors: [AMGColorObject] = []
    var selectedBodyColors: [Int] = []
    
    var salonTypes: [AMGObject]
    var selectedSalonType = 0
    
    var salonColors: [AMGColorObject] = []
    var selectedSalonColors: [Int] = []
    
    let sortingFields = ["Город", "Дилер", "Цена", "Год производства"]
    let sortingParameters = ["City", "Dealer", "Price", "DateManufacture"]
    var sortField = ""
    var sortParameter = ""
    
    var sortOrder = 0

    init(json: JSON) {
        self.cities = json["CitiesList"].compactMap({ AMGECFCity(json: $0.1) })
        self.dealers = json["DealersList"].compactMap({ AMGObject(json: $0.1) })
        self.models = json["EnginesList"].compactMap({ AMGECFModel(json: $0.1) }).filter({ $0.name.contains("AMG") })
        
        self.minimalPrice = ceil(json["MinimalPrice"].doubleValue / 100000) * 100000
        self.maximumPrice = ceil(json["MaximumPrice"].doubleValue / 100000) * 100000
        self.scalePrice = (maximumPrice - minimalPrice) / 10
        
        self.bodyColors = json["ColorValuesList"].compactMap({ AMGColorObject(json: $0.1) })
        self.salonTypes = json["SalonTypesList"].compactMap({ AMGColorObject(json: $0.1) })
        
        for salonType in self.salonTypes {
            if salonType.name.isEmpty { salonType.name = "Не указан"}
        }
        
        self.salonColors = json["SalonFurnishList"].compactMap({ AMGColorObject(json: $0.1) })
        
        self.selectedBodyColors = []
        self.selectedSalonColors = []
        self.selectedModelIds = []
        self.dealers = []
    }
    
    func setSelectedCityId(cityId: Int) {
        self.selectedCityId = cityId
        if cityId == 0 {
            self.dealers = []
            return
        }
        
        if let city = self.cities.filter({ $0.id == cityId }).last {
            self.dealers = city.dealers
        }
    }
    
    func setSortField(sortField: String) {
        if let index = self.sortingFields.firstIndex(of: sortField) {
            self.sortField = sortField
            self.sortParameter = self.sortingParameters[index]
        }
    }
    
    func reset() {
        self.selectedCityId = 0 // AMGUser.shared.dealerCityId
        self.selectedDealerId = 0 //AMGUser.shared.dealerId
        
        self.selectedMaximumPrice = self.maximumPrice
        self.selectedMinimalPrice = self.minimalPrice
        
        self.selectedBodyColors = []
        self.selectedSalonColors = []
        self.selectedModelIds = []
        self.selectedSalonType = 0
        self.dealers = []
        
        self.sortField = ""
        self.sortParameter = ""
        self.sortOrder = 0
    }
    
    func preparedFilter() -> AMGNewFilter {
        let preparedFilter = AMGNewFilter(json: JSON.null)
        
        preparedFilter.classId = self.classId
        
        if self.selectedMaximumPrice != self.maximumPrice {
            preparedFilter.selectedMaximumPrice = self.selectedMaximumPrice
        }
        
        if self.selectedMinimalPrice != self.minimalPrice {
            preparedFilter.selectedMinimalPrice = self.selectedMinimalPrice
        }
        
        preparedFilter.selectedDealerId = self.selectedDealerId
        preparedFilter.selectedCityId = self.selectedCityId
        preparedFilter.selectedModelIds = self.selectedModelIds
        preparedFilter.selectedBodyColors = self.selectedBodyColors
        preparedFilter.selectedSalonColors = self.selectedSalonColors
        preparedFilter.selectedSalonType = self.selectedSalonType
        preparedFilter.sortParameter = self.sortParameter
        preparedFilter.sortOrder = self.sortOrder
        
        return preparedFilter
    }
}


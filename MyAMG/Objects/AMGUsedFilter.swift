//
//  AMGUsedFilter.swift
//  MyAMG
//
//  Created by Сергей Никитин on 22/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGUsedCity: AMGObject {
    var dealers: [AMGObject] = []
    
    override init(json: JSON) {
        super.init(json: json)
        self.dealers = json["Dealers"].compactMap({ AMGObject(json: $0.1) })
    }
}

class AMGUsedFilter {
    var cities: [AMGUsedCity] = []
    var selectedCityId = 0
    
    var dealers: [AMGObject] = []
    var selectedDealerId = 0
    
    var classId = 0
    
    var models: [AMGObject] = []
    var selectedModelId = 0
    
    var drives: [AMGObject] = []
    var selectedDrive = 0
    
    var engineTypes: [AMGObject] = []
    var selectedEngineType = 0
    
    var minimalEngineVolume = 0.0
    var maximumEngineVolume = 0.0
    var scaleEngineVolume = 0.0
    var selectedMinimalEngineVolume = 0.0
    var selectedMaximumEngineVolume = 0.0
    
    var minimalPrice = 0.0
    var maximumPrice = 0.0
    var scalePrice = 0.0
    var selectedMinimalPrice = 0.0
    var selectedMaximumPrice = 0.0
    
    var minimalRun = 0.0
    var maximumRun = 0.0
    var scaleRun = 0.0
    var selectedMinimalRun = 0.0
    var selectedMaximumRun = 0.0
    
    var minimalYear = 0
    var maximumYear = 0
    var scaleYear = 0
    var selectedMinimalYear = 0
    var selectedMaximumYear = 0
    
    var bodyColors: [AMGColorObject] = []
    var selectedBodyColors: [Int] = []
    
    // NOTE: Sorting
    
    let sortingFields = ["Город", "Дилер", "Цена", "Пробег", "Год выпуска"]
    let sortingParameters = ["City", "Dealer", "Cost", "Run", "Year"]
    var sortField = ""
    var sortParameter = ""
    var sortOrder = 0
    
    var onlyCertified = false
    
    init(json: JSON) {
        self.cities = json["Cities"].compactMap({ AMGUsedCity(json: $0.1) })
        self.engineTypes = json["EngineTypes"].compactMap({ AMGObject(json: $0.1) })
        self.drives = json["GearTypes"].compactMap({ AMGObject(json: $0.1) })
        self.models = json["Models"].compactMap({ AMGObject(json: $0.1) }).filter({ $0.name.contains("AMG") })
        
        self.minimalYear = json["YearMin"].intValue
        self.maximumYear = json["YearMax"].intValue
        
        if (minimalYear == maximumYear) {
            self.minimalYear -= 1
            self.maximumYear += 1
        }
        
        self.scaleYear = 1
        
        // NOTE: Prepare scale for run
        
        self.minimalRun = ceil(json["RunMin"].doubleValue / 10000) * 10000
        if self.minimalRun == 10000 { self.minimalRun = 10 }
        self.maximumRun = (ceil(json["RunMax"].doubleValue / 10000) + 1) * 10000
        
        self.scaleRun = (self.maximumRun - self.minimalRun) / 10
        
        self.minimalEngineVolume = ceil(json["DisplacementMin"].doubleValue / 100) * 100
        self.maximumEngineVolume = (ceil(json["DisplacementMax"].doubleValue / 100) + 1) * 100
        self.scaleEngineVolume = (self.maximumEngineVolume - self.minimalEngineVolume) / 10
        
        self.minimalPrice = ceil(json["CostMin"].doubleValue / 100000) * 100000
        self.maximumPrice = (ceil(json["CostMax"].doubleValue / 100000) + 1) * 100000
        self.scalePrice = (self.maximumPrice - self.minimalPrice) / 10
        
        self.bodyColors = json["ColorBodies"].compactMap({ AMGColorObject(json: $0.1) })
        
        self.selectedBodyColors = []
        self.dealers = []
        
        self.onlyCertified = false;
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
        self.selectedDealerId = 0 // AMGUser.shared.dealerId
        
        self.selectedModelId = 0
        self.selectedDrive = 0
        self.selectedEngineType = 0
        
        self.selectedMinimalRun = self.minimalRun
        self.selectedMaximumRun = self.maximumRun
        self.selectedMinimalYear = self.minimalYear
        self.selectedMaximumYear = self.maximumYear
        
        self.selectedMaximumEngineVolume = self.maximumEngineVolume
        self.selectedMaximumPrice = self.maximumPrice
        self.selectedMinimalEngineVolume = self.minimalEngineVolume
        self.selectedMinimalPrice = self.minimalPrice
        
        self.selectedBodyColors = []
        self.dealers = []
        
        self.sortField = ""
        self.sortParameter = ""
        self.sortOrder = 0
        
        self.onlyCertified = false
    }
}

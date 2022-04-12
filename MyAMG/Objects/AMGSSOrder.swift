//
//  AMGSSOrder.swift
//  MyAMG
//
//  Created by Сергей Никитин on 06/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGSSOrder {
    var classId = 0
    var engineTypeId = 0
    var scTypeId = 0
    var periodId = 0
    
    var scTypeName = ""
    var descr = ""
    var footNotes: [String] = []
    var isTechnicalInspections = false
    var generalRuns = false
    var arrPrice: [AMGSSPrice] = []
    var engineGeneralRun = 0
    
    var cityId = 0
    var showRoomId = 0
    var cityName = ""
    var showRoomName = ""
    var vin = ""
    var lastName = ""
    var firstName = ""
    var middleName = ""
    var phone = ""
    var email = ""
    
    init(json: JSON) {
        self.scTypeName = json["SCTypeName"].stringValue
        
        let descr1 = json["PriceCondition"].stringValue
        let descr2 = json["DetailedInformation"].stringValue
        let descr3 = json["ConclusionServiceContractText"].stringValue
        
        self.descr = descr1
        if !descr2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.descr = "\(self.descr)\n\n\(descr2)"
        }
        if !descr3.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.descr = "\(self.descr)\n\n\(descr3)"
        }
        
        self.isTechnicalInspections = json["WithTechnicalInspections"].boolValue
        self.generalRuns = json["WithGeneralRuns"].boolValue
        
        self.footNotes = json["Footnotes"].arrayValue.map({ $0.stringValue })
        self.arrPrice = json["Results"].compactMap({ AMGSSPrice(json: $0.1) })
    }
}

class AMGSSType {
    var id = 0
    var text = ""
    var linkDetailed = ""
    var descr = ""
    var multiplePeriods = false
    
    init(json: JSON) {
        self.id = json["Id"].intValue
        self.linkDetailed = json["LinkDetailed"].stringValue
        self.descr = json["Description"].stringValue
        self.text = json["Text"].stringValue
        self.multiplePeriods = json["WithMultiplePeriods"].boolValue
    }
}

class AMGSSPrice {
    var generalRun = ""
    var technicalInspections = 0
    var price = 0

    init(json: JSON) {
        self.generalRun = json["GeneralRun"].stringValue
        self.technicalInspections = json["TechnicalInspections"].intValue
        self.price = json["Price"].intValue
    }
}

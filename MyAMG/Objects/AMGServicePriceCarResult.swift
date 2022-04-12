//
//  AMGServicePriceCarResult.swift
//  MyAMG
//
//  Created by Сергей Никитин on 09/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGServicePriceCarResult {
    var classId = 0
    var className = ""
    
    var yearId = 0
    var yearName = ""
    
    var bodyTypeId = 0
    var bodyTypeName = ""
    
    var engineTypeId = 0
    var engineType = 0
    
    var mileageItems: [Double] = []
    var completlyFound = false
    
    var id = 0
    var name = ""
    var sysName = ""
    
    var classSysName = ""
    var modelSysName = ""
    
    init(json: JSON) {
        self.bodyTypeId = json["BodyTypeId"].intValue
        self.bodyTypeName = json["BodyTypeName"].stringValue
        self.engineTypeId = json["EngineTypeId"].intValue
        self.engineType = json["EngineType"].intValue
        
        self.id = json["Id"].intValue
        self.name = json["Name"].stringValue
        
        self.sysName = json["SysName"].stringValue
        if self.sysName.count == 0 { self.sysName = json["SpSysName"].stringValue }
    }
}

//
//  AMGClasses.swift
//  MyAMG
//
//  Created by Сергей Никитин on 15/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGObject {
    var id = 0
    var name = ""
    var sysName = ""
    
    var mbClassId = 0
    
    init(json: JSON) {
        self.id = json["Id"].intValue
        self.name = json["Name"].stringValue
        
        self.sysName = json["SysName"].stringValue
        if self.sysName.count == 0 { self.sysName = json["SpSysName"].stringValue }
        
        self.mbClassId = json["MBClassId"].intValue
    }
}

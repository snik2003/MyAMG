//
//  AMGServiceManager.swift
//  MyAMG
//
//  Created by Сергей Никитин on 01/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGServiceManager {
    var managerID = ""
    var name = ""
    var image = ""
    
    var workweekWorkTimeFrom = ""
    var workweekWorkTimeTo = ""
    var weekendWorkTimeFrom = ""
    var weekendWorkTimeTo = ""
    
    var shedules: [AMGServiceShedule] = []
    
    init(json: JSON, id: String) {
        self.managerID = id;
        self.name = json["Name"].stringValue
        self.image = json["Image"].stringValue
        self.workweekWorkTimeFrom = json["WorkweekWorkTimeFrom"].stringValue
        self.workweekWorkTimeTo = json["WorkweekWorkTimeTo"].stringValue
        self.weekendWorkTimeFrom = json["WeekendWorkTimeFrom"].stringValue
        self.weekendWorkTimeTo = json["WeekendWorkTimeTo"].stringValue
        
        self.shedules = []
        if let dict = json["ScheduleByDate"].dictionary {
            for key in dict.keys {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                if let date = formatter.date(from: key) {
                    let shedule = AMGServiceShedule(json: json["ScheduleByDate"][key], date: date)
                    self.shedules.append(shedule)
                }
            }
        }
    }
}

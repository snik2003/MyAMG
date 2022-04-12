//
//  AMGServiceShedule.swift
//  MyAMG
//
//  Created by Сергей Никитин on 01/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGServiceShedule {
    var date: Date!
    var timeIntervals: [AMGServiceTimeInterval] = []

    init(json: JSON, date: Date) {
        self.date = date
        self.timeIntervals = json.compactMap({ AMGServiceTimeInterval(json: $0.1) })
    }
    
    func numberOfFreeIntervals() -> Int {
        return timeIntervals.filter({ $0.isFree == true }).count
    }
    
    func multiplyTimeIntervals(intervals: [AMGServiceTimeInterval]) {
        
        var result: [AMGServiceTimeInterval] = []
    
        for interval in intervals {
            if self.timeIntervals.filter({ $0.intervalFrom == interval.intervalFrom }).count > 0 {
                for dollyInterval in self.timeIntervals.filter({ $0.intervalFrom == interval.intervalFrom }) {
                    dollyInterval.isFree = dollyInterval.isFree || interval.isFree
                }
            } else {
                result.append(interval)
            }
        }
    
        self.timeIntervals = result;
    }
}

class AMGServiceTimeInterval {
    var intervalFrom = ""
    var intervalAsString = ""
    var isFree = false
    var isSpecialPrice = false
    var comment = ""
    
    init(json: JSON) {
        self.intervalFrom = json["IntervalFrom"].stringValue
        self.intervalAsString = json["IntervalAsString"].stringValue
        self.comment = json["Comment"].stringValue
        self.isFree = json["IsFree"].boolValue
        self.isSpecialPrice = json["IsSpecialPrice"].boolValue
    }
}



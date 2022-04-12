//
//  AMGSPEmailOrder.swift
//  MyAMG
//
//  Created by Сергей Никитин on 17/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGSPEmailOrder {
    var email = ""
    
    var modelId = 0
    var yearId = 0
    var mileage = 0
    var carMileage = 0
    var showRoomId = 0
    
    var servicePlusIds: [Int] = []
    
    init(request: AMGSPCalculationRequest) {
        
        self.modelId = request.modelId
        self.yearId = request.yearId
        self.mileage = request.mileage
        self.carMileage = request.carMileage
        self.showRoomId = request.showRoomId
    }
}

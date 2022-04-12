//
//  AMGSPCalculationResult.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGSPCalculationResult {
    var price = 0
    var serviceMainName = ""
    
    var mainOptions: [AMGServicePriceOption] = []
    var otherOptions: [AMGServicePriceOption] = []
    var plusOptions: [AMGServicePricePlusOption] = []
    
    var detailOptions: [AMGServicePriceOption] = []
    
    init(json: JSON) {
        self.price = json["Price"].intValue
        self.serviceMainName = json["ServiceMainName"].stringValue
        
        self.mainOptions = json["ServiceMainShortList"].compactMap({ AMGServicePriceOption(json: $0.1) })
        self.otherOptions = json["ServiceOtherShortList"].compactMap({ AMGServicePriceOption(json: $0.1) })
        self.plusOptions = json["ServicePlusShortList"].compactMap({ AMGServicePricePlusOption(json: $0.1) })
        
        self.detailOptions = json["ServiceDetailList"].compactMap({ AMGServicePriceOption(json: $0.1) })
    }
}

class AMGServicePriceOption: AMGObject {
    var isSpecialOffer = false
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.isSpecialOffer = json["IsSpecialOffer"].boolValue
    }
}

class AMGServicePricePlusOption: AMGObject {
    var price = 0
    var isSpecialOffer = false
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.price = json["Price"].intValue
        self.isSpecialOffer = json["IsSpecialOffer"].boolValue
    }
}



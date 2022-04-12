//
//  AMGShowroom.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGShowroom {
    var id = 0
    var name = ""
    var cityId = 0
    var city = ""
    var dealerId = 0
    var coFiCo = ""
    var address = ""
    var email = ""
    var imageUrl = ""
    var smallImageUrl = ""
    var latitude = ""
    var longitude = ""
    var phone = ""
    var servicePhone = ""
    var index = ""
    var daysBeforeServiceOrder = 0
    var daysAfterServiceOrder = 0
    var minutesBeforeClosingServiceOrder = 0
    var isOrderStatus = false
    var isRentAvailable = false
    
    var siteUrl = ""
    var smartSiteUrl = ""
    
    init(json: JSON) {
        self.id = json["Id"].intValue
        self.name = json["Name"].stringValue
        self.city = json["City"].stringValue
        self.address = json["Address"].stringValue
        self.email = json["Email"].stringValue
        self.index = json["Index"].stringValue
        self.latitude = json["Latitude"].stringValue
        self.longitude = json["Longitude"].stringValue
        self.phone = json["Phone"].stringValue
        self.servicePhone = json["ServicePhone"].stringValue
        self.coFiCo = json["CoFiCo"].stringValue
        self.imageUrl = json["ImageUrl"].stringValue
        self.smallImageUrl = json["MobileAppImageUrl"].stringValue
        
        self.siteUrl = json["Site"].stringValue
        self.smartSiteUrl = json["SmartSite"].stringValue
        self.isRentAvailable = json["Rent"].boolValue
    }
}

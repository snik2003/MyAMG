//
//  AMGUserConsent.swift
//  MyAMG
//
//  Created by Сергей Никитин on 10/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGUserConsent {
    
    static let shared = AMGUserConsent(json: JSON.null)
    
    var isSuccess = false
    var agreePhone = false
    var agreeEmail = false
    var agreeSMS = false
    
    init(json: JSON) {
        self.agreePhone = json["AgreePhone"].boolValue
        self.agreeEmail = json["AgreeEmail"].boolValue
        self.agreeSMS = json["AgreeSMS"].boolValue
    }
}

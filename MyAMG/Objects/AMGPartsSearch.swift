//
//  AMGPartsSearch.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGPartsSearch {
    var searchString = ""
    var parts: [AMGPartSearch] = []
    
    init(json: JSON) {
        self.searchString = json["Article"].stringValue
        self.parts = json["Results"].compactMap { AMGPartSearch(json: $0.1) }
    }
}

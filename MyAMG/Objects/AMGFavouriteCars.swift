//
//  AMGFavouriteCars.swift
//  MyAMG
//
//  Created by Сергей Никитин on 26/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGFavouriteCars: Codable {
    
    static let shared = AMGFavouriteCars(json: JSON.null)
    
    var newCars: [AMGCar] = []
    var usedCars: [AMGCar] = []
    
    init(json: JSON) {
        self.newCars = json["FavouritesNewCars"].compactMap({ AMGCar(json: $0.1, isNew: true) })
        self.usedCars = json["FavouritesUsedCars"].compactMap({ AMGCar(json: $0.1, isNew: false) })
    }
}

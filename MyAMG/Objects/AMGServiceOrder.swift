//
//  AMGServiceOrder.swift
//  MyAMG
//
//  Created by Сергей Никитин on 02/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGServiceOrder {
    var gender = 0
    var lastName = ""
    var firstName = ""
    var middleName = ""
    var phone = ""
    var email = ""
    
    var serviceTypeId = 0
    var serviceName = ""
    var showRoomId = 0
    var userCarId = 0
    var dateTime = Date()
    
    var dealerConsultantId = 0      //DealerConsultantId
    var  toType = 0                 //ToType: 0 - если не ТО, 1 - без консультантов, 2 - с консультантами
    var brandId = 0                 // id марки автомобиля
    var classId = 0                 // id класса автомобиля
    var classSysName = ""           // SysName класса автомобиля из проекта ContactsDB
    var carModel = ""               // Модель автомобиля
    var carYearRelease = ""         // Год выпуска автомобиля
    var carVin = ""                 // VIN автомобиля
    var carRegNumber = ""           // Государственный номер автомобиля
    
    var comment = ""                 // комментарий от калькулятора по сервису
}

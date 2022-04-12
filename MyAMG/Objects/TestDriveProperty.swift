//
//  TestDriveProperty.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class TestDriveProperty {
    var isOpen = false
    var isList = false
    var title = ""
    var subtitle = ""
    var list: [AMGObject] = []
    
    init(index: Int) {
        if index == 0 {
            self.isOpen = false
            self.isList = false
            self.title = "Требования к участникам"
            self.subtitle = "Требования к водителю: не менее 25 лет и водительский стаж не меньше 3-х лет (категория В)"
            self.list = []
        }
        
        if index == 1 {
            self.isOpen = false
            self.isList = false
            self.title = "Продолжительность тест-драйва"
            self.subtitle = "Тест-драйв проходит в течение 45 минут по маршруту длиной в 32 км"
            self.list = []
        }
        
        if index == 2 {
            self.isOpen = false
            self.isList = true
            self.title = "Необходимые данные для записи"
            self.subtitle = ""
            
            let object1 = AMGObject(json: JSON.null)
            object1.id = 1
            object1.name = "Паспорт гражданина РФ"
            
            let object2 = AMGObject(json: JSON.null)
            object2.id = 2
            object2.name = "Водительское удостоверение категории B"
            
            let object3 = AMGObject(json: JSON.null)
            object3.id = 3
            object3.name = "Контактные данные"
            
            let object4 = AMGObject(json: JSON.null)
            object4.id = 4
            object4.name = "VIN Вашего Mercedes-AMG"
            
            self.list = [object1,object2,object3,object4]
        }
        
        
        if index == 3 {
            self.isOpen = false
            self.isList = true
            self.title = "Перечень моделей"
            self.subtitle = ""
            
            let object1 = AMGObject(json: JSON.null)
            object1.id = 1
            object1.name = "Mercedes-AMG C 63 S"
            
            let object2 = AMGObject(json: JSON.null)
            object2.id = 2
            object2.name = "Mercedes-AMG GLC 43 4MATIC Coupe Особая Серия"
            
            let object3 = AMGObject(json: JSON.null)
            object3.id = 3
            object3.name = "Mercedes-AMG GLC 63 S 4MATIC"
            
            let object4 = AMGObject(json: JSON.null)
            object4.id = 4
            object4.name = "Mercedes-AMG E 53 4MATIC+ Coupe Особая Серия"
            
            let object5 = AMGObject(json: JSON.null)
            object5.id = 5
            object5.name = "Mercedes-AMG E 63 S 4MATIC"
            
            let object6 = AMGObject(json: JSON.null)
            object6.id = 6
            object6.name = "Mercedes-AMG CLS 53 4MATIC+ Особая Серия"
            
            let object7 = AMGObject(json: JSON.null)
            object7.id = 7
            object7.name = "Mercedes-AMG GLE 63 S 4MATIC Coupe"
            
            let object8 = AMGObject(json: JSON.null)
            object8.id = 8
            object8.name = "Mercedes-AMG S 63 4MATIC Cabrio"
            
            let object9 = AMGObject(json: JSON.null)
            object9.id = 9
            object9.name = "Mercedes-AMG S 63 4MATIC+ Coupe"
            
            let object10 = AMGObject(json: JSON.null)
            object10.id = 10
            object10.name = "Mercedes-AMG GT 63 4MATIC"
            
            let object11 = AMGObject(json: JSON.null)
            object11.id = 11
            object11.name = "Mercedes-AMG G 63"
            
            self.list = [object1,object2,object3,object4,object5,object6,object7,object8,object9,object10,object11]
        }
    }
    
}

//
//  AMGDataManager.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

class AMGDataManager {
    
    let serverErrorMessage = "Ошибка при обращении к серверу. Попробуйте повторить позже"
    
    func getClassesNames(success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvClassesNames(byBrandId: 1, includeVans: false, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let classes = json.compactMap { AMGObject(json: $0.1) }
            success(classes)
        }, failure: { error in
            failure()
        })
    }
    
    func getUserCarClassSystemName(car: AMGUserCar, success: @escaping (String)->(), failure: @escaping ()->()) {
    
        getClassesNames(success: { classes in
            for carClass in classes {
                if carClass.id == car.idClass {
                    success(carClass.sysName)
                    return
                }
            }
            success("")
        }, failure: {
            failure()
        })
    }
    
    func getUserCarModelSystemName(car: AMGUserCar, success: @escaping (String)->(), failure: @escaping ()->()) {
        
        getModelsNames(classID: Int32(car.idClass), success: { models in
            for model in models {
                if model.id == car.idModel {
                    success(model.sysName)
                    return
                }
            }
            success("")
        }, failure: {
            failure()
        })
    }
    
    func getModelsNames(classID: Int32, success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetModels(forClassId: classID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let models = json.compactMap { AMGObject(json: $0.1) }
            success(models)
        }, failure: { error in
            failure()
        })
    }
    
    func getCitiesNames(success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvDealersCities({ response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let cities = json.compactMap { AMGObject(json: $0.1) }
            success(cities)
        }, failure: { error in
            failure()
        })
    }
    
    func getDealersNames(cityID: Int32, success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvDealers(inCity: cityID, excludeVans: false, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let dealers = json.compactMap { AMGObject(json: $0.1) }
            success(dealers)
        }, failure: { error in
            failure()
        })
    }
    
    func getShowroomsForDealer(dealerId: Int, success: @escaping ([AMGShowroom])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvShowrooms(ofDealer: Int32(dealerId), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let showrooms = json.compactMap { AMGShowroom(json: $0.1) }
            success(showrooms)
        }, failure: { error in
            failure()
        })
    }
    
    func getServiceResultForCar(_ car: AMGUserCar, success: @escaping (Bool)->(), failure: @escaping ()->()) {
        
        success(true)
        return
            
        /*API_WRAPPER.srvReadServiceCarClasses({ response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let classes = json.compactMap { AMGObject(json: $0.1) }
            for carClass in classes {
                if carClass.id == car.idClass {
                    
                    API_WRAPPER.srvReadServiceCarModification(Int32(carClass.id), success: { response in
                        guard let data = response, let json = try? JSON(data: data) else {
                            failure()
                            return
                        }
                        let types = json.compactMap { AMGObject(json: $0.1) }
                        for carType in types {
                            if carType.name.lowercased() == car.nModel.lowercased() {
                                
                                API_WRAPPER.srvReadServiceCarManufactureYears(Int32(carType.id), success: { response in
                                    guard let data = response, let json = try? JSON(data: data) else {
                                        failure()
                                        return
                                    }
                                    
                                    let years = json.arrayValue.map { $0.stringValue }
                                    if years.contains(car.year) {
                                        success(true)
                                        return
                                    }
                                    
                                    success(false)
                                }, failure: { _ in
                                    failure()
                                })
                                
                                return
                            }
                        }
                        success(false)
                    }, failure: { _ in
                        failure()
                    })
                    
                    return
                }
            }
            success(false)
        }, failure: { _ in
            failure()
        })*/
    }
    
    func getWorkTypeForShowroom(showroom: AMGShowroom?, success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        var showroomID: NSNumber? = nil
        if showroom != nil {
            showroomID = showroom?.id as NSNumber?
        }
        API_WRAPPER.srvReadServiceTypes(forShowroomId: showroomID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let workTypes = json.compactMap { AMGObject(json: $0.1) }
            success(workTypes)
        }, failure: { error in
            failure()
        })
    }
    
    func getServiceShedule(showroomID: Int, success: @escaping ([AMGServiceShedule], [AMGServiceManager])->(), failure: @escaping ()->()) {
    
        API_WRAPPER.srvReadServiceSchedule(withShowroomId: Int32(showroomID), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            //print(json)
            if let dict = json.dictionary {
                var shedules: [AMGServiceShedule] = []
                var managers: [AMGServiceManager] = []
                
                for key in dict.keys {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd.MM.yyyy"
                    if let date = formatter.date(from: key) {
                        let shedule = AMGServiceShedule(json: json[key], date: date)
                        shedules.append(shedule)
                    }
                    
                    let manager = AMGServiceManager(json: json[key], id: key)
                    managers.append(manager)
                }
                
                success(shedules, managers)
                return
            }
            failure()
        }, failure: { _ in
            failure()
        })
    }
    
    func sendServiceOrder(car: AMGUserCar, order: AMGServiceOrder, success: @escaping ()->(), failure: @escaping (String)->()) {
    
       
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        var serviceOrder = [
            "Gender": order.gender,
            "LastName": order.lastName,
            "FirstName": order.firstName,
            "PatronymicName": order.middleName,
            "Phone": order.phone,
            "Email": order.email,
            "Comment": order.comment,
            "ServiceTypeId": order.serviceTypeId,
            "CarClassName": order.classSysName,
            "CarModel": order.carModel,
            "CarYearRelease": order.carYearRelease,
            "CarVin": order.carVin,
            "CarRegNumber": order.carRegNumber,
            "ShowRoomId": order.showRoomId,
            "DateCreated": dateFormatter.string(from: Date()),
            "ToType": order.toType,
            "PreferableDate": dateFormatter.string(from: order.dateTime),
            "DeviceType": "iPhone"
            ] as [String : Any]
        
        if order.serviceName == "Техническое обслуживание" {
            serviceOrder["DealerConsultantId"] = order.dealerConsultantId
        }
        
        let parameters = [
            "userGuid" : AMGUser.shared.userUUID,
            "order" : serviceOrder,
            "AgreePersonalData": true,
            "AgreePhone": AMGUserConsent.shared.agreePhone,
            "AgreeEmail": AMGUserConsent.shared.agreeEmail,
            "AgreeSMS": AMGUserConsent.shared.agreeSMS
        ] as [String : Any]
        
        API_WRAPPER.srvServiceCreateOrder(parameters, success: { _ in
            success()
        }, failure: { error in
            if let _ = error?.localizedDescription {
                failure("Данная модификация автомобиля не найдена")
            } else {
                failure(self.serverErrorMessage)
            }
        })
    }
    
    func getSSEngineTypesForCar(_ car: AMGUserCar, success: @escaping (Bool, Int, AMGObject?)->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvSCClasses({ response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let classes = json.compactMap({ AMGObject(json: $0.1) })
            for carClass in classes {
                if carClass.id == car.idClass {
                    API_WRAPPER.srvSCEngineTypes(forClass: Int32(carClass.id), success: { response2 in
                        guard let data = response2, let json2 = try? JSON(data: data) else {
                            failure()
                            return
                        }
                        
                        let enginesTypes = json2.compactMap({ AMGObject(json: $0.1) })
                        if let engine = enginesTypes.filter({ $0.name.contains("AMG")}).first {
                            success(true, carClass.id, engine)
                            return
                        }
                        success(false, 0, nil)
                    }, failure: { _ in
                        failure()
                    })
                    return
                }
            }
            success(false, 0, nil)
        }, failure: { _ in
            failure()
        })
    }
    
    func getSSTypesForEngineType(engineTypeID: Int, success: @escaping ([AMGSSType])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvSSTypes(withEngineTypeId: Int32(engineTypeID), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let ssTypes = json.compactMap({ AMGSSType(json: $0.1) })
            success(ssTypes)
        }, failure: { _ in
            failure()
        })
    }
    
    func getSSPrices(order: AMGSSOrder, success: @escaping (AMGSSOrder)->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvSCPeriod(withEngineTypeId: Int32(order.engineTypeId), scTypeId: Int32(order.scTypeId), success: { response in
            
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let durations = json.compactMap({ AMGObject(json: $0.1) })
            if durations.count > 0 {
            
                order.periodId = durations[0].id
                
                let parameters = [
                    "EngineTypeId": order.engineTypeId,
                    "SCTypeId": order.scTypeId,
                    "MBClassId": order.classId,
                    "PeriodId": order.periodId
                ]
                
                API_WRAPPER.srvSCPrice(parameters, success: { response in
                    guard let data = response, let json = try? JSON(data: data) else {
                        failure()
                        return
                    }
                    
                    let order = AMGSSOrder(json: json)
                    success(order)
                }, failure: { _ in
                    failure()
                })
            } else {
                failure()
            }
        }, failure: { _ in
            failure()
        })
    }
    
    func sendSSOrder(order: AMGSSOrder, success: @escaping ()->(), failure: @escaping (String)->()) {
    
        let customFields = [
            customFieldObjectWithName("UserGuid", value: AMGUser.shared.userUUID),
            customFieldObjectWithName("OrderType", value: NSNumber(2)),
        ]
         
        let parameters = [
            "MBClassId": order.classId,
            "EngineTypeId": order.engineTypeId,
            "SCTypeId": order.scTypeId,
            "CityId": order.cityId,
            "ShowRoomId": order.showRoomId,
            "VIN": order.vin,
            "FirstName": AMGUser.shared.firstName,
            "LastName": AMGUser.shared.lastName,
            "Patronymic": AMGUser.shared.middleName,
            "Phone": AMGUser.shared.phone,
            "Email": AMGUser.shared.email,
            "IsSubscriber": false,
            "PeriodId": order.periodId,
            "DeviceType": "iPhone",
            "CustomFields": customFields,
            "CarTypeId": 1,
            "EngineGeneralRun": order.engineGeneralRun,
            "AgreePersonalData": true,
            "AgreePhone": AMGUserConsent.shared.agreePhone,
            "AgreeEmail": AMGUserConsent.shared.agreeEmail,
            "AgreeSMS": AMGUserConsent.shared.agreeSMS
        ] as [String : Any]
        
        API_WRAPPER.srvSCOrder(parameters, user: AMGUser.shared.userUUID, success: { _ in
            success()
        }, failure: { error in
            if let _ = error?.localizedDescription {
                failure("Данная модификация автомобиля не найдена")
            } else {
                failure(self.serverErrorMessage)
            }
        })
    }
    
    func getServicePriceClasses(success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        API_WRAPPER.srvGetServicePriceClasses({ response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let classes = json.compactMap({ AMGObject(json: $0.1) })
            success(classes)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceYears(classID: Int, success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        API_WRAPPER.srvGetServicePriceYears(forClassId: Int32(classID), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let years = json.compactMap({ AMGObject(json: $0.1) })
            success(years)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceModelForCar(classID: Int, year: Int, bodyType: Int, success: @escaping ([AMGServicePriceCarResult])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetServicePriceModels(forClassId: Int32(classID), year: Int32(year), bodyType: Int32(bodyType), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            //print(json)
            let result = json.compactMap { AMGServicePriceCarResult(json: $0.1) }
            success(result)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceMileageItems(modelID: Int, success: @escaping ([Double])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetServicePriceMileageItems(forModelId: Int32(modelID), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let mileages = json.arrayValue.map({ $0["Value"].doubleValue })
            success(mileages)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceCarResult(_ car: AMGUserCar, success: @escaping (AMGServicePriceCarResult?)->(), failure: @escaping ()->()) {
        
        self.getServicePriceClasses(success: { classes in
            
            var servicePriceCarClassId = 0
            var servicePriceCarClassName = ""
            
            for carClass in classes {
                if carClass.id == car.idClass {
                    servicePriceCarClassId = carClass.id
                    servicePriceCarClassName = carClass.name
                }
            }
            
            if servicePriceCarClassId == 0 {
                success(nil)
                return
            }
            
            let result = AMGServicePriceCarResult(json: JSON.null)
            result.classId = servicePriceCarClassId
            result.className = servicePriceCarClassName
            result.classSysName = car.nClass
            
            self.getServicePriceYears(classID: servicePriceCarClassId, success: { years in
                
                var servicePriceYearId = 0
                var servicePriceYearName = ""
                for year in years {
                    if year.name == car.year {
                        servicePriceYearId = year.id
                        servicePriceYearName = year.name
                    }
                }
                
                if servicePriceYearId == 0 {
                    success(result)
                    return
                }
                
                result.yearId = servicePriceYearId
                result.yearName = servicePriceYearName
                
                self.getServicePriceModelForCar(classID: servicePriceCarClassId, year: servicePriceYearId, bodyType: 0, success: { jsonResult in
                    
                    for res in jsonResult {
                        if res.name == car.nModel {
                            result.id = res.id
                            result.name = res.name
                            result.sysName = res.sysName
                            result.bodyTypeId = res.bodyTypeId
                            result.bodyTypeName = res.bodyTypeName
                            result.engineTypeId = res.engineTypeId
                            result.engineType = res.engineType
                            
                            result.modelSysName = res.modelSysName
                        }
                    }
                    
                    if result.bodyTypeId == 0 {
                        success(result)
                        return
                    }
                    
                    result.completlyFound = true
                    
                    self.getServicePriceMileageItems(modelID: result.id, success: { mileages in
                        
                        result.mileageItems = mileages
                        success(result)
                    }, failure: {
                        failure()
                    })
                }, failure: {
                    failure()
                })
            }, failure: {
                failure()
            })
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceCities(success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetServicePriceCities({ response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let cities = json.compactMap({ AMGObject(json: $0.1) })
            success(cities)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceShowroomsForCityId(_ cityID: Int, success: @escaping ([AMGShowroom])->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetServicePriceShowrooms(forCityId: Int32(cityID), success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let showrooms = json.compactMap({ AMGShowroom(json: $0.1) })
            success(showrooms)
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceCityAndDealerForCurrentUser(success: @escaping (Int, String?, AMGShowroom)->(), failure: @escaping ()->()) {
        getServicePriceCities(success: { cities in
            var servicePriceCityId = 0
            var servicePriceCityName = ""
            var servicePriceShowroom = AMGShowroom(json: JSON.null)
            
            for city in cities {
                if city.name == AMGUser.shared.dealerCityName {
                    servicePriceCityId = city.id
                    servicePriceCityName = city.name
                }
            }
            
            if servicePriceCityId == 0 {
                success(0,nil,servicePriceShowroom)
                return
            }
            
            self.getShowroomsForDealer(dealerId: AMGUser.shared.dealerId, success: { showroomsCMS in
                self.getServicePriceShowroomsForCityId(servicePriceCityId, success: { showroomsSP in
                    
                    for showroomCMS in showroomsCMS {
                        for showroomSP in showroomsSP {
                            if showroomCMS.coFiCo == showroomSP.coFiCo {
                                servicePriceShowroom = showroomCMS
                                break
                            }
                        }
                    }
                    
                    success(servicePriceCityId, servicePriceCityName, servicePriceShowroom)

                }, failure: {
                    failure()
                })
            }, failure: {
                failure()
            })
        }, failure: {
            failure()
        })
    }
    
    func getServicePriceCalculation(request: AMGSPCalculationRequest, success: @escaping (AMGSPCalculationResult)->(), failure: @escaping ()->()) {
        
        let parameters = [
            "mbModelId": request.modelId,
            "manufactureYearId": request.yearId,
            "mileage": request.mileage,
            "showRoomId": request.showRoomId
        ]
        
        API_WRAPPER.srvGetServicePriceCalculation(parameters, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let result = AMGSPCalculationResult(json: json)
            success(result)
        }, failure: {
            failure()
        })
    }
    
    func requestServicePriceEmail(order: AMGSPEmailOrder, success: @escaping ()->(), failure: @escaping ()->()) {
        
        let parameters = [
            "Email": order.email,
            "MbModelId": order.modelId,
            "ManufactureYearId": order.yearId,
            "Mileage": order.mileage,
            "CarMileage": order.carMileage,
            "ShowRoomId": order.showRoomId,
            "ServicePlusIds": order.servicePlusIds
            ] as [String : Any]
        
        API_WRAPPER.srvGetServicePriceEmail(parameters, success: { _ in
            success()
        }, failure: { 
            failure()
        })
        
    }
    
    func getInSaleClassesForDealer(dealerId: Int, orCity: Int, isNewCars: Bool, success: @escaping ([AMGObject])->(), failure: @escaping ()->()) {
        
        
        if isNewCars {
            API_WRAPPER.srvAuthorizeECF({ tokenData in
                if let token = tokenData!["access_token"] as? String {
                    API_WRAPPER.srvReadInSaleECFClasses(withToken: token, dealerId: Int32(dealerId), orCity: Int32(orCity), success: { response in
                        guard let data = response, let json = try? JSON(data: data) else {
                            failure()
                            return
                        }
                        
                        //print(json)
                        let inSaleClasses = json.compactMap { AMGObject(json: $0.1) }
                        var classes: [AMGObject] = []
                        
                        for carClass in inSaleClasses {
                            if AMGUserCar.amgInSaleNewClasses.filter({ $0.self == carClass.id }).count > 0 {
                                classes.append(carClass)
                            }
                        }
                        
                        classes = classes.sorted(by: { $1.name > $0.name })
                        success(classes)
                    }, failure: { error in
                        failure()
                    })
                } else {
                    failure()
                    return
                }
            }, failure: { error in
                failure()
            })
        } else {
            API_WRAPPER.srvReadInSaleUsedClasses(forDealer: Int32(dealerId), orCity: Int32(orCity), success: { response in
                guard let data = response, let json = try? JSON(data: data) else {
                    failure()
                    return
                }
                
                //print(json)
                let inSaleClasses = json.compactMap { AMGObject(json: $0.1) }
                var classes: [AMGObject] = []
                
                for carClass in inSaleClasses {
                    if AMGUserCar.amgInSaleUsedClasses.filter({ $0.self == carClass.id }).count > 0 {
                        classes.append(carClass)
                    }
                }
                
                classes = classes.sorted(by: { $1.name > $0.name })
                success(classes)
            }, failure: { error in
                failure()
            })
        }
    }
    
    func getInSaleCarsOfClass(classId: Int, isNews: Bool, order: String, success: @escaping ([AMGCar])->(), failure: @escaping (String)->()) {
    
        let cityID = 0 // AMGUser.shared.dealerCityId
        let dealerID = 0 // AMGUser.shared.dealerId
        
        if isNews {
            API_WRAPPER.srvAuthorizeECF({ tokenData in
                if let token = tokenData!["access_token"] as? String {
                    API_WRAPPER.srvReadSaleECFCars(withToken: token, forClassId: Int32(classId), dealerId: Int32(dealerID), cityId: Int32(cityID), sortOrder: order, success: { response in
                        
                        guard let data = response, let json = try? JSON(data: data) else {
                            failure(self.serverErrorMessage)
                            return
                        }
                        
                        let cars = json.compactMap({ AMGCar(json: $0.1, isNew: isNews) }).filter({ $0.nModel.contains("AMG") })
                        if cars.count == 0 {
                            failure("В настоящий момент в данном классе отсутствуют автомобили AMG в продаже")
                            return
                        }
                        success(cars)
                    }, failure: { _ in
                        failure(self.serverErrorMessage)
                    })
                } else {
                    failure(self.serverErrorMessage)
                }
            }, failure: { _ in
                failure(self.serverErrorMessage)
            })
        } else {
            API_WRAPPER.srvReadSaleUsedCars(forClassId: Int32(classId), dealerId: Int32(dealerID), cityId: Int32(cityID), sortOrder: order, success: { response in
                
                guard let data = response, let json = try? JSON(data: data) else {
                    failure(self.serverErrorMessage)
                    return
                }
                
                let cars = json.compactMap({ AMGCar(json: $0.1, isNew: isNews) }).filter({ $0.nModel.contains("AMG") })
                if cars.count == 0 {
                    failure("В настоящий момент в данном классе отсутствуют автомобили AMG в продаже")
                    return
                }
                success(cars)
            }, failure: { _ in
                failure(self.serverErrorMessage)
            })
        }
    }
    
    func getInSaleNewCarWithDetails(car: AMGCar, success: @escaping (AMGCar)->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvAuthorizeECF({ tokenData in
            if let token = tokenData!["access_token"] as? String {
                API_WRAPPER.srvReadSaleDetails(withToken: token, forNewCarIds: ["\(car.srvId)"], success: { response in
                    guard let data = response, let json = try? JSON(data: data) else {
                        failure()
                        return
                    }
                    
                    car.readNewCarDetails(json: json[0])
                    success(car)
                }, failure: { _ in
                    failure()
                })
            } else {
                failure()
            }
        }, failure: { _ in
            failure()
        })
    }
    
    func sendNewCarDescriptionToEmail(carID: Int, success: @escaping ()->(), failure: @escaping (String)->()) {
        
        let email = AMGUser.shared.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if email.isEmpty {
            failure("Не указан E-mail.\nВведите данные")
            return
        }
        
        API_WRAPPER.srvAuthorizeECF({ tokenData in
            if let token = tokenData!["access_token"] as? String {
                API_WRAPPER.srvSendNewCarIdInfo(withToken: token, carId: Int32(carID), onEmail: email, hideSpecialOffer: false, success: { _ in
                    success()
                }, failure: { _ in
                    failure(self.serverErrorMessage)
                })
            } else {
                failure(self.serverErrorMessage)
            }
        }, failure: { _ in
            failure(self.serverErrorMessage)
        })
    }
    
    func requestInSale(car: AMGCar, isNewCar: Bool, success: @escaping ()->(), failure: @escaping ()->()) {
        
        var parameters: [String : Any] = [:]
         
        if isNewCar {
            var consentString = "SRV,PD"
            
            if AMGUserConsent.shared.agreePhone { consentString = "\(consentString),PHONE" }
            if AMGUserConsent.shared.agreeEmail { consentString = "\(consentString),EMAIL" }
            if AMGUserConsent.shared.agreeSMS { consentString = "\(consentString),SMS" }
            
            let customFields = [
                customFieldObjectWithName("OrderType", value: 5),
                customFieldObjectWithName("UserGuid", value: AMGUser.shared.userUUID)
            ]
            
            parameters = [
                "ContactSourceSysName": "ecf-mobile-app-amg",
                "ContactSourceName": "ECF - Мобильное приложение My AMG",
                "contactsourcetype": 4,
                "salutation": AMGUser.shared.gender,
                "lastname": AMGUser.shared.lastName,
                "firstname": AMGUser.shared.firstName,
                "middlename": AMGUser.shared.middleName,
                "email": AMGUser.shared.email,
                "PhonePersonal": AMGUser.shared.phone,
                "MBClassName": car.nClass,
                "MBClassSysName": car.modelSysName,
                "MBModel":car.nModel,
                "InterestedCarCondition": "new",
                "WantsDealerConnect": true,
                "InterestTestDrive": false,
                "ShowRoomId": car.showroomId,
                "CustomFields": customFields,
                "AdditionalInformation": car.priceUrl,
                "Consents": consentString
            ]
            
        } else {
            parameters = [
                "MBCarId": "\(car.srvId)",
                "Patronimic": AMGUser.shared.middleName,
                "LastName": AMGUser.shared.lastName,
                "FirstName": AMGUser.shared.firstName,
                "Gender": AMGUser.shared.gender,
                "Phone": AMGUser.shared.phone,
                "Email": AMGUser.shared.email,
                "Comment": "Заявка из мобильного приложения My AMG",
                "DeviceType": "iPhone",
                "UserGuid": AMGUser.shared.userUUID
                ]
        }
        
        API_WRAPPER.srvSaleAutoOrder(parameters, isNew: isNewCar, success: { _ in
            success()
        }, failure: { _ in
            failure()
        })
    }
    
    func getNewCarFilter(classID: Int, cars: [AMGCar], success: @escaping (AMGNewFilter)->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvAuthorizeECF({ tokenData in
            if let token = tokenData!["access_token"] as? String {
                API_WRAPPER.srvGetECFFilters(withToken: token, classId: Int32(classID), dealer: 0, success: { response in
                    guard let data = response, let json = try? JSON(data: data) else {
                        failure()
                        return
                    }
                    
                    //print("filter = \(json)")
                    let filter = AMGNewFilter(json: json)
                    
                    var bodyColors: [AMGColorObject] = []
                    for bodyColor in filter.bodyColors {
                        if cars.filter({ $0.baseBodyColorId == bodyColor.id }).count > 0 {
                            bodyColors.append(bodyColor)
                        }
                    }
                    filter.bodyColors = bodyColors
                    
                    var salonColors: [AMGColorObject] = []
                    for salonColor in filter.salonColors {
                        if cars.filter({ $0.baseSalonFurnishId == salonColor.id }).count > 0 {
                            salonColors.append(salonColor)
                        }
                    }
                    filter.salonColors = salonColors
                    
                    var salonTypes: [AMGObject] = []
                    for salonType in filter.salonTypes {
                        if cars.filter({ $0.salonTypeId == salonType.id }).count > 0 {
                            salonTypes.append(salonType)
                        }
                    }
                    filter.salonTypes = salonTypes
                    
                    var cities: [AMGECFCity] = []
                    for city in filter.cities {
                        if cars.filter({ $0.city == city.name }).count > 0 {
                            var dealers: [AMGObject] = []
                            for dealer in city.dealers {
                                if cars.filter({ $0.city == city.name && $0.dealer == dealer.name }).count > 0 {
                                    dealers.append(dealer)
                                }
                            }
                            city.dealers = dealers
                            cities.append(city)
                        }
                    }
                    filter.cities = cities
                    
                    if let minValue = cars.map({ Double($0.cost)! }).min() {
                        filter.minimalPrice = minValue
                    }
                    
                    if let maxValue = cars.map({ Double($0.cost)! }).max() {
                        filter.maximumPrice = maxValue
                    }
                    
                    if (filter.minimalPrice == filter.maximumPrice) {
                        filter.minimalPrice = floor(filter.minimalPrice / 1000) * 1000
                        filter.maximumPrice = filter.minimalPrice + 1000
                        filter.scalePrice = 1000
                    } else {
                        filter.minimalPrice = floor(filter.minimalPrice / 1000) * 1000
                        filter.maximumPrice = floor(filter.maximumPrice / 1000) * 1000 + 1000
                        filter.scalePrice = (filter.maximumPrice - filter.minimalPrice) / 10
                    }
                    
                    filter.classId = classID
                    filter.selectedCityId = AMGUser.shared.dealerCityId
                    filter.setSelectedCityId(cityId: filter.selectedCityId)
                    //filter.selectedDealerId = AMGUser.shared.dealerId
                    success(filter)
                }, failure: { _ in
                    failure()
                })
            } else {
                failure()
            }
        }, failure: { _ in
            failure()
        })
    }
    
    func getNewCarsWithFilter(filter: AMGNewFilter, success: @escaping ([AMGCar])->(), failure: @escaping ()->()) {
        
        filter.setSortField(sortField: filter.sortField)
    
        var parameters: [String: Any] = [:]
        
        parameters["ModelId"] = filter.classId
        
        if filter.selectedMaximumPrice < filter.maximumPrice {
            parameters["MaxumumPrice"] = floor(filter.selectedMaximumPrice)
        }
        
        if filter.selectedMinimalPrice > filter.minimalPrice {
            parameters["MinimalPrice"] = floor(filter.selectedMinimalPrice)
        }
        
        if filter.selectedDealerId > 0 {
            parameters["DealerId"] = filter.selectedDealerId
        }
        
        if filter.selectedCityId > 0 {
            parameters["CityId"] = filter.selectedCityId
        }
        
        
        parameters["EngineIds"] = filter.selectedModelIds
        parameters["ColorBodyIds"] = filter.selectedBodyColors
        parameters["SalonFurnishColorIds"] = filter.selectedSalonColors
        
        if filter.selectedSalonType > 0 {
            parameters["SalonFurnishTypeIds"] = filter.selectedSalonType
        }
        
        if !filter.sortParameter.isEmpty {
            parameters["Sort"] = filter.sortParameter
            parameters["SortDirection"] = filter.sortOrder
        }
        
        
        API_WRAPPER.srvAuthorizeECF({ tokenData in
            if let token = tokenData!["access_token"] as? String {
                API_WRAPPER.srvReadECFSaleCars(withFilter: token, parameters: parameters, success: { response in
                    guard let data = response, let json = try? JSON(data: data) else {
                        failure()
                        return
                    }
                    
                    let cars = json.compactMap({ AMGCar(json: $0.1, isNew: true) }).filter({ $0.nModel.contains("AMG") })
                    success(cars)
                }, failure: { _ in
                    failure()
                })
            } else {
                failure()
            }
        }, failure: { _ in
            failure()
        })
    }
    
    func getUsedCarFilter(classID: Int, cars: [AMGCar], success: @escaping (AMGUsedFilter)->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvGetUsedFilters(forClassId: Int32(classID), dealer: 0, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            //print("filter = \(json)")
            let filter = AMGUsedFilter(json: json)
            
            var bodyColors: [AMGColorObject] = []
            for bodyColor in filter.bodyColors {
                if cars.filter({ $0.colorBody == bodyColor.name }).count > 0 {
                    bodyColors.append(bodyColor)
                }
            }
            filter.bodyColors = bodyColors
            
            var engineTypes: [AMGObject] = []
            for engineType in filter.engineTypes {
                if cars.filter({ $0.engineType == engineType.name }).count > 0 {
                    engineTypes.append(engineType)
                }
            }
            filter.engineTypes = engineTypes
            
            var drives: [AMGObject] = []
            for drive in filter.drives {
                if cars.filter({ $0.drive == drive.name }).count > 0 {
                    drives.append(drive)
                }
            }
            filter.drives = drives
            
            var cities: [AMGUsedCity] = []
            for city in filter.cities {
                if cars.filter({ $0.city == city.name }).count > 0 {
                    var dealers: [AMGObject] = []
                    for dealer in city.dealers {
                        if cars.filter({ $0.city == city.name && $0.dealer == dealer.name }).count > 0 {
                            dealers.append(dealer)
                        }
                    }
                    city.dealers = dealers
                    cities.append(city)
                }
            }
            filter.cities = cities
            
            if let minValue = cars.map({ Int($0.yearManufacture)! }).min() {
                filter.minimalYear = minValue
            }
            
            if let maxValue = cars.map({ Int($0.yearManufacture)! }).max() {
                filter.maximumYear = maxValue
            }
            
            if (filter.minimalYear == filter.maximumYear) {
                filter.minimalYear -= 1
                filter.maximumYear += 1
            }
            
            if let minValue = cars.map({ Double($0.engineVolume)! }).min() {
                filter.minimalEngineVolume = minValue
            }
            
            if let maxValue = cars.map({ Double($0.engineVolume)! }).max() {
                filter.maximumEngineVolume = maxValue
            }
            
            if (filter.minimalEngineVolume == filter.maximumEngineVolume) {
                filter.minimalEngineVolume = floor(filter.minimalEngineVolume / 100) * 100
                filter.maximumEngineVolume = filter.minimalEngineVolume + 100
                filter.scaleEngineVolume = 100
            } else {
                filter.minimalEngineVolume = floor(filter.minimalEngineVolume / 100) * 100
                filter.maximumEngineVolume = floor(filter.maximumEngineVolume / 100) * 100 + 100
                filter.scaleEngineVolume = (filter.maximumEngineVolume - filter.minimalEngineVolume) / 10
            }
            
            if let minValue = cars.map({ Double($0.run)! }).min() {
                filter.minimalRun = minValue
            }
            
            if let maxValue = cars.map({ Double($0.run)! }).max() {
                filter.maximumRun = maxValue
            }
            
            if (filter.minimalRun == filter.maximumRun) {
                filter.minimalRun = floor(filter.minimalRun / 100) * 100
                filter.maximumRun = filter.minimalRun + 100
                filter.scaleRun = 100
            } else {
                filter.minimalRun = floor(filter.minimalRun / 100) * 100
                filter.maximumRun = floor(filter.maximumRun / 100) * 100 + 100
                filter.scaleRun = (filter.maximumRun - filter.minimalRun) / 10
            }
            
            if let minValue = cars.map({ Double($0.cost)! }).min() {
                filter.minimalPrice = minValue
            }
            
            if let maxValue = cars.map({ Double($0.cost)! }).max() {
                filter.maximumPrice = maxValue
            }
            
            if (filter.minimalPrice == filter.maximumPrice) {
                filter.minimalPrice = floor(filter.minimalPrice / 1000) * 1000
                filter.maximumPrice = filter.minimalPrice + 1000
                filter.scalePrice = 1000
            } else {
                filter.minimalPrice = floor(filter.minimalPrice / 1000) * 1000
                filter.maximumPrice = floor(filter.maximumPrice / 1000) * 1000 + 1000
                filter.scalePrice = (filter.maximumPrice - filter.minimalPrice) / 10
            }
            
            filter.classId = classID
            filter.selectedCityId = AMGUser.shared.dealerCityId
            filter.setSelectedCityId(cityId: filter.selectedCityId)
            //filter.selectedDealerId = AMGUser.shared.dealerId
            success(filter)
        }, failure: { _ in
            failure()
        })
    }
    
    func getUsedCarsWithFilter(filter: AMGUsedFilter, success: @escaping ([AMGCar])->(), failure: @escaping ()->()) {
        
        filter.setSortField(sortField: filter.sortField)
        
        var parameters: [String: Any] = [:]
        
        if filter.selectedMaximumEngineVolume < filter.maximumEngineVolume {
            parameters["DisplacementMax"] = filter.selectedMaximumEngineVolume
        }
        
        if filter.selectedMinimalEngineVolume > filter.minimalEngineVolume {
            parameters["DisplacementMin"] = filter.selectedMinimalEngineVolume
        }
        
        if filter.selectedMaximumPrice < filter.maximumPrice {
            parameters["CostMax"] = floor(filter.selectedMaximumPrice)
        }
        
        if filter.selectedMinimalPrice > filter.minimalPrice {
            parameters["CostMin"] = floor(filter.selectedMinimalPrice)
        }
        
        if filter.selectedMinimalYear > filter.minimalYear {
            parameters["YearMin"] = filter.selectedMinimalYear
        }
        
        if filter.selectedMaximumYear < filter.maximumYear {
            parameters["YearMax"] = filter.selectedMaximumYear
        }
        
        if filter.selectedMinimalRun > filter.minimalRun {
            parameters["RunMin"] = floor(filter.selectedMinimalRun)
        }
        
        if filter.selectedMaximumRun < filter.maximumRun {
            parameters["RunMax"] = floor(filter.selectedMaximumRun)
        }
        
        if filter.selectedDealerId > 0 {
            parameters["DealerId"] = filter.selectedDealerId
        }
        
        if filter.selectedCityId > 0 {
            parameters["CityId"] = filter.selectedCityId
        }
        
        if filter.selectedModelId > 0 {
            parameters["ModelId"] = filter.selectedModelId
        }
        
        if filter.selectedEngineType > 0 {
            parameters["EngineTypeId"] = filter.selectedEngineType
        }
        
        if filter.selectedDrive > 0 {
            parameters["GearTypeId"] = filter.selectedDrive
        }
        
        parameters["ColorIds"] = filter.selectedBodyColors
         
        if !filter.sortParameter.isEmpty {
            parameters["Sort"] = filter.sortParameter
            parameters["SortDirection"] = filter.sortOrder
        }
        
        if filter.onlyCertified {
            parameters["mbClassId"] = "\(filter.classId)"
        }
        
        API_WRAPPER.srvReadUsedSaleCars(withFilter: parameters, classId: Int32(filter.classId), onlyCertified: filter.onlyCertified, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            
            let cars = json.compactMap({ AMGCar(json: $0.1, isNew: false) }).filter({ $0.nModel.contains("AMG") })
            success(cars)
        }, failure: { _ in
            failure()
        })
    }
    
    func updateFavouritesCars(carID: Int, isNew: Bool, del: Bool, success: @escaping ()->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvSaveFavouriteUserAuto(Int32(carID), isNew: isNew, del: del, forUser: AMGUser.shared.userUUID, success: { _ in
            success()
        }, failure: { _ in
            failure()
        })
    }
    
    func readUserFavouriteCars(newCarIds: [Int], usedCarIds: [Int], success: @escaping ([AMGCar],[AMGCar])->(), failure: @escaping ()->()) {
        
        if newCarIds.count > 0 {
            API_WRAPPER.srvAuthorizeECF({ tokenData in
                if let token = tokenData!["access_token"] as? String {
                    API_WRAPPER.srvReadSaleDetails(withToken: token, forNewCarIds: newCarIds, success: { response in
                        guard let data = response, let json = try? JSON(data: data) else {
                            failure()
                            return
                        }
                        
                        let newCars = json.compactMap({ AMGCar(json: $0.1, isNew: true) })
                        
                        if usedCarIds.count > 0 {
                            
                            API_WRAPPER.srvReadSaleDetails(forUsedCarIds: usedCarIds, success: { response in
                                guard let data = response, let json = try? JSON(data: data) else {
                                    failure()
                                    return
                                }
                                
                                let usedCars = json.compactMap({ AMGCar(json: $0.1, isNew: false) })
                                
                                success(newCars, usedCars)
                            }, failure: { _ in
                                failure()
                            })
                        } else {
                            success(newCars,[])
                        }
                    }, failure: { _ in
                        failure()
                    })
                } else {
                    failure()
                }
            }, failure: { _ in
                failure()
            })
        } else if usedCarIds.count > 0 {
            API_WRAPPER.srvReadSaleDetails(forUsedCarIds: usedCarIds, success: { response in
                guard let data = response, let json = try? JSON(data: data) else {
                    failure()
                    return
                }
                
                let usedCars = json.compactMap({ AMGCar(json: $0.1, isNew: false) }).filter({ $0.nModel.contains("AMG") })
                
                success([], usedCars)
            }, failure: { _ in
                failure()
            })
        } else {
            success([],[])
        }
    }
    
    func getOrderStatus(orderDealerNumber: String, orderNumber: String, success: @escaping ()->(), failure: @escaping ()->()) {
        
        API_WRAPPER.srvOrderStatus(orderDealerNumber, orderNumber: orderNumber, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            success()
        }, failure: { error in
            failure()
        })
    }
    
    func getPartSearch(order: AMGPartSearch, success: @escaping (AMGPartSearch)->(), failure: @escaping ()->()) {
    
        let parameters = [
                "article": order.article,
                "guid": AMGUser.shared.userUUID,
                "latitude": order.latitude,
                "longitude": order.longitude
            ] as [String : Any]
        
        API_WRAPPER.srvPartSearch(parameters, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let result = AMGPartSearch(json: json)
            success(result)
        }, failure: { error in
            failure()
        })
    }
    
    func getPartsSearch(order: AMGPartSearch, success: @escaping (AMGPartsSearch)->(), failure: @escaping ()->()) {
        
        APIWrapper().srvGetParts(order: order, success: { response in
            guard let data = response, let json = try? JSON(data: data) else {
                failure()
                return
            }
            let result = AMGPartsSearch(json: json)
            success(result)
        }, failure: { error in
            failure()
        })
    }
    
    func getPartsSearchHistory(success: @escaping ([AMGPartSearch])->()) {
        
        API_WRAPPER.srvPartSearchHistory(forUser: AMGUser.shared.userUUID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else { return }
            
            let parts = json.compactMap { AMGPartSearch(json: $0.1) }
            for part in parts { part.isHistory = true }
            success(parts)
        }, failure: { _ in })
    }
    
    func addPartInHistory(article: String) {
        
        let parameters = [
            "Guid": AMGUser.shared.userUUID,
            "Article": article
        ]
        
        API_WRAPPER.srvPartAddArticle(parameters, success: { _ in }, failure: { _ in })
    }
    
    func customFieldObjectWithName(_ name: String, value: Any) -> Dictionary<String, Any> {
        let customField = [
            "FieldName": name,
            "FieldValue": value
        ]
        return customField
    }

}

//
//  AMGNewsManager.swift
//  MyAMG
//
//  Created by Сергей Никитин on 23/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Notification.Name {
    static let onGetNews = Notification.Name("on-get-new")
}

class AMGNewsManager {
    
    let serverErrorMessage = "Ошибка при обращении к серверу. Попробуйте повторить позже"
    
    func getNews(refreshControl: UIRefreshControl) {
        
        let parameters = [
            "guid" : AMGUser.shared.userUUID,
            "deviceToken" : AMGUser.shared.token
        ]
        
        API_WRAPPER.srvReadNews(parameters, success: { response in
            guard let data = response, let json = try? JSON(data: data) else { return }
            
            //print(json)
            let news = AMGNews(json: json["News"])
            AMGNews.shared.setNews(news: news.news)
            AMGNews.shared.saveNews()
            NotificationCenter.default.post(name: .onGetNews, object: nil)
            refreshControl.endRefreshing()
        }, failure: { _ in
            refreshControl.endRefreshing()
        })
    }
    
    func confirmNews(news: AMGOneNews, newsID: Int, isConfirmed: Bool, selectedDate: Date?, success: @escaping ()->(), failure: @escaping ()->()) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        var parameters = [
            "NewsId": Int32(newsID),
            "IsConfirmed": isConfirmed,
            "DeviceToken": AMGUser.shared.defaultDeviceToken,
            "userGuid": AMGUser.shared.userUUID
        ] as [String : Any]
    
        if let date = selectedDate { parameters["RegistrationDate"] = dateFormatter.string(from: date) }
        
        API_WRAPPER.srvConfirmNews(forUser: AMGUser.shared.userUUID, parameters: parameters, success: { _ in
            
            if isConfirmed {
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = selectedDate {
                    news.userRegistrationDate = dateFormatter.string(from: date)
                } else {
                    
                }
            } else {
                news.userRegistrationDate = ""
            }
            news.isConfirmed = isConfirmed
            news.showConfirmation = false
            
            success()
        }, failure: { _ in
            failure()
        })
    }
}

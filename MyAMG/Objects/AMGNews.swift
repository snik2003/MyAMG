//
//  AMGOneNews.swift
//  MyAMG
//
//  Created by Сергей Никитин on 24/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON

final class AMGNews: Codable {
    
    static let shared = AMGNews(json: JSON.null)
    
    var news: [AMGOneNews] = []
    
    init(json: JSON) {
        self.news = json.compactMap { AMGOneNews(json: $0.1) }
    }
    
    func setNews(news: [AMGOneNews]) {
        AMGNews.shared.news = news
    }
    
    func saveNews() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(AMGNews.shared) {
            UserDefaults.standard.set(encoded, forKey: "AMGNews")
        }
    }
    
    func loadNews() {
        if let data = UserDefaults.standard.object(forKey: "AMGNews") as? Data {
            let decoder = JSONDecoder()
            if let news = try? decoder.decode(AMGNews.self, from: data) {
                AMGNews.shared.setNews(news: news.news)
            }
        }
    }
    
    func removeNews() {
        UserDefaults.standard.removeObject(forKey: "AMGNews")
    }
}

class AMGOneNews: Codable {
    
    var text = ""
    var dealerName = ""
    var image = ""
    var dataImage = ""
    var userRegistrationDate = ""
    var keyVisualSubTitle = ""
    var dealerId = 0
    var redirectBtnValue = ""
    var title = ""
    var showConfirmation = false
    var appeal = 0
    var newsTypeId = 0
    var dateTimeCreate = ""
    var userInfo = ""
    var callBtnTelefon = ""
    var registrationDateEnd = ""
    var images: [AMGNewsImage] = []
    var onMainScreen = false
    var redirectUrl = ""
    var dateTimeCreateString = ""
    var id = 0
    var registrationDateBegin = ""
    var content: [AMGNewsContent] = []
    var isAlert = false
    var keyVisualTitle = ""
    var isConfirmed = false
    
    init(json: JSON) {
        self.images = json["Images"].compactMap { AMGNewsImage(json: $0.1) }
        self.content = json["Content"].compactMap { AMGNewsContent(json: $0.1) }
        
        self.text = json["Text"].stringValue
        self.dealerName = json["DealerName"].stringValue
        self.image = json["Image"].stringValue
        self.userRegistrationDate = json["UserRegistrationDate"].stringValue
        self.keyVisualSubTitle = json["KeyVisualSubTitle"].stringValue
        self.dealerId = json["DealerId"].intValue
        self.redirectBtnValue = json["RedirectBtnValue"].stringValue
        self.title = json["Title"].stringValue
        self.showConfirmation = json["IsUnconfirmedNotice"].boolValue
        self.appeal = json["Appeal"].intValue
        self.newsTypeId = json["NewsTypeId"].intValue
        self.dateTimeCreate = json["DateTimeCreate"].stringValue
        self.userInfo = json["UserInfo"].stringValue
        self.callBtnTelefon = json["CallBtnTelefon"].stringValue
        self.registrationDateEnd = json["RegistrationDateEnd"].stringValue
        self.onMainScreen = json["OnMainScreen"].boolValue
        self.redirectUrl = json["RedirectUrl"].stringValue
        self.dateTimeCreateString = json["DateTimeCreateString"].stringValue
        self.id = json["Id"].intValue
        self.registrationDateBegin = json["RegistrationDateBegin"].stringValue
        self.isAlert = json["IsAlert"].boolValue
        self.keyVisualTitle = json["KeyVisualTitle"].stringValue
        self.isConfirmed = json["IsConfirmed"].boolValue
        
        
        if self.image.isEmpty {
            if let cont = self.content.filter({ $0.typeString == "Image"}).first,
                let image1 = cont.images.first { self.image = image1.url }
        }
        
        self.dataImage = ""
    }
}

class AMGNewsImage: Codable {
    var url = ""
    var width = 0.0
    var height = 0.0
    
    init(json: JSON) {
        
        self.url = json["Url"].stringValue
        self.width = json["Width"].doubleValue
        self.height = json["Height"].doubleValue
    }
}

class AMGNewsContent: Codable {
    
    var images: [AMGNewsImage] = []
    var confirmMessageTitle = ""
    var sectionIndex = 0
    var trueConfirmText = ""
    var text = ""
    var url = ""
    var phoneNumber = ""
    var typeString = ""
    var confirmMessage = ""
    var confirmText = ""
    var notConfirmText = ""
    
    init(json: JSON) {
        self.images = json["Images"].compactMap { AMGNewsImage(json: $0.1) }
        self.confirmMessageTitle = json["ConfirmMessageTitle"].stringValue
        self.sectionIndex = json["SectionIndex"].intValue
        self.trueConfirmText = json["TrueConfirmText"].stringValue
        self.text = json["Text"].stringValue
        self.url = json["Url"].stringValue
        self.phoneNumber = json["PhoneNumber"].stringValue
        self.typeString = json["Type"].stringValue
        self.confirmMessage = json["ConfirmMessage"].stringValue
        self.confirmText = json["ConfirmText"].stringValue
        self.notConfirmText = json["NotConfirmText"].stringValue
    }
}

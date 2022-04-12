//
//  AMGPushConfigurator.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import UserNotifications

final class AMGPushConfigurator {
    
    static let defaultConfigurator = AMGPushConfigurator()
    
    func askForPushNotifications() {

        if AMGSettings.shared.askForPush { return }
        
        let alertVC = AMGAlertController()
        
        alertVC.typeAlert = TypeAlert.AlertWithDoubleActions;
        
        alertVC.header = "Push-уведомления"
        alertVC.message = "Вы согласны получать уведомления о новостях и спец. предложениях?"
        
        alertVC.action1Completion = {
            self.setPushAdvertisingAsked()
            self.registerForPushNotifications()
        }
        alertVC.action1Name = "Да"
        
        alertVC.action2Completion = {
            self.setPushAdvertisingAsked()
        }
        alertVC.action2Name = "Нет, спасибо"
        
        OperationQueue.main.addOperation {
            alertVC.modalPresentationStyle = .overCurrentContext
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func setPushAdvertisingAsked() {
        AMGSettings.shared.askForPush = true
        AMGSettings.shared.saveSettings()
    }
    
    func unregisterdForPushNotification() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func registerForPushNotifications() {

        let notificationCenter = UNUserNotificationCenter.current()
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        
        notificationCenter.requestAuthorization(options: options) { didAllow, error in
            
            if !didAllow {
                print("User has declined notifications")
                return
            }
            
            if let err = error {
                print("Push registration FAILED")
                print("ERROR: \(err.localizedDescription)")
            } else {
                OperationQueue.main.addOperation {
                    UIApplication.shared.registerForRemoteNotifications()
                    AMGSettings.shared.pushOn = true
                    AMGSettings.shared.saveSettings()
                }
                print("Push registration SUCCESS")
            }
        }
    }
}

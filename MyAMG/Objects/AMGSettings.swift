//
//  AMGSettings.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import Foundation
import SwiftyJSON
import LocalAuthentication

final class AMGSettings: Codable {
    
    static let shared = AMGSettings()

    static let isBiometricModeOn = true
    
    var askForPush = false
    var pushOn = false
    var soundOn = true
    var biometricsOn = false
    var biometricsLogin = ""
    var biometricsText = ""
    
    func setSettings(_ settings: AMGSettings) {
        self.askForPush = settings.askForPush
        self.pushOn = settings.pushOn
        self.soundOn = settings.soundOn
        self.biometricsOn = settings.biometricsOn
        self.biometricsLogin = settings.biometricsLogin
        self.biometricsText = settings.biometricsText
    }
    
    func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(AMGSettings.shared) {
            UserDefaults.standard.set(encoded, forKey: "AMGSettings")
        }
    }
    
    func loadSettings() {
        if let data = UserDefaults.standard.object(forKey: "AMGSettings") as? Data {
            let decoder = JSONDecoder()
            if let settings = try? decoder.decode(AMGSettings.self, from: data) {
                AMGSettings.shared.setSettings(settings)
            }
        }
    }
    
    func removeBiometricsSettings() {
        AMGSettings.shared.biometricsOn = false
        AMGSettings.shared.biometricsLogin = ""
        AMGSettings.shared.biometricsText = ""
        AMGSettings.shared.saveSettings()
    }
    
    func isTouchIDAvialable() -> Bool {
        
        if !AMGSettings.isBiometricModeOn { return false }
        
        var error: NSError?
        let context = LAContext()
        
        if #available(iOS 11.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if context.biometryType == .touchID {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isFaceIDAvialable() -> Bool {
        
        if !AMGSettings.isBiometricModeOn { return false }
        
        var error: NSError?
        let context = LAContext()
        
        if #available(iOS 11.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if context.biometryType == .faceID {
                    return true
                }
            }
        }
        
        return false
    }
}

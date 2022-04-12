//
//  UITextField+extension.swift
//  MyAMG
//
//  Created by Сергей Никитин on 15/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

extension UITextField {
    
    func isPhoneValid() -> Bool {
        if let text = self.text, text.count == 18 {
            return true
        }
        
        return false
    }
    
    func getPhone() -> String {
        return self.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }

}

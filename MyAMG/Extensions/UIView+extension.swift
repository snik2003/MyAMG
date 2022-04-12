//
//  UIView+extension.swift
//  MyAMG
//
//  Created by Сергей Никитин on 14/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

extension UIView {
    
    func setStatusSeparator(isValidated: Bool) {
        if (isValidated) {
            self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        } else {
            self.backgroundColor = .red
        }
    }
}

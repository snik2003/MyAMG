//
//  AMGTitleLabel.swift
//  MyAMG
//
//  Created by Сергей Никитин on 19/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class AMGTitleLabel: UILabel {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let line = UIView()
        line.frame = CGRect(x: 0, y: 0, width: 32, height: 1)
        line.backgroundColor = UIColor(red: 217/255, green: 37/255, blue: 43/255, alpha: 1)
        self.addSubview(line)
    }
}

//
//  SertificateCell.swift
//  MyAMG
//
//  Created by Сергей Никитин on 05/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class SertificateCell: UITableViewCell {

    var nameLabel = UILabel()
    var priceLabel = UILabel()
    var marker = UIImageView()
    var separator = UIView()
    
    let selectedMarker = UIImage(named: "check-marker")
    let deselectedMarker = UIImage(named: "uncheck-marker")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        nameLabel.frame = CGRect(x: 20, y: 2, width: bounds.width/2 + 40, height: 44)
        nameLabel.textColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
        self.addSubview(nameLabel)
        
        priceLabel.frame = CGRect(x: bounds.width/2 + 60, y: 2, width: bounds.width/2 - 105, height: 44)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .right
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.5
        priceLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
        self.addSubview(priceLabel)
        
        marker.frame = CGRect(x: bounds.width - 33, y: 17, width: 13, height: 10)
        marker.tintColor = UIColor(red: 0.85, green: 0.15, blue: 0.17, alpha: 1)
        self.addSubview(marker)
        
        separator.frame = CGRect(x: 20, y: 47, width: bounds.width - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.addSubview(separator)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .gray
        let bgColorView = UIView()
        
        if selected {
            marker.image = selectedMarker
            bgColorView.backgroundColor = UIColor(red: 0.85, green: 0.15, blue: 0.17, alpha: 0.1)
        } else {
            marker.image = deselectedMarker
            bgColorView.backgroundColor = .clear
        }
        
        self.selectedBackgroundView = bgColorView
        self.layoutSubviews()
    }
}

//
//  AMGTableViewCell.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class AMGTableViewCell: UITableViewCell {

    var isValidated = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValidated(validated: Bool) {
        isValidated = validated
    }

}

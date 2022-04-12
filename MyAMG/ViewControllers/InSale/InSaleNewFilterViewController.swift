//
//  InSaleNewFilterViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class InSaleCarFilterViewController: InnerViewController {

    var selectedClass: AMGObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Фильтр"
    }
}

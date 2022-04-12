//
//  ServiceCalcDetailViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 17/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class ServiceCalcDetailViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "service_calculator_all_options"
    
    var options: [AMGServicePriceOption] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "detailCell")
        titleLabel.text = "Список услуг"
    }
    
    override func closeButtonAction(sender: UIButton) {
        showAlertWithDoubleActions(title: "Внимание!", text: "Ваши изменения не будут сохранены.\nВы уверены, что хотите выйти?", title1: "Нет", title2: "Да", completion: {}, completion2: {
            
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                if let vc = tabbarController.selectedViewController as? TabItemViewController {
                    vc.fadeView.isHidden = false
                }
            }
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for subview in cell.subviews {
            if subview.tag == 123 { subview.removeFromSuperview() }
        }
        
        let nameLabel = UILabel()
        nameLabel.tag = 123
        nameLabel.frame = CGRect(x: 20, y: 2, width: screenWidth - 60, height: 44)
        nameLabel.numberOfLines = 0
        nameLabel.text = option.name
        nameLabel.textColor = .black
        nameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        cell.addSubview(nameLabel)
        
        let marker = UIImageView()
        marker.tag = 123
        marker.tintColor = UIColor(red: 0.85, green: 0.15, blue: 0.17, alpha: 1)
        marker.frame = CGRect(x: screenWidth - 33, y: 17, width: 13, height: 10)
        marker.image = UIImage(named: "check-marker")
        cell.addSubview(marker)
        
        let separator = UIView()
        separator.tag = 123
        separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        cell.addSubview(separator)
        
        cell.selectionStyle = .none
        return cell
    }
}

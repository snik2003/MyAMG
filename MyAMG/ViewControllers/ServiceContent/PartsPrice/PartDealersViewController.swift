//
//  PartDealersViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class PartDealersViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var part: AMGPartSearch!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "partCell")
        
        titleLabel.text = "Наличие"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return part.stocks.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for subview in cell.subviews {
            if subview.tag == 123 { subview.removeFromSuperview() }
        }
        
        let stock = part.stocks[indexPath.row]
        
        let view = UIView()
        view.tag = 123
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 88)
        view.backgroundColor = .clear
        cell.addSubview(view)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 88))
        button.tag = indexPath.row
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(showPartInDealer(sender:)), for: .touchUpInside)
        view.addSubview(button)
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 20, y: 0, width: screenWidth - 60, height: 48)
        nameLabel.text = stock.stockName
        nameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.contentScaleFactor = 8
        nameLabel.textAlignment = .left
        nameLabel.textColor = .black
        button.addSubview(nameLabel)
        
        let addressLabel = UILabel()
        addressLabel.frame = CGRect(x: 20, y: 48, width: screenWidth - 60, height: 17)
        addressLabel.text = stock.address
        addressLabel.font = UIFont(name: "DaimlerCS-Regular", size: 14)
        addressLabel.numberOfLines = 0
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.contentScaleFactor = 8
        addressLabel.textAlignment = .left
        addressLabel.textColor = UIColor(white: 0.55, alpha: 1)
        button.addSubview(addressLabel)
        
        let priceLabel = UILabel()
        priceLabel.frame = CGRect(x: 20, y: 65, width: screenWidth - 60, height: 17)
        priceLabel.text = "\(priceToString(priceString: stock.price)) (\(stock.partsInStock) шт.)"
        priceLabel.font = UIFont(name: "DaimlerCS-Regular", size: 14)
        priceLabel.numberOfLines = 0
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.contentScaleFactor = 7
        priceLabel.textAlignment = .left
        priceLabel.textColor = UIColor(white: 0.55, alpha: 1)
        button.addSubview(priceLabel)
        
        let arrowImage = UIImageView()
        arrowImage.frame = CGRect(x: screenWidth - 28, y: 37.5, width: 8, height: 13)
        arrowImage.image = UIImage(named: "rightArrow")
        button.addSubview(arrowImage)
        
        let separator = UIView()
        
        separator.frame = CGRect(x: 20, y: 87, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        button.addSubview(separator)
        
        return cell
    }
    
    @objc func showPartInDealer(sender: UIButton) {
        let detailVC = PartInDealerViewController()
        detailVC.part = self.part
        detailVC.stock = self.part.stocks[sender.tag]
        detailVC.modalPresentationStyle = .overCurrentContext
        self.present(detailVC, animated: true, completion: nil)
    }
}

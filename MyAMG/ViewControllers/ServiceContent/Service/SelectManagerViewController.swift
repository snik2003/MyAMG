//
//  SelectManagerViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 01/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class SelectManagerViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: ServiceOrderViewController!
    var managers: [AMGServiceManager] = []
    
    var photoCache: [IndexPath: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "managerCell")
        
        bChangedFormData = true
        titleLabel.text = "Выберите менеджера"
    }

    override func backButtonAction(sender: UIButton) {
        self.dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managers.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "managerCell", for: indexPath)
        cell.backgroundColor = .clear
        
        let manager = managers[indexPath.row]
        
        for view in cell.subviews {
            if view is UIButton { view.removeFromSuperview() }
        }
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 110))
        button.tag = indexPath.row
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(selectManagerAction(sender:)), for: .touchUpInside)
        cell.addSubview(button)
        
        let photo = UIImageView()
        photo.tag = 123
        photo.frame = CGRect(x: 20, y: 15, width: 80, height: 80)
        button.addSubview(photo)
        
        if let image = photoCache[indexPath] {
            photo.image = image
        } else {
            let getCacheImage = GetCacheImage(url: manager.image, lifeTime: .userWallImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    if let image = getCacheImage.outputImage {
                        self.photoCache[indexPath] = image
                        photo.image = image
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 120, y: 15, width: screenWidth - 140, height: 24)
        nameLabel.text = manager.name
        nameLabel.textColor = .black
        nameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 14)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.textAlignment = .left
        button.addSubview(nameLabel)
        
        let label1 = UILabel()
        label1.frame = CGRect(x: 120, y: 55, width: 64, height: 19)
        label1.text = "Будние:"
        label1.textColor = UIColor(white: 0, alpha: 0.3)
        label1.font = UIFont(name: "DaimlerCS-Regular", size: 13)
        label1.adjustsFontSizeToFitWidth = true
        label1.minimumScaleFactor = 0.5
        label1.textAlignment = .left
        button.addSubview(label1)
        
        let label11 = UILabel()
        label11.frame = CGRect(x: 186, y: 55, width: screenWidth - 206, height: 19)
        label11.text = "\(manager.workweekWorkTimeFrom) - \(manager.workweekWorkTimeTo)"
        label11.textColor = .black
        label11.font = UIFont(name: "DaimlerCS-Regular", size: 13)
        label11.adjustsFontSizeToFitWidth = true
        label11.minimumScaleFactor = 0.5
        label11.textAlignment = .left
        button.addSubview(label11)
        
        let label2 = UILabel()
        label2.frame = CGRect(x: 120, y: 76, width: 64, height: 19)
        label2.text = "Выходные:"
        label2.textColor = UIColor(white: 0, alpha: 0.3)
        label2.font = UIFont(name: "DaimlerCS-Regular", size: 13)
        label2.adjustsFontSizeToFitWidth = true
        label2.minimumScaleFactor = 0.5
        label2.textAlignment = .left
        button.addSubview(label2)
        
        let label22 = UILabel()
        label22.frame = CGRect(x: 186, y: 76, width: screenWidth - 206, height: 19)
        label22.text = "\(manager.weekendWorkTimeFrom) - \(manager.weekendWorkTimeTo)"
        label22.textColor = .black
        label22.font = UIFont(name: "DaimlerCS-Regular", size: 13)
        label22.adjustsFontSizeToFitWidth = true
        label22.minimumScaleFactor = 0.5
        label22.textAlignment = .left
        button.addSubview(label22)
        
        let separator = UIView()
        separator.frame = CGRect(x: 20, y: 109, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        button.addSubview(separator)
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func selectManagerAction(sender: UIButton) {
        
        let manager = managers[sender.tag]
        
        delegate.managerCell.setValidated(validated: true)
        delegate.selectedManager = manager
        delegate.managerLabel.text = manager.name
        delegate.managerLabel.textColor = .black
        
        delegate.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

//
//  Tab2ViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class Tab2ViewController: TabItemViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "in_sale_controller"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBOutlet var headerCell: UITableViewCell!
    
    var isNew = true
    
    var classesNews: [AMGObject] = []
    var classesUsed: [AMGObject] = []
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "classCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "favouriteCell")
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = AMGButton()._color
        //tableView.addSubview(refreshControl)
        
        segmented.layer.cornerRadius = 0
        segmented.layer.borderWidth = 0;
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:10)!,NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:11)!,NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmented.removeBorders()
        
        //segmented.selectedSegmentIndex = AMGUser.shared.email == AMGUser.testAccount ? 1 : 0
        segmented.selectedSegmentIndex = 0
        loadClasses()
    }
    
    @objc func pullToRefresh() {
        classesNews.removeAll()
        classesUsed.removeAll()
        loadClasses()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isNew ? 1 + classesNews.count : 1 + classesUsed.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 90 + 2 * screenWidth / 3
        default:
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return headerCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for view in cell.subviews {
                if view is UIButton { view.removeFromSuperview() }
            }
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 48))
            button.tag = indexPath.row - 1
            button.setTitle("", for: .normal)
            button.addTarget(self, action: #selector(selectClassAction(sender:)), for: .touchUpInside)
            cell.addSubview(button)
            
            let classLabel = UILabel()
            classLabel.frame = CGRect(x: 20, y: 0, width: screenWidth - 43, height: 48)
            
            if isNew { classLabel.text = classesNews[indexPath.row - 1].name }
            else { classLabel.text = classesUsed[indexPath.row - 1].name }
            
            classLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            classLabel.adjustsFontSizeToFitWidth = true
            classLabel.minimumScaleFactor = 0.5
            classLabel.textAlignment = .left
            classLabel.textColor = .white
            button.addSubview(classLabel)
            
            let arrowImage = UIImageView()
            arrowImage.frame = CGRect(x: screenWidth - 28, y: 17.5, width: 8, height: 13)
            arrowImage.image = UIImage(named: "rightArrow")
            button.addSubview(arrowImage)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
            separator.backgroundColor = UIColor(white: 1, alpha: 0.2)
            button.addSubview(separator)
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @IBAction func favouriteCarsAction() {
        
        let alert = UIAlertController(title: "Избранные автомобили:", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Новые автомобили AMG", style: .default, handler: { action in
            if AMGFavouriteCars.shared.newCars.count == 0 {
                self.showAttention(message: "В разделе \"Избранное\" отсутствуют новые автомобили AMG")
                self.fadeView.isHidden = true
                return
            }
            
            let carsVC = InSaleCarListViewController()
            carsVC.cars = AMGFavouriteCars.shared.newCars
            carsVC.isNew = true
            carsVC.isFavouriteMode = true
            carsVC.modalPresentationStyle = .overCurrentContext
            self.present(carsVC, animated: true, completion: { self.fadeView.isHidden = false })
        })
        alert.addAction(action1)
        
        let action2 = UIAlertAction(title: "Автомобили AMG с пробегом", style: .default, handler: { action in
            if AMGFavouriteCars.shared.usedCars.count == 0 {
                self.showAttention(message: "В разделе \"Избранное\" отсутствуют автомобили AMG с пробегом")
                self.fadeView.isHidden = true
                return
            }
            
            let carsVC = InSaleCarListViewController()
            carsVC.cars = AMGFavouriteCars.shared.usedCars
            carsVC.isNew = false
            carsVC.isFavouriteMode = true
            carsVC.modalPresentationStyle = .overCurrentContext
            self.present(carsVC, animated: true, completion: { self.fadeView.isHidden = false })
        })
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    @objc func selectClassAction(sender: UIButton) {
        
        let selectedClass = isNew ? classesNews[sender.tag] : classesUsed[sender.tag]
        
        showHUD()
        AMGDataManager().getInSaleCarsOfClass(classId: selectedClass.id, isNews: isNew, order: "", success: { cars in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                let parameters = self.isNew ? ["action":"in_sale_new_cars"] : ["action":"in_sale_used_cars"]
                self.YMReport(message: self.screenName, parameters: parameters)
                
                let carsVC = InSaleCarListViewController()
                carsVC.cars = cars
                carsVC.isNew = self.isNew
                carsVC.selectedClass = selectedClass
                carsVC.modalPresentationStyle = .overCurrentContext
                self.present(carsVC, animated: true, completion: { self.fadeView.isHidden = false })
            }
        }, failure: { errorMessage in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.YMReport(message: self.screenName, parameters: ["error": errorMessage])
                self.showAttention(message: errorMessage)
            }
        })
    }
    
    func loadClasses() {
        refreshControl.endRefreshing()
        isNew = segmented.selectedSegmentIndex == 0 ? true : false
        
        if isNew && classesNews.count > 0 {
            tableView.reloadData()
            return
        }
        
        if !isNew && classesUsed.count > 0 {
            tableView.reloadData()
            return
        }
        
        tableView.reloadData()
        
        let cityId = 0 // AMGUser.shared.dealerCityId
        let dealerId = 0 // AMGUser.shared.dealerId
        
        showHUD()
        AMGDataManager().getInSaleClassesForDealer(dealerId: dealerId, orCity: cityId, isNewCars: isNew, success: { classes in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                if self.isNew { self.classesNews = classes }
                else { self.classesUsed = classes }
                
                self.tableView.reloadData()
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func segmentedControlValueChanged() {
        loadClasses()
    }
}

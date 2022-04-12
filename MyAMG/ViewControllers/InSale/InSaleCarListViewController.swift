//
//  InSaleCarListViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class InSaleCarListViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "in_sale_cars_list"
    
    var isNew = true
    var cars: [AMGCar] = []
    var selectedClass: AMGObject!
    var isFavouriteMode = false
    
    var newFilter: AMGNewFilter!
    var usedFilter: AMGUsedFilter!
    
    @IBOutlet weak var tableView: UITableView!
    
    let numberFormatter = NumberFormatter()
    let runNumberFormatter = NumberFormatter()
    
    var cacheImages: [IndexPath: UIImage] = [:]
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        backButton.isHidden = true
        
        if isFavouriteMode {
            titleLabel.text = "Избранное"
            //titleLabel.text = isNew ? "Избранное (новые)" : "Избранное (с пробегом)"
            filterButton.isHidden = true
            filterButtonTopConstraint.constant = 52
            filterButtonHeightConstraint.constant = 0
        } else {
            titleLabel.text = selectedClass.name
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "carCell")
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.maximumFractionDigits = 0
        
        runNumberFormatter.numberStyle = .decimal
        runNumberFormatter.maximumFractionDigits = 0
    }

    func updateCarList() {
        if isFavouriteMode {
            cacheImages.removeAll()
            cars = isNew ? AMGFavouriteCars.shared.newCars : AMGFavouriteCars.shared.usedCars
            tableView.reloadData()
            if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isNew ? 104 : 128
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for view in cell.subviews {
            if view is UIButton { view.removeFromSuperview() }
        }
        
        let car = cars[indexPath.section]
        
        let cellHeight: CGFloat = isNew ? 104 : 128
        
        let imageWidth = screenWidth * 0.4
        var imageHeight = imageWidth * 3 / 5
        
        if imageHeight > cellHeight { imageHeight = cellHeight }
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: cellHeight))
        button.tag = indexPath.section
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(selectCarAction(sender:)), for: .touchUpInside)
        cell.addSubview(button)
        
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 20, y: 0, width: imageWidth, height: imageHeight)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        button.addSubview(imageView)
        
        let activity = UIActivityIndicatorView()
        activity.frame = CGRect(x: imageView.bounds.width/2 - 10, y: cellHeight/2 - 17.5, width: 20, height: 20)
        activity.style = .white
        activity.color = AMGButton()._color
        activity.stopAnimating()
        activity.hidesWhenStopped = true
        imageView.addSubview(activity)
        
        if let image = cacheImages[indexPath] {
            imageView.image = image
        } else {
            activity.startAnimating()
            let getCacheImage = GetCacheImage(url: car.listImage, lifeTime: .userWallImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    if let image = getCacheImage.outputImage {
                        self.cacheImages[indexPath] = image
                        imageView.image = image
                        activity.stopAnimating()
                    } else {
                        imageView.image = UIImage(named: "carPlaceholder3")
                        activity.stopAnimating()
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        let workWidth = screenWidth - imageWidth - 70
        let size = CGSize(width: workWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14)]
    
        var modelLabelHeight = car.nModel.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        
        if modelLabelHeight < 20  { modelLabelHeight = 16 }
        else { modelLabelHeight = 32 }
        
        
        let modelLabel = UILabel()
        modelLabel.frame = CGRect(x: imageWidth + 35, y: 0, width: workWidth, height: modelLabelHeight)
        modelLabel.text = car.nModel
        modelLabel.font = UIFont(name: "DaimlerCS-Regular", size: 14)
        modelLabel.textColor = UIColor(white: 1, alpha: 0.6)
        modelLabel.numberOfLines = 0
        modelLabel.adjustsFontSizeToFitWidth = true
        modelLabel.minimumScaleFactor = 0.5
        button.addSubview(modelLabel)
        
        if !isNew {
            var topY = 10 + modelLabelHeight
            if modelLabelHeight == 16 { topY += 16 }
            
            let yearNameLabel = UILabel()
            yearNameLabel.frame = CGRect(x: imageWidth + 35, y: topY, width: 50, height: 19)
            yearNameLabel.text = "Год:"
            yearNameLabel.textColor = UIColor(white: 1, alpha: 0.5)
            yearNameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 13)
            button.addSubview(yearNameLabel)
            
            let yearLabel = UILabel()
            yearLabel.frame = CGRect(x: imageWidth + 85, y: topY, width: workWidth - 50, height: 19)
            yearLabel.text = car.yearManufacture
            yearLabel.textColor = .white
            yearLabel.font = UIFont(name: "DaimlerCS-Regular", size: 13)
            button.addSubview(yearLabel)
            
            topY += 19
            
            let mileageNameLabel = UILabel()
            mileageNameLabel.frame = CGRect(x: imageWidth + 35, y: topY, width: 50, height: 19)
            mileageNameLabel.text = "Пробег:"
            mileageNameLabel.textColor = UIColor(white: 1, alpha: 0.5)
            mileageNameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 13)
            button.addSubview(mileageNameLabel)
            
            let mileageLabel = UILabel()
            mileageLabel.frame = CGRect(x: imageWidth + 85, y: topY, width: workWidth - 50, height: 19)
            mileageLabel.text = "0 км"
            if let runNumber = runNumberFormatter.number(from: car.run), let run = runNumberFormatter.string(from: runNumber) {
                mileageLabel.text = "\(run) км"
            }
            mileageLabel.textColor = .white
            mileageLabel.font = UIFont(name: "DaimlerCS-Regular", size: 13)
            button.addSubview(mileageLabel)
        }
        
        let priceLabel = UILabel()
        priceLabel.frame = CGRect(x: imageWidth + 35, y: cellHeight - 39, width: workWidth, height: 24)
        priceLabel.text = "\(car.cost) ₽"
        if let cost = numberFormatter.number(from: car.cost), let price = numberFormatter.string(from: cost) {
            priceLabel.text = "\(price) ₽"
        }
        priceLabel.font = UIFont(name: "DaimlerCS-Regular", size: 22)
        priceLabel.textColor = .white
        priceLabel.numberOfLines = 1
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.5
        button.addSubview(priceLabel)
        
        
        let arrowImage = UIImageView()
        arrowImage.frame = CGRect(x: screenWidth - 28, y: cellHeight/2 - 14, width: 8, height: 13)
        arrowImage.image = UIImage(named: "rightArrow")
        button.addSubview(arrowImage)
        
        
        let separator = UIView()
        separator.frame = CGRect(x: 20, y: cellHeight - 1, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0.3, alpha: 1)
        button.addSubview(separator)
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func selectCarAction(sender: UIButton) {
        if isNew {
            let car = cars[sender.tag]
            
            showHUD()
            AMGDataManager().getInSaleNewCarWithDetails(car: car, success: { detailCar in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    let carVC = InSaleNewCarDetailViewController()
                    carVC.car = detailCar
                    carVC.isFavouriteMode = self.isFavouriteMode
                    carVC.delegate = self
                    carVC.modalPresentationStyle = .overCurrentContext
                    self.present(carVC, animated: true, completion: nil)
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["serverError":"getInSaleNewCarWithDetails"])
                    self.showServerError()
                }
            })
        } else {
            let carVC = InSaleCarDetailViewController()
            carVC.car = cars[sender.tag]
            carVC.isFavouriteMode = isFavouriteMode
            carVC.delegate = self
            carVC.modalPresentationStyle = .overCurrentContext
            self.present(carVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func openFilterAction() {
        if isNew {
            if (newFilter == nil) {
                showHUD()
                AMGDataManager().getNewCarFilter(classID: selectedClass.id, cars: cars, success: { filter in
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.newFilter = filter
                        
                        let filterVC = InSaleCarFilterViewController()
                        filterVC.delegate = self
                        filterVC.selectedClass = self.selectedClass
                        filterVC.filter = self.newFilter
                        filterVC.modalPresentationStyle = .overCurrentContext
                        self.present(filterVC, animated: true, completion: nil)
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.showServerError()
                    }
                })
            } else {
                let filterVC = InSaleCarFilterViewController()
                filterVC.delegate = self
                filterVC.selectedClass = selectedClass
                filterVC.filter = newFilter
                filterVC.modalPresentationStyle = .overCurrentContext
                self.present(filterVC, animated: true, completion: nil)
            }
        } else {
            if (usedFilter == nil) {
                showHUD()
                AMGDataManager().getUsedCarFilter(classID: selectedClass.id, cars: cars, success: { filter in
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.usedFilter = filter
                        
                        let filterVC = InSaleUsedCarFilterViewController()
                        filterVC.delegate = self
                        filterVC.selectedClass = self.selectedClass
                        filterVC.filter = self.usedFilter
                        filterVC.modalPresentationStyle = .overCurrentContext
                        self.present(filterVC, animated: true, completion: nil)
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.showServerError()
                    }
                })
            } else {
                let filterVC = InSaleUsedCarFilterViewController()
                filterVC.delegate = self
                filterVC.selectedClass = selectedClass
                filterVC.filter = usedFilter
                filterVC.modalPresentationStyle = .overCurrentContext
                self.present(filterVC, animated: true, completion: nil)
            }
        }
    }
}

//
//  Tab3ViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class Tab3ViewController: TabItemViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "services_controller"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpButton: AMGButton!
    
    var cars: [AMGUserCar] = []
    var carImages:[String:UIImage] = [:]
    var pageControl: AMGPageControl!
    
    @IBOutlet var addCarCell: UITableViewCell!
    @IBOutlet var helpCell: UITableViewCell!
    @IBOutlet var serviceCell: UITableViewCell!
    @IBOutlet var partpriceCell: UITableViewCell!
    @IBOutlet var sertificateCell: UITableViewCell!
    @IBOutlet var calculatorCell: UITableViewCell!
    @IBOutlet var orderStatusCell: UITableViewCell!
    
    @IBOutlet weak var helpButtonLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YMReport(message: screenName)
        
        tableView.register(CarNameCell.self, forCellReuseIdentifier: "carNameCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "carImageCell")
        
        pageControl = AMGPageControl()
        pageControl.currentPage = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cars = AMGUser.shared.registrationCars
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if screenHeight < 600 { helpButtonLeadingConstraint.constant = 30}
    }
    
    @objc func myAutoAction(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"edit_car"])
        
        showHUD()
        AMGUserManager().loadUserCarAdditionalInfo(car: cars[sender.tag], success: { _ in
            OperationQueue.main.addOperation {
                self.hideHUD()
                let autoVC = MyAutoViewController()
                autoVC.delegateController = self
                autoVC.car = self.cars[sender.tag]
                autoVC.indexCar = sender.tag
                autoVC.modalPresentationStyle = .overCurrentContext
                self.present(autoVC, animated: true, completion: { self.fadeView.isHidden = false })
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    @objc func myAutoActionByImage() {
        YMReport(message: screenName, parameters: ["action":"edit_car"])
        
        if pageControl.currentPage >= 0 && pageControl.currentPage < cars.count {
            showHUD()
            AMGUserManager().loadUserCarAdditionalInfo(car: cars[pageControl.currentPage], success: { _ in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    let autoVC = MyAutoViewController()
                    autoVC.delegateController = self
                    autoVC.car = self.cars[self.pageControl.currentPage]
                    autoVC.indexCar = self.pageControl.currentPage
                    autoVC.modalPresentationStyle = .overCurrentContext
                    self.present(autoVC, animated: true, completion: { self.fadeView.isHidden = false })
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.showServerError()
                }
            })
        }
    }
    
    @IBAction func addAutoAction(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"add_new_car"])
        
        let autoVC = MyAutoViewController()
        autoVC.delegateController = self
        autoVC.viewMode = ViewTypeMode.AddCarMode
        autoVC.modalPresentationStyle = .overCurrentContext
        self.present(autoVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    @IBAction func phoneHelp() {
        YMReport(message: screenName, parameters: ["action":"call_help"])
        showTelPromptWithString(phone: "+80017777777")
    }
    
    @IBAction func serviceOrder() {
        YMReport(message: screenName, parameters: ["action":"service_request"])
        
        if (!CheckConnection()) { return }
        
        showHUD()
        AMGDataManager().getShowroomsForDealer(dealerId: AMGUser.shared.dealerId, success: { showrooms in
            OperationQueue.main.addOperation {
                self.hideHUD()
                let serviceVC = ServiceDealerViewController()
                serviceVC.showrooms = showrooms
                serviceVC.cars = AMGUser.shared.registrationCars
                serviceVC.modalPresentationStyle = .overCurrentContext
                self.present(serviceVC, animated: true, completion: { self.fadeView.isHidden = false })
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    @IBAction func checkOrderStatus() {
        let serviceVC = OrderStatusViewController()
        serviceVC.modalPresentationStyle = .overCurrentContext
        self.present(serviceVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    @IBAction func partsPriceAction() {
        YMReport(message: screenName, parameters: ["action":"parts_price"])
        
        let partsVC = SearchPartsViewController()
        partsVC.modalPresentationStyle = .overCurrentContext
        self.present(partsVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    @IBAction func serviceSertificateAction() {
        YMReport(message: screenName, parameters: ["action":"service_certificate"])
        
        let sertVC = SelectSertificateViewController()
        sertVC.modalPresentationStyle = .overCurrentContext
        self.present(sertVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    @IBAction func serviceCalculatorAction() {
        YMReport(message: screenName, parameters: ["action":"service_calculator"])
        
        let calcVC = ServiceCalcOptionsViewController()
        calcVC.modalPresentationStyle = .overCurrentContext
        self.present(calcVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cars.count + 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 { return (screenWidth - 40) * 2 / 3 + 16 }
        if indexPath.row == cars.count + 2 { return 80 }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "carImageCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for subview in cell.subviews {
                if subview.tag == 123 { subview.removeFromSuperview() }
            }
            
            let cars = AMGUser.shared.registrationCars
            if cars.count > 0 {
                let imageHeight = (screenWidth - 40) * 2 / 3
                
                let view = UIView()
                view.tag = 123
                view.backgroundColor = .clear
                view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight + 16)
                cell.addSubview(view)
                
                var scrollWidth: CGFloat = 20
                
                let scrollView = UIScrollView()
                scrollView.frame = view.frame
                scrollView.showsVerticalScrollIndicator = false
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.bounces = false
                scrollView.isScrollEnabled = false
                scrollView.isPagingEnabled = false
                view.addSubview(scrollView)
                
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                
                swipeLeft.direction = .left
                swipeRight.direction = .right
                
                scrollView.addGestureRecognizer(swipeLeft)
                scrollView.addGestureRecognizer(swipeRight)
                scrollView.isUserInteractionEnabled = true

                pageControl.numberOfPages = cars.count
                pageControl.currentPage = 0
                pageControl.currentPageIndicatorTintColor = .clear
                pageControl.pageIndicatorTintColor = .clear
                pageControl.hidesForSinglePage = true
                pageControl.frame = CGRect(x: 20, y: imageHeight - 22, width: screenWidth - 40, height: 30)
                pageControl.clipsToBounds = true
                view.addSubview(pageControl)
                
                for car in cars {
                    let imageView = UIImageView()
                    imageView.frame = CGRect(x: scrollWidth, y: 8, width: screenWidth - 40, height: imageHeight)
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    //imageView.addShadow(cornerRadius: 2, maskedCorners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], color: .white, offset: .zero, opacity: 0.7, shadowRadius: 6)
                    scrollView.addSubview(imageView)
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(myAutoActionByImage))
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tap)
                    
                    let activity = UIActivityIndicatorView()
                    activity.frame = CGRect(x: imageView.bounds.width/2 - 20, y: imageView.bounds.height/2 - 20, width: 40, height: 40)
                    activity.style = .whiteLarge
                    activity.color = AMGButton()._color
                    activity.stopAnimating()
                    activity.hidesWhenStopped = true
                    imageView.addSubview(activity)
                    
                    if carImages.keys.contains(car.VIN) {
                        imageView.image = carImages[car.VIN]
                    } else {
                        activity.startAnimating()
                        AMGUserManager().loadUserCarAdditionalInfo(car: car, success: { imageURL in
                            let getCacheImage = GetCacheImage(url: imageURL.absoluteString, lifeTime: .userWallImage)
                            getCacheImage.completionBlock = {
                                OperationQueue.main.addOperation {
                                    activity.stopAnimating()
                                    if let image = getCacheImage.outputImage {
                                        self.carImages[car.VIN] = image
                                        imageView.image = image
                                    } else {
                                        imageView.image = UIImage(named: "carPlaceholder")
                                    }
                                }
                            }
                            OperationQueue().addOperation(getCacheImage)
                        }, failure: {
                            OperationQueue.main.addOperation {
                                activity.stopAnimating()
                                imageView.image = UIImage(named: "carPlaceholder")
                            }
                        })
                    }
                    
                    scrollWidth += screenWidth - 30
                }
                
                scrollWidth += 10
                scrollView.contentSize = CGSize(width: scrollWidth, height: imageHeight + 16)
                
                /*let page = pageControl.currentPage
                switch page {
                case 0:
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                case 1...pageControl.numberOfPages - 2:
                    scrollView.setContentOffset(CGPoint(x: CGFloat(page) * (screenWidth-30), y: 0), animated: false)
                case pageControl.numberOfPages - 1:
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - screenWidth, y: 0), animated: false)
                default:
                    break
                }*/
            }
            
            cell.selectionStyle = .none
            return cell
        case 1..<cars.count+1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "carNameCell", for: indexPath) as! CarNameCell
            cell.backgroundColor = .clear
            let bounds = tableView.bounds
            
            for view in cell.subviews {
                if view is UIButton {
                    view.removeFromSuperview()
                }
            }
            
            let carButton = UIButton()
            carButton.tag = indexPath.row - 1
            carButton.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 48)
            carButton.setTitle("", for: .normal)
            carButton.addTarget(self, action: #selector(myAutoAction(sender:)), for: .touchUpInside)
            cell.addSubview(carButton)
            
            let carNameLabel = UILabel()
            carNameLabel.frame = CGRect(x: 100, y: 0, width: bounds.width - 143, height: 48)
            carNameLabel.text = cars[indexPath.row - 1].nModel
            carNameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            carNameLabel.adjustsFontSizeToFitWidth = true
            carNameLabel.minimumScaleFactor = 0.5
            carNameLabel.numberOfLines = 0
            carNameLabel.textAlignment = .right
            carNameLabel.textColor = .white
            carButton.addSubview(carNameLabel)
            
            let myAmgLabel = UILabel()
            myAmgLabel.frame = CGRect(x: 20, y: 0, width: 70, height: 48)
            myAmgLabel.text = "Мой AMG"
            myAmgLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            myAmgLabel.textAlignment = .left
            myAmgLabel.textColor = .white
            carButton.addSubview(myAmgLabel)
            
            let arrowImage = UIImageView()
            arrowImage.frame = CGRect(x: bounds.width - 28, y: 17.5, width: 8, height: 13)
            arrowImage.image = UIImage(named: "rightArrow")
            carButton.addSubview(arrowImage)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: bounds.width - 20, height: 1)
            separator.backgroundColor = UIColor(white: 1, alpha: 0.2)
            carButton.addSubview(separator)
            
            return cell
        case cars.count + 1:
            return addCarCell
        case cars.count + 2:
            return helpCell
        case cars.count + 3:
            return serviceCell
        case cars.count + 4:
            return partpriceCell
        case cars.count + 5:
            return sertificateCell
        case cars.count + 6:
            return calculatorCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.001
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if let scrollView = sender.view as? UIScrollView {
            if sender.direction == .right && pageControl.currentPage > 0 {
                pageControl.currentPage -= 1
            }
            
            if sender.direction == .left && pageControl.currentPage < pageControl.numberOfPages - 1 {
                pageControl.currentPage += 1
            }
            
            let page = pageControl.currentPage
            
            if page >= 1 && page < pageControl.numberOfPages-1 {
                scrollView.setContentOffset(CGPoint(x: CGFloat(page) * (screenWidth-30), y: 0), animated: true)
            }
            
            if page == 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            
            if page == pageControl.numberOfPages - 1 {
                scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - screenWidth, y: 0), animated: true)
            }
        }
    }
}

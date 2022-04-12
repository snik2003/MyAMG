//
//  InSaleCarDetailViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 20/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class InSaleCarDetailViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "in_sale_used_car_detail"
    
    var car: AMGCar!
    var isFavouriteMode = false
    var delegate: InSaleCarListViewController!
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var priceCell: AMGTableViewCell!
    @IBOutlet var equipmentsCell: AMGTableViewCell!
    @IBOutlet var sendOrderCell: AMGTableViewCell!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var bodyColorLabel: UILabel!
    @IBOutlet weak var bodyTypeLabel: UILabel!
    @IBOutlet weak var wheelLabel: UILabel!
    @IBOutlet weak var statusCarLabel: UILabel!
    @IBOutlet weak var engineTypeLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var engineVolumeLabel: UILabel!
    @IBOutlet weak var driveLabel: UILabel!
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    
    @IBOutlet weak var equipmentsLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var phoneSeparator: UIView!
    
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var isCertifiedMarker: UIImageView!
    
    @IBOutlet weak var phoneButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var onlineServicesButtonTopConstraint: NSLayoutConstraint!
    
    var pageControl = AMGPageControl()
    var cacheImages: [String: UIImage] = [:]
    
    let numFormatter = NumberFormatter()
    let runFormatter = NumberFormatter()
    
    var isFavourite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        bChangedFormData = false
        titleLabel.text = "Информация"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "carImagesCell")
        carNameLabel.text = car.nModel
        
        numFormatter.numberStyle = .decimal
        numFormatter.decimalSeparator = "."
        numFormatter.maximumFractionDigits = 0
        
        runFormatter.numberStyle = .decimal
        runFormatter.maximumFractionDigits = 0
        
        priceLabel.text = "\(car.cost) ₽ *"
        if let cost = numFormatter.number(from: car.cost), let price = numFormatter.string(from: cost) {
            priceLabel.text = "\(price) ₽ *"
        }
        
        runLabel.text = "0 км"
        if let number = runFormatter.number(from: car.run), let run = runFormatter.string(from: number) {
            runLabel.text = "\(run) км"
        }
        
        powerLabel.text = "0 л.с."
        if let number = runFormatter.number(from: car.enginePower), let power = runFormatter.string(from: number) {
            powerLabel.text = "\(power) л.с."
        }
        
        engineVolumeLabel.text = "0 куб.см."
        if let number = runFormatter.number(from: car.engineVolume), let vol = runFormatter.string(from: number) {
            engineVolumeLabel.text = "\(vol) куб.см."
        }
        
        yearLabel.text = car.yearManufacture
        isCertifiedMarker.alpha = car.isCertified ? 1.0 : 0.3
        isCertifiedMarker.tintColor = car.isCertified ? UIColor(red: 0.85, green: 0.15, blue: 0.17, alpha: 1) : UIColor(white: 1, alpha: 0.3)
        bodyColorLabel.text = car.colorBody
        bodyTypeLabel.text = car.bodyType
        wheelLabel.text = car.steeringWheel
        statusCarLabel.text = car.status.isEmpty ? "Не указан" : car.status
        engineTypeLabel.text = car.engineType
        driveLabel.text = car.drive
        transmissionLabel.text = car.transmission
        dealerLabel.text = "\(car.dealer) (\(car.city))"
        
        pageControl.currentPage = 0
        
        if car.dealerPhone.isEmpty {
            phoneButton.isHidden = true
            phoneSeparator.isHidden = true
            phoneButtonHeightConstraint.constant = 0
            onlineServicesButtonTopConstraint.constant = 15
        }
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20
        style.maximumLineHeight = 20
        style.alignment = NSTextAlignment.left
        
        let attributtes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14)]
        commentLabel.attributedText = NSAttributedString(string: commentLabel.text!, attributes: attributtes as [NSAttributedString.Key : Any])
        commentLabel.sizeToFit()
        
        if car.equipments.count > 0 {
            equipmentsLabel.text = car.equipments.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 20
            style.maximumLineHeight = 20
            style.alignment = NSTextAlignment.left
            
            let attributtes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14)]
            equipmentsLabel.attributedText = NSAttributedString(string: equipmentsLabel.text!, attributes: attributtes as [NSAttributedString.Key : Any])
            equipmentsLabel.sizeToFit()
        }
        
        setImageFavorite()
    }

    override func backButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setImageFavorite() {
        if AMGFavouriteCars.shared.usedCars.filter({ $0.srvId == car.srvId }).count > 0 {
            favoriteImage.image = UIImage(named: "star-on")
            isFavourite = true
        } else {
            favoriteImage.image = UIImage(named: "star-off")
            isFavourite = false
        }
    }
    
    @IBAction func addFavoriteAction() {
        if !isFavourite {
            
            //showAlertWithDoubleActions(title: "Внимание!", text: "Добавить автомобиль в \"Избранное\"?", title1: "Добавить", title2: "Отмена", completion: {
                
                self.showHUD()
                AMGDataManager().updateFavouritesCars(carID: self.car.srvId, isNew: false, del: false, success: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        
                        AMGFavouriteCars.shared.usedCars.append(self.car)
                        self.isFavourite = true
                        self.setImageFavorite()
                        self.showAlertWithTitle(title: "Внимание!", text: "Автомобиль добавлен в Избранное")
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.showServerError()
                    }
                })
            //}, completion2: {})
        } else {
            //showAlertWithDoubleActions(title: "Внимание!", text: "Удалить автомобиль из раздела \"Избранное\"?", title1: "Удалить", title2: "Отмена", completion: {
                
                self.showHUD()
                AMGDataManager().updateFavouritesCars(carID: self.car.srvId, isNew: false, del: true, success: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                
                        AMGFavouriteCars.shared.usedCars = AMGFavouriteCars.shared.usedCars.filter({ $0.srvId != self.car.srvId })
                        self.isFavourite = false
                        self.setImageFavorite()
                        self.showAlert(WithTitle: "Внимание!", andMessage: "Автомобиль удален из Избранного", completion: {
                            if self.isFavouriteMode {
                                self.delegate.updateCarList()
                                self.dismiss(animated: true, completion: nil)
                                if self.delegate.cars.count == 0 {
                                    self.delegate.dismiss(animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }, failure: {
                    OperationQueue.main.addOperation {
                        self.hideHUD()
                        self.showServerError()
                    }
                })
            //}, completion2: {})
        }
    }
    
    @IBAction func phoneDealer() {
        YMReport(message: screenName, parameters: ["action":"call_dealer"])
        showTelPromptWithString(phone: car.dealerPhone)
    }
    
    @IBAction func sendOrderAction() {
        YMReport(message: screenName, parameters: ["action":"send_order"])
        
        if !CheckConnection() {
            YMReport(message: screenName, parameters: ["warning":"no_internet_connection"])
            return
        }
        
        showAlertWithDoubleActions(title: "Подтверждение отправки заявки", text: "Заявка с Вашими контактными данными будет отправлена дилеру", title1: "Да", title2: "Отмена", completion: {
        
            self.showHUD()
            AMGDataManager().requestInSale(car: self.car, isNewCar: false, success: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["action":"sent_successfully"])
                    self.showAlert(WithTitle: "Заявка отправлена!", andMessage: "Наш менеджер свяжется с Вами для уточнения деталей", completion: {
                        if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            if let vc = tabbarController.selectedViewController as? TabItemViewController {
                                vc.fadeView.isHidden = true
                            }
                        }
                        
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    })
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.YMReport(message: self.screenName, parameters: ["serverError":"requestInSale"])
                    self.showServerError()
                }
            })
        }, completion2: {})
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            var height = (screenWidth - 40) * 2 / 3 + 15
            if car.images.count > 1 { height += 20 }
            return height
        case 1:
            return 674
        case 2:
            if car.equipments.count > 0 {
                let size = CGSize(width: screenWidth - 40, height: 100000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14)]
                
                return equipmentsLabel.text!.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height / 16 * 20 + 30
            }
            return 0
        case 3:
            let size = CGSize(width: screenWidth - 40, height: 100000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 14)]
            
            var height = commentLabel.text!.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height / 16 * 20
            
            if !car.dealerPhone.isEmpty { height += 15 + 15 + 48 + 30 + 30 + 15 + 50 + 20 }
            else { height += 15 + 30 + 30 + 15 + 50 + 20 }
            
            return height
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "carImagesCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for subview in cell.subviews {
                if subview.tag == 123 { subview.removeFromSuperview() }
            }
            
            let images = car.images
            let imageHeight = (screenWidth - 40) * 2 / 3
            
            let view = UIView()
            view.tag = 123
            view.backgroundColor = .clear
            view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight + 15)
            cell.addSubview(view)
            
            if images.count > 0 {
                var scrollWidth: CGFloat = 20
                
                let scrollView = UIScrollView()
                scrollView.frame = view.frame
                scrollView.showsVerticalScrollIndicator = false
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.bounces = false
                scrollView.isScrollEnabled = false
                scrollView.isPagingEnabled = false
                view.addSubview(scrollView)
                
                pageControl.numberOfPages = images.count
                pageControl.currentPageIndicatorTintColor = .clear
                pageControl.pageIndicatorTintColor = .clear
                pageControl.hidesForSinglePage = true
                pageControl.frame = CGRect(x: 20, y: imageHeight, width: screenWidth - 40, height: 30)
                pageControl.clipsToBounds = true
                
                view.addSubview(pageControl)
                
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                
                swipeLeft.direction = .left
                swipeRight.direction = .right
                
                scrollView.addGestureRecognizer(swipeLeft)
                scrollView.addGestureRecognizer(swipeRight)
                scrollView.isUserInteractionEnabled = true
                
                for imageURL in images {
                    let imageView = UIImageView()
                    imageView.frame = CGRect(x: scrollWidth, y: 0, width: screenWidth - 40, height: imageHeight)
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    scrollView.addSubview(imageView)
                    
                    let activity = UIActivityIndicatorView()
                    activity.frame = CGRect(x: imageView.bounds.width/2 - 20, y: imageView.bounds.height/2 - 20, width: 40, height: 40)
                    activity.style = .whiteLarge
                    activity.color = AMGButton()._color
                    activity.stopAnimating()
                    activity.hidesWhenStopped = true
                    imageView.addSubview(activity)
                    
                    if let image = cacheImages[imageURL] {
                        imageView.image = image
                    } else {
                        activity.startAnimating()
                        let getCacheImage = GetCacheImage(url: imageURL, lifeTime: .userWallImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                imageView.image = UIImage(named: "carPlaceholder3")
                                self.cacheImages[imageURL] = getCacheImage.outputImage
                                imageView.image = getCacheImage.outputImage
                                activity.stopAnimating()
                            }
                        }
                        OperationQueue().addOperation(getCacheImage)
                    }
                    
                    scrollWidth += screenWidth - 30
                }
                
                scrollWidth += 10
                scrollView.contentSize = CGSize(width: scrollWidth, height: imageHeight + 16)
                
                let page = pageControl.currentPage
                switch page {
                case 0:
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                case 1...pageControl.numberOfPages - 2:
                    scrollView.setContentOffset(CGPoint(x: CGFloat(page) * (screenWidth-30), y: 0), animated: false)
                case pageControl.numberOfPages - 1:
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - screenWidth, y: 0), animated: false)
                default:
                    break
                }
            } else {
                let imageView = UIImageView()
                imageView.image = UIImage(named: "carPlaceholder3")
                imageView.frame = CGRect(x: 20, y: 0, width: screenWidth - 40, height: imageHeight)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                view.addSubview(imageView)
            }
            
            cell.selectionStyle = .none
            return cell
        case 1:
            return priceCell
        case 2:
            if car.equipments.count > 0 { return equipmentsCell }
            return UITableViewCell()
        case 3:
            return sendOrderCell
        default:
            return UITableViewCell()
        }
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

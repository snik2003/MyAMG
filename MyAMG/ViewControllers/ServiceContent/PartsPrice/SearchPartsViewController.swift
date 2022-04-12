//
//  SearchPartsViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 21/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class SearchPartsViewController: InnerViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    var parts: [AMGPartSearch] = []
    var searchHistory = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 7, vertical: 0)
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 16
        style.maximumLineHeight = 16
        style.alignment = .left
        let attributtes = [NSAttributedString.Key.paragraphStyle: style]
        
        searchLabel.attributedText = NSAttributedString(string: searchLabel.text!, attributes: attributtes)
        searchLabel.sizeToFit()
        
        for subview in searchBar.subviews {
            for subview1 in subview.subviews {
                if let textField = subview1 as? UITextField {
                    textField.borderStyle = .none
                    textField.backgroundColor = UIColor(white: 241/255, alpha: 1)
                }
            }
        }
        
        backButton.isHidden = true
        titleLabel.text = "Запасные части"
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "partCell")
        
        if !CLLocationManager.locationServicesEnabled() {
            showAttention(message: ServiceDealerViewController().locationServicesError)
            return
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + 20, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAttention(message: ServiceDealerViewController().locationServicesError)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location { currentLocation = location }
        manager.stopUpdatingLocation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parts.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for view in cell.subviews {
            if view is UIButton { view.removeFromSuperview() }
        }
        
        let part = parts[indexPath.row]
        
        let button = UIButton()
        button.tag = indexPath.row
        button.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 48)
        button.setTitle("", for: .normal)
        cell.addSubview(button)
        
        if (part.isHistory) {
            button.addTarget(self, action: #selector(partHistoryButtonAction(sender:)), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(partButtonAction(sender:)), for: .touchUpInside)
        }
        
        let partNameLabel = UILabel()
        partNameLabel.frame = CGRect(x: 20, y: 0, width: screenWidth / 2, height: 48)
        partNameLabel.text = part.name.capitalizeName()
        partNameLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
        partNameLabel.numberOfLines = 0
        partNameLabel.adjustsFontSizeToFitWidth = true
        partNameLabel.minimumScaleFactor = 0.5
        partNameLabel.textAlignment = .left
        partNameLabel.textColor = .black
        button.addSubview(partNameLabel)
        
        let articleLabel = UILabel()
        articleLabel.frame = CGRect(x: screenWidth/2 + 20, y: 0, width: screenWidth/2 - 60, height: 48)
        articleLabel.text = part.article
        articleLabel.font = UIFont(name: "DaimlerCS-Regular", size: 15)
        articleLabel.numberOfLines = 1
        articleLabel.adjustsFontSizeToFitWidth = true
        articleLabel.minimumScaleFactor = 0.5
        articleLabel.textAlignment = .right
        articleLabel.textColor = UIColor(white: 0, alpha: 0.3)
        button.addSubview(articleLabel)
        
        let arrowImage = UIImageView()
        arrowImage.frame = CGRect(x: screenWidth - 28, y: 17.5, width: 8, height: 13)
        arrowImage.image = UIImage(named: "rightArrow")
        button.addSubview(arrowImage)
        
        let separator = UIView()
        separator.frame = CGRect(x: 20, y: 47, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.2)
        button.addSubview(separator)
        
        return cell
    }
    
    @objc func partHistoryButtonAction(sender: UIButton) {
        let part = parts[sender.tag]
        if part.article.count > 0 {
            let partSearch = AMGPartSearch(json: JSON.null)
            partSearch.article = part.article
            partSearch.latitude = currentLocation.coordinate.latitude
            partSearch.longitude = currentLocation.coordinate.longitude
            
            showHUD()
            AMGDataManager().getPartSearch(order: partSearch, success: { searchPart in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    let partVC = PartDetailViewController()
                    partVC.part = searchPart
                    partVC.modalPresentationStyle = .overCurrentContext
                    self.present(partVC, animated: true, completion: nil)
                }
            }, failure: {
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.showServerError()
                }
            })
        }
    }
    
    @objc func partButtonAction(sender: UIButton) {
    
        let index = sender.tag
        
        let part = parts[index]
        if !part.wasNotFound {
            let partVC = PartDetailViewController()
            partVC.part = part
            partVC.modalPresentationStyle = .overCurrentContext
            self.present(partVC, animated: true, completion: nil)
        } else {
            showErrorWithTitle(title: "Результат поиска", error: "Информация не найдена. Для консультации предлагаем обратиться к ближайшему официальному дилеру АО «Мерседес-Бенц РУС»")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 2 {
            loadParts()
        } else if searchHistory {
            loadHistory()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.view.endEditing(true)
        tableView.reloadSections([0], with: .automatic)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func loadHistory() {
        AMGDataManager().getPartsSearchHistory(success: { parts in
            OperationQueue.main.addOperation {
                if parts.count > 0 { self.view.endEditing(true) }
                self.searchHistory = false
                self.parts = parts
                self.tableView.reloadData()
            }
        })
    }
    
    func loadParts() {
        let partSearch = AMGPartSearch(json: JSON.null)
        partSearch.article = searchBar.text!
        partSearch.latitude = currentLocation.coordinate.latitude
        partSearch.longitude = currentLocation.coordinate.longitude
        
        self.showHUD()
        AMGDataManager().getPartsSearch(order: partSearch, success: { result in
            OperationQueue.main.addOperation {
                self.hideHUD()
                if let text = self.searchBar.text, text == result.searchString {
                    if result.parts.count > 0 { self.view.endEditing(true) }
                    self.searchHistory = true
                    self.parts = result.parts
                    self.tableView.reloadData()
                }
            }
        }, failure: {
            self.hideHUD()
        })
    }
}

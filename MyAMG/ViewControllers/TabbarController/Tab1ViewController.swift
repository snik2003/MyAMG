//
//  TabOneViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import AVKit

class Tab1ViewController: TabItemViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "news"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmented: UISegmentedControl!
    
    let refreshControl = UIRefreshControl()
    
    var news: [AMGOneNews] = []
    
    var cacheImages: [IndexPath: UIImage] = [:]
    var cacheHeights: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YMReport(message: screenName)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "mainNewsCell")
        
        segmented.layer.cornerRadius = 0
        segmented.layer.borderWidth = 0;
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:10)!,NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "DaimlerCS-Regular", size:11)!,NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmented.removeBorders()
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = AMGButton()._color
        tableView.addSubview(refreshControl)
        
        AMGNews.shared.loadNews()
        self.news = AMGNews.shared.news.filter( { $0.newsTypeId == 18 } )
        self.tableView.reloadData()
        
        showHUD()
        AMGUserManager().getUserData(success: {
            AMGUser.shared.loadCurrentUser()
            self.getUserConsent()
            self.pullToRefresh()
        }, failure: {
            self.hideHUD()
            AMGUser.shared.logoutForRegisteredUser()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AMGPushConfigurator.defaultConfigurator.askForPushNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .onGetNews, object: nil)
    }
    
    @objc func pullToRefresh() {
        NotificationCenter.default.addObserver(self, selector: #selector(actionOnGetNews), name: .onGetNews, object: nil)
        
        cacheImages.removeAll()
        cacheHeights.removeAll()
        AMGNewsManager().getNews(refreshControl: self.refreshControl)
    }
    
    @objc func actionOnGetNews() {
        AMGNews.shared.loadNews()
        
        if segmented.selectedSegmentIndex == 0 {
            news = AMGNews.shared.news.filter( { $0.newsTypeId == 18 } )
        } else {
            news = AMGNews.shared.news.filter( { $0.newsTypeId == 20 } )
        }
        tableView.reloadData()
        NotificationCenter.default.removeObserver(self, name: .onGetNews, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if let height = cacheHeights[indexPath] {
            return height
        } else {
            let new = news[indexPath.row]
            
            let size = CGSize(width: screenWidth - 70, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 18)]
            
            var height = new.title.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
            if height < 16 { height = 16 }
            height = 15 + height / 16 * 28 + 15 + (screenWidth - 40) / 3 * 2 + 15
            
            cacheHeights[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsOne = news[indexPath.row]
        
        YMReport(message: screenName, parameters: ["action":"open_news"])
        
        let newsVC = NewsViewController()
        newsVC.delegate = self
        newsVC.news = newsOne
        newsVC.modalPresentationStyle = .overCurrentContext
        self.present(newsVC, animated: true, completion: { self.fadeView.isHidden = false })
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainNewsCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for subview in cell.subviews {
            if subview.tag == 123 { subview.removeFromSuperview() }
        }
        
        let newsOne = news[indexPath.row]
        
        let size = CGSize(width: screenWidth - 70, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCA-Regular", size: 18)]
        
        var height = newsOne.title.boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height
        if height < 16 { height = 16 }
        
        let topY = 15 + height / 16 * 28 + 15
        let imageHeight = (screenWidth - 40) / 3 * 2
        
        
        let newsView = UIView()
        newsView.tag = 123
        newsView.frame = CGRect(x: 20, y: 0, width: screenWidth - 40, height: topY + imageHeight)
        newsView.backgroundColor = UIColor(white: 0.07, alpha: 1)
        cell.addSubview(newsView)
        
        
        let titleLabel = AMGTitleLabel()
        titleLabel.tag = 123
        titleLabel.frame = CGRect(x: 35, y: 15, width: screenWidth - 70, height: height / 16 * 24)
        titleLabel.text = newsOne.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "DaimlerCA-Regular", size: 18)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.clipsToBounds = true
        titleLabel.contentMode = .center
        titleLabel.textAlignment = .left
        cell.addSubview(titleLabel)
        
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 28
        style.maximumLineHeight = 28
        style.alignment = NSTextAlignment.left
        let attributtes2 = [NSAttributedString.Key.paragraphStyle: style]
        
        titleLabel.attributedText = NSAttributedString(string: newsOne.title, attributes: attributtes2)
        titleLabel.sizeToFit()
        
        
        let imageView = UIImageView()
        imageView.tag = 123
        imageView.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: imageHeight)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        
        let star = UIImageView()
        star.frame = CGRect(x: 16, y: imageView.bounds.height - 32, width: 16, height: 16)
        if newsOne.isConfirmed { star.image = UIImage(named: "star-on") }
        else { star.image = UIImage(named: "star-off") }
        
        let activity = UIActivityIndicatorView()
        activity.frame = CGRect(x: imageView.bounds.width/2 - 20, y: imageView.bounds.height/2 - 20, width: 40, height: 40)
        activity.style = .whiteLarge
        activity.color = AMGButton()._color
        activity.stopAnimating()
        activity.hidesWhenStopped = true
        imageView.addSubview(activity)
        
        if let image = cacheImages[indexPath] {
            imageView.image = image
            if newsOne.newsTypeId == 20 { imageView.addSubview(star) }
        } else {
            activity.startAnimating()
            let getCacheImage = GetCacheImage(url: newsOne.image, lifeTime: .userWallImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    if let image = getCacheImage.outputImage {
                        self.cacheImages[indexPath] = image
                        imageView.image = image
                        imageView.clipsToBounds = true
                    }
                    if newsOne.newsTypeId == 20 { imageView.addSubview(star) }
                    activity.stopAnimating()
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    @IBAction func segmentedValueChanged() {
        cacheImages.removeAll()
        cacheHeights.removeAll()
        
        if segmented.selectedSegmentIndex == 0 {
            YMReport(message: screenName, parameters: ["action":"filter_news"])
            news = AMGNews.shared.news.filter( { $0.newsTypeId == 18 } )
        } else {
            YMReport(message: screenName, parameters: ["action":"filter_events"])
            news = AMGNews.shared.news.filter( { $0.newsTypeId == 20 } )
        }
    
        tableView.reloadData()
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

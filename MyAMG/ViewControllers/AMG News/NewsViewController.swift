//
//  NewsViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 25/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class NewsViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    let screenName = "news_details"
    
    var delegate: Tab1ViewController!
    var delegate2: Tab5ViewController!
    var news: AMGOneNews!
    
    var imageView = UIImageView()
    
    var cacheImages: [String: UIImage] = [:]
    var cacheHeights: [IndexPath: CGFloat] = [:]
    var cacheCurrentPage: [IndexPath: Int] = [:]
    
    var confirmationIndex = 0
    var selectedConfirmationDate: Date?
    var firstTextContentIndex = -1
    
    @IBOutlet weak var newsTitleLabel: AMGTitleLabel!
    @IBOutlet weak var tableView: UITableView!
    
    var pickerView: UIDatePicker!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "textCell")
        
        backButton.isHidden = true
        titleLabel.text = ""
        
        newsTitleLabel.text = news.title
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 28
        style.maximumLineHeight = 28
        style.alignment = NSTextAlignment.left
        let attributtes = [NSAttributedString.Key.paragraphStyle: style]
        
        newsTitleLabel.attributedText = NSAttributedString(string: news.title, attributes: attributtes)
        newsTitleLabel.sizeToFit()
        
        firstTextContentIndex = getFirstTextSectionIndex()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    override func closeButtonAction(sender: UIButton) {
        super.closeButtonAction(sender: sender)
        if news.newsTypeId == 20 && delegate != nil { delegate.tableView.reloadData() }
        if news.newsTypeId == 17 && delegate2 != nil { delegate2.tableView.reloadData() }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return news.content.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            let content = news.content[indexPath.row]
            if content.typeString == "Text" {
                if let height = cacheHeights[indexPath] {
                    return height
                } else {
                    let size = CGSize(width: screenWidth - 40, height: 10000)
                    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                    let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18)]
                    
                    var height = (content.text.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height) / 18 * 24 + 20
                    
                    if news.appeal > 1 && indexPath.row == firstTextContentIndex { height += 34 }
                    
                    cacheHeights[indexPath] = height
                    return height
                }
            }
            
            if content.typeString == "CallButton" { return 80 }
            if content.typeString == "SectionButton" { return 80 }
            if content.typeString == "SiteButton" { return 80 }
            
            if content.typeString == "Image" {
                if let height = cacheHeights[indexPath] {
                    return height
                } else {
                    var height: CGFloat = 0
                    if content.images.count > 0 {
                        let image = content.images[0]
                        if image.height > 0 && image.width > 0 {
                            height += (screenWidth - 40) * CGFloat(image.height) / CGFloat(image.width) + 10
                        } else {
                            height += (screenWidth - 40) * 3 / 4 + 10
                        }
                    }
                    cacheHeights[indexPath] = height
                    return height
                }
            }
            
            if content.typeString == "Video" {
                return (screenWidth - 40) * 3 / 4 + 10
            }
            
            if content.typeString == "ConfirmButtons" {
                var height: CGFloat = 44
                if !news.registrationDateBegin.isEmpty || !news.registrationDateEnd.isEmpty { height += 118 }
                return height + 18 + 50 + 18
            }
            
            return 0
        case 1:
            return 20
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.backgroundColor = .clear
            
            for subview in cell.subviews {
                if subview.tag == 123 { subview.removeFromSuperview() }
            }
            
            let content = news.content[indexPath.row]
            
            if content.typeString == "Text" {
                cellForText(cell: cell, content: content, indexPath: indexPath)
            }
            
            if content.typeString == "Image" {
                cellForImage(cell: cell, content: content, indexPath: indexPath)
            }
            
            if content.typeString == "Video" {
                cellForVideo(cell: cell, content: content)
            }
            
            if content.typeString == "CallButton" {
                cellForPhoneCall(cell: cell, content: content, indexPath: indexPath)
            }
            
            if content.typeString == "SectionButton" {
                cellForSection(cell: cell, content: content, indexPath: indexPath)
            }
            
            if content.typeString == "SiteButton" {
                cellForSiteUrl(cell: cell, content: content, indexPath: indexPath)
            }
            
            if content.typeString == "ConfirmButtons" {
                cellForConfirmation(cell: cell, content: content, indexPath: indexPath)
            }
            
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func callAction(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"call"])
        showTelPromptWithString(phone: news.content[sender.tag].phoneNumber)
    }
    
    @objc func sectionAction(sender: UIButton) {
        YMReport(message: screenName, parameters: ["action":"section"])
        
        let section = news.content[sender.tag].sectionIndex
        
        switch section {
        case 2: // Сервис
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                tabbarController.selectedIndex = 1
                self.dismiss(animated: true, completion: {
                    self.serviceOrder(tabbarController: tabbarController)
                })
            }
        case 5: // В продаже
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                self.dismiss(animated: true)
                tabbarController.selectedIndex = 2
            }
        case 6: // Мой профиль
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                self.dismiss(animated: true, completion: {
                    let regVC = RegViewController()
                    regVC.editDataMode = true
                    regVC.modalPresentationStyle = .overCurrentContext
                    tabbarController.present(regVC, animated: true, completion: nil)
                })
            }
        case 7: // Тест-драйв
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                self.dismiss(animated: true)
                tabbarController.selectedIndex = 3
            }
        case 11: // Сервисный сертификат
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                tabbarController.selectedIndex = 1
                self.dismiss(animated: true, completion: {
                    let sertVC = SelectSertificateViewController()
                    sertVC.modalPresentationStyle = .overCurrentContext
                    tabbarController.present(sertVC, animated: true, completion: nil)
                })
            }
        case 12: // Проверка наличия запчасти
            if let tabbarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                tabbarController.selectedIndex = 1
                self.dismiss(animated: true, completion: {
                    let partsVC = SearchPartsViewController()
                    partsVC.modalPresentationStyle = .overCurrentContext
                    tabbarController.present(partsVC, animated: true, completion: nil)
                })
            }
        default:
            break
        }
    }
    
    @objc func siteAction(sender: UIButton) {
        if let url = URL(string: news.content[sender.tag].url) {
            YMReport(message: screenName, parameters: ["action":"web"])
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func serviceOrder(tabbarController: UITabBarController) {
        
        if (!CheckConnection()) { return }
        
        showHUD()
        AMGDataManager().getShowroomsForDealer(dealerId: AMGUser.shared.dealerId, success: { showrooms in
            OperationQueue.main.addOperation {
                self.hideHUD()
                let serviceVC = ServiceDealerViewController()
                serviceVC.showrooms = showrooms
                serviceVC.modalPresentationStyle = .overCurrentContext
                tabbarController.present(serviceVC, animated: true, completion: nil)
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func showAnswerAlert() {
        let msg = news.content[confirmationIndex].confirmMessage != "" ? news.content[confirmationIndex].confirmMessage : "Спасибо!"
        let title = news.content[confirmationIndex].confirmMessageTitle != "" ? news.content[confirmationIndex].confirmMessageTitle : "Ваш ответ зарегистрирован"
        
        showAlertWithTitle(title: title, text: msg)
    }

    @objc func acceptConfirmationAction(sender: UIButton) {
        
        confirmationIndex = sender.tag
        
        YMReport(message: screenName, parameters: ["action":"accept"])
        
        if !news.registrationDateBegin.isEmpty || !news.registrationDateEnd.isEmpty {
            if selectedConfirmationDate == nil {
                showAttention(message: "Пожалуйста выберите предпочтительное время")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
            
            let msg = "Вы хотите зарегистрироваться на \(dateFormatter.string(from: selectedConfirmationDate!))?"
            showAlertWithDoubleActions(title: "Подтверждение участия", text: msg, title1: "Да", title2: "Нет", completion: {
                self.sendConfirmation(isConfirmed: true)
            }, completion2: {})
        } else {
            sendConfirmation(isConfirmed: true)
        }
    }
    
    @objc func declineConfirmationAction(sender: UIButton) {
        confirmationIndex = sender.tag
        
        YMReport(message: screenName, parameters: ["action":"decline"])
        
        if !news.registrationDateBegin.isEmpty || !news.registrationDateEnd.isEmpty {
            let msg = "Вы действительно хотите отменить регистрацию?"
            showAlertWithDoubleActions(title: "Отмена участия", text: msg, title1: "Да", title2: "Нет", completion: {
                self.sendConfirmation(isConfirmed: false)
            }, completion2: {})
        } else {
            sendConfirmation(isConfirmed: false)
        }
        
    }
    
    func sendConfirmation(isConfirmed: Bool, inBackground: Bool = false) {
        if !inBackground { showHUD() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
        
        AMGNewsManager().confirmNews(news: news, newsID: news.id, isConfirmed: isConfirmed, selectedDate: selectedConfirmationDate, success: {
            OperationQueue.main.addOperation {
                if !inBackground {
                    self.hideHUD()
                    AMGNews.shared.saveNews()
                    self.showAnswerAlert()
                }
                if !isConfirmed { self.selectedConfirmationDate = nil }
                self.bChangedFormData = false
                self.tableView.reloadData()
            }
        }, failure: {
            OperationQueue.main.addOperation {
                if !inBackground {
                    self.hideHUD()
                    self.showServerError()
                }
            }
        })
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if let scrollView = sender.view as? UIScrollView, let pageControl = scrollView.viewWithTag(100) as? UIPageControl {
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


extension NewsViewController {
    
    func getFirstTextSectionIndex() -> Int {
        for index in 0..<news.content.count {
            if news.content[index].typeString == "Text" {
                return index
            }
        }
        
        return -1
    }
    
    func constructAppeal() -> String {
        switch news.appeal {
        case 2:
            if AMGUser.shared.gender == Gender.Female.rawValue {
                return "Уважаемая \(AMGUser.shared.firstName) \(AMGUser.shared.middleName)!"
            } else {
                return "Уважаемый \(AMGUser.shared.firstName) \(AMGUser.shared.middleName)!"
            }
        case 3:
            if AMGUser.shared.gender == Gender.Female.rawValue {
                return "Госпожа \(AMGUser.shared.lastName)!"
            } else {
                return "Господин \(AMGUser.shared.lastName)!"
            }
        default:
            return ""
        }
    }

    func cellForText(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        var topY: CGFloat = 10
        
        if news.appeal > 1 && indexPath.row == firstTextContentIndex {
            let appealLabel = UILabel()
            appealLabel.tag = 123
            appealLabel.font = UIFont(name: "DaimlerCS-Regular", size: 18)
            appealLabel.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: 24)
            appealLabel.text = constructAppeal()
            appealLabel.textColor = UIColor(white: 0, alpha: 0.6)
            appealLabel.textAlignment = .left
            appealLabel.numberOfLines = 1
            appealLabel.adjustsFontSizeToFitWidth = true
            appealLabel.minimumScaleFactor = 0.4
            cell.addSubview(appealLabel)
            
            topY += 34
        }
        
        let size = CGSize(width: screenWidth - 40, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18)]
        
        let height = content.text.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: size, options: options, attributes: attributes as [NSAttributedString.Key : Any], context: nil).height / 18 * 24 + 20
        
        let textView = UITextView()
        textView.tag = 123
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = [.phoneNumber, .link]
        textView.font = UIFont(name: "DaimlerCS-Regular", size: 18)
        textView.frame = CGRect(x: 20, y: topY, width: screenWidth - 30, height: height)
        textView.text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)
        textView.textColor = UIColor(white: 0, alpha: 0.6)
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.bouncesZoom = false
        cell.addSubview(textView)
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 24
        style.maximumLineHeight = 24
        style.alignment = NSTextAlignment.left
        let attributtes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18), NSAttributedString.Key.foregroundColor: UIColor(white: 0, alpha: 0.6)]
        
        textView.attributedText = NSAttributedString(string: textView.text!, attributes: attributtes as [NSAttributedString.Key : Any])
        textView.sizeToFit()
    }
    
    func cellForImage(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        if content.images.count > 0 {
            let image = content.images[0]
            
            var imageHeight = (screenWidth - 40) * 3 / 4
            if image.height > 0 && image.width > 0 {
                imageHeight = (screenWidth - 40) * CGFloat(image.height) / CGFloat(image.width)
            }
            
            let view = UIView()
            view.tag = 123
            view.backgroundColor = .clear
            view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: imageHeight + 10)
            cell.addSubview(view)
            
            var scrollWidth: CGFloat = 20
            
            let scrollView = UIScrollView()
            scrollView.backgroundColor = .white
            scrollView.frame = view.frame
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            //scrollView.bounces = false
            //scrollView.isScrollEnabled = false
            //scrollView.isPagingEnabled = false
            view.addSubview(scrollView)
            
            let pageControl = UIPageControl()
            pageControl.tag = 100
            pageControl.isHidden = true
            pageControl.numberOfPages = content.images.count
            pageControl.currentPageIndicatorTintColor = .clear
            pageControl.pageIndicatorTintColor = .clear
            pageControl.hidesForSinglePage = true
            pageControl.frame = CGRect(x: 20, y: imageHeight - 22, width: screenWidth - 40, height: 30)
            pageControl.clipsToBounds = true
            scrollView.addSubview(pageControl)
            
            for image in content.images {
                let imageView = UIImageView()
                imageView.tag = 1
                imageView.frame = CGRect(x: scrollWidth, y: 5, width: screenWidth - 40, height: imageHeight)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                scrollView.addSubview(imageView)
                
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
                
                swipeLeft.direction = .left
                swipeRight.direction = .right
                
                scrollView.addGestureRecognizer(swipeLeft)
                scrollView.addGestureRecognizer(swipeRight)
                scrollView.isUserInteractionEnabled = true
                
                let activity = UIActivityIndicatorView()
                activity.frame = CGRect(x: imageView.bounds.width/2 - 20, y: imageView.bounds.height/2 - 20, width: 40, height: 40)
                activity.style = .whiteLarge
                activity.color = AMGButton()._color
                activity.stopAnimating()
                activity.hidesWhenStopped = true
                imageView.addSubview(activity)
                
                if let image = cacheImages[image.url] {
                    imageView.image = image
                } else {
                    imageView.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    activity.startAnimating()
                    let getCacheImage = GetCacheImage(url: image.url, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                    setImageToRow.completionBlock = {
                        OperationQueue.main.addOperation {
                            activity.stopAnimating()
                            self.cacheImages[image.url] = getCacheImage.outputImage
                        }
                    }
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                }
                
                scrollWidth += screenWidth - 30
            }
            
            scrollWidth += 10
            scrollView.contentSize = CGSize(width: scrollWidth, height: imageHeight)
            
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
        }
    }
    
    func cellForVideo(cell: UITableViewCell, content: AMGNewsContent) {
        
        if CheckConnectionWithoutAlert() {
            let webView = WKWebView()
            webView.tag = 123
            webView.backgroundColor = .clear
            webView.navigationDelegate = self
            webView.isOpaque = false
            
            let width = screenWidth - 40
            webView.frame = CGRect(x: 20, y: 5, width: width, height: width * 0.75)
            
            let view = UIView()
            view.tag = 123
            view.backgroundColor = UIColor(red: 122/255, green: 122/255, blue: 122/255, alpha: 1.0)
            view.frame = CGRect(x: 0, y: 0, width: webView.frame.width, height: webView.frame.height)
            webView.addSubview(view)
            
            if let url = URL(string: content.url) {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 50)
                webView.load(request)
                cell.addSubview(webView)
            }
            
            if let scrollView = webView.subviews.last as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    func cellForPhoneCall(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        let button = AMGButton()
        button.tag = 123
        button.frame = CGRect(x: 50, y: 15, width: screenWidth - 100, height: 50)
        button.tag = indexPath.row
        button.setTitle("Позвонить", for: .normal)
        if content.text != "" { button.setTitle(content.text, for: .normal) }
        button.setImage(UIImage(named: "phone"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: -7, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(callAction(sender:)), for: .touchUpInside)
        cell.addSubview(button)
    }
    
    func cellForSection(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        let button = AMGButton()
        button.tag = 123
        button.frame = CGRect(x: 50, y: 15, width: screenWidth - 100, height: 50)
        button.tag = indexPath.row
        button.setTitle("Перейти в раздел", for: .normal)
        if content.text != "" { button.setTitle(content.text, for: .normal) }
        button.addTarget(self, action: #selector(sectionAction(sender:)), for: .touchUpInside)
        cell.addSubview(button)
    }
    
    func cellForSiteUrl(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        let button = AMGButton()
        button.tag = 123
        button.frame = CGRect(x: 50, y: 15, width: screenWidth - 100, height: 50)
        button.tag = indexPath.row
        button.setTitle("Перейти на сайт", for: .normal)
        if content.text != "" { button.setTitle(content.text, for: .normal) }
        button.addTarget(self, action: #selector(siteAction(sender:)), for: .touchUpInside)
        cell.addSubview(button)
    }
    
    func cellForConfirmation(cell: UITableViewCell, content: AMGNewsContent, indexPath: IndexPath) {
        
        let confirmLabel = UILabel()
        confirmLabel.tag = 123
        confirmLabel.text = content.confirmText
        confirmLabel.textColor = UIColor(white: 0, alpha: 0.6)
        confirmLabel.font = UIFont(name: "DaimlerCS-Regular", size: 16)
        confirmLabel.frame = CGRect(x: 20, y: 10, width: screenWidth - 40, height: 24)
        confirmLabel.textAlignment = .left
        confirmLabel.numberOfLines = 1
        confirmLabel.adjustsFontSizeToFitWidth = true
        confirmLabel.minimumScaleFactor = 0.5
        cell.addSubview(confirmLabel)
        
        var topY: CGFloat = 44
        
        if !news.registrationDateBegin.isEmpty || !news.registrationDateEnd.isEmpty {
            
            let dateLabel = UILabel()
            dateLabel.tag = 123
            dateLabel.textColor = UIColor(white: 0, alpha: 0.6)
            dateLabel.font = UIFont(name: "DaimlerCS-Regular", size: 14)
            dateLabel.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: 20)
            dateLabel.textAlignment = .center
            dateLabel.numberOfLines = 1
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.minimumScaleFactor = 0.5
            cell.addSubview(dateLabel)
            
            topY += 30
            
            let view = UIView()
            view.tag = 123
            view.backgroundColor = UIColor(white: 0.9, alpha: 1)
            view.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: 20)
            cell.addSubview(view)

            topY += 20
            
            let dateButton = UIButton()
            dateButton.tag = 123
            dateButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
            dateButton.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: 48)
            dateButton.setImage(UIImage(named: "time"), for: .normal)
            dateButton.titleLabel?.font = UIFont(name: "DaimlerCS-Regular", size: 14)
            dateButton.setTitleColor(.black, for: .normal)
            dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 15)
            dateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 40)
            dateButton.contentHorizontalAlignment = .left
            cell.addSubview(dateButton)
            
            let arrowImage = UIImageView()
            arrowImage.frame = CGRect(x: dateButton.bounds.width - 28, y: 17.5, width: 8, height: 13)
            arrowImage.image = UIImage(named: "rightArrow")
            dateButton.addSubview(arrowImage)
            
            let separator = UIView()
            separator.frame = CGRect(x: 20, y: 47, width: dateButton.bounds.width - 20, height: 1)
            separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
            dateButton.addSubview(separator)
            
            topY += 48
            
            let view2 = UIView()
            view2.tag = 123
            view2.backgroundColor = UIColor(white: 0.9, alpha: 1)
            view2.frame = CGRect(x: 20, y: topY, width: screenWidth - 40, height: 20)
            cell.addSubview(view2)
            
            topY += 20
            
            if !news.userRegistrationDate.isEmpty {
                
                if news.isConfirmed {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ru_RU")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    var regDate = ""
                    if let date = dateFormatter.date(from: news.userRegistrationDate) {
                        dateFormatter.locale = Locale(identifier: "ru_RU")
                        dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
                        regDate = dateFormatter.string(from: date)
                    } else {
                        dateFormatter.locale = Locale(identifier: "ru_RU")
                        dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
                        regDate = dateFormatter.string(from: Date())
                    }
                    
                    dateLabel.text = "Вы зарегистрированы на:"
                    dateButton.setTitle(regDate, for: .normal)
                    dateButton.setTitleColor(.black, for: .normal)
                    
                    dateButton.isUserInteractionEnabled = false
                    dateButton.removeTarget(self, action: nil, for: .allEvents)
                } else {
                    dateLabel.text = "Выберите удобное для Вас время:"
                    dateButton.setTitle("Выберите время", for: .normal)
                    dateButton.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                    
                    dateButton.isUserInteractionEnabled = true
                    dateButton.addTarget(self, action: #selector(selectDateAction), for: .touchUpInside)
                }
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
                
                dateLabel.text = "Выберите удобное для Вас время:"
                if let date = selectedConfirmationDate {
                    dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
                    dateButton.setTitleColor(.black, for: .normal)
                } else {
                    dateButton.setTitle("Выберите время", for: .normal)
                    dateButton.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                }
                
                dateButton.isUserInteractionEnabled = true
                dateButton.addTarget(self, action: #selector(selectDateAction), for: .touchUpInside)
            }
        }
        
        if news.isConfirmed {
            let disagreeButton = AMGButton()
            disagreeButton.tag = 123
            disagreeButton.frame = CGRect(x: 50, y: topY + 18, width: screenWidth - 100, height: 50)
            disagreeButton.tag = indexPath.row
            disagreeButton.setTitle("", for: .normal)
            disagreeButton.addTarget(self, action: #selector(declineConfirmationAction(sender:)), for: .touchUpInside)
            cell.addSubview(disagreeButton)
            
            let disagreeLabel = UILabel()
            disagreeLabel.frame = CGRect(x: 22, y: 0, width: screenWidth - 144, height: 50)
            disagreeLabel.textColor = .white
            disagreeLabel.textAlignment = .center
            disagreeLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            disagreeLabel.numberOfLines = 0
            disagreeLabel.clipsToBounds = true
            disagreeLabel.adjustsFontSizeToFitWidth = true
            disagreeLabel.minimumScaleFactor = 0.4
            disagreeLabel.text = "Отписаться"
            if content.notConfirmText != "" { disagreeLabel.text = content.notConfirmText }
            disagreeButton.addSubview(disagreeLabel)
        } else {
            let agreeButton = AMGButton()
            agreeButton.tag = 123
            agreeButton._color = UIColor(red: 0, green: 173/255, blue: 239/255, alpha: 1)
            agreeButton.frame = CGRect(x: 50, y: topY + 18, width: screenWidth - 100, height: 50)
            agreeButton.tag = indexPath.row
            agreeButton.setTitle("", for: .normal)
            agreeButton.addTarget(self, action: #selector(acceptConfirmationAction(sender:)), for: .touchUpInside)
            cell.addSubview(agreeButton)
            
            let agreeLabel = UILabel()
            agreeLabel.frame = CGRect(x: 22, y: 0, width: screenWidth - 144, height: 50)
            agreeLabel.textColor = .white
            agreeLabel.textAlignment = .center
            agreeLabel.font = UIFont(name: "DaimlerCS-Regular", size: 17)
            agreeLabel.numberOfLines = 0
            agreeLabel.clipsToBounds = true
            agreeLabel.adjustsFontSizeToFitWidth = true
            agreeLabel.minimumScaleFactor = 0.4
            agreeLabel.text = "Записаться"
            if content.confirmText != "" { agreeLabel.text = content.confirmText }
            agreeButton.addSubview(agreeLabel)
        }
    }
}

extension NewsViewController {
    
    @objc func selectDateAction() {
        loadPicker()
    }
    
    @objc func donePickerAction() {
        
        bChangedFormData = true
        selectedConfirmationDate = pickerView.date
        cancelPickerAction()
        tableView.reloadData()
    }
    
    func loadPicker() {
        self.view.endEditing(true)
        
        pickerView.datePickerMode = .dateAndTime
        pickerView.locale = Locale(identifier: "ru_RU")
        pickerView.minuteInterval = 15
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: news.registrationDateBegin) {
            pickerView.minimumDate = date
            pickerView.date = date
            if Date() > date {
                pickerView.minimumDate = Date()
                pickerView.date = Date()
            }
        } else {
            pickerView.minimumDate = Date()
            pickerView.date = Date()
        }
        
        if let date = dateFormatter.date(from: news.registrationDateEnd) {
            pickerView.maximumDate = date
        } else {
            pickerView.maximumDate = Date()
        }
        
        pickerView.isHidden = false
        toolbar.isHidden = false
        fadeView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height - 206, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height - 250, width: bounds.width, height: 44)
        })
    }
    
    @objc func cancelPickerAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.fadeView.isHidden = true
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44)
        }, completion: { finished in
            self.toolbar.isHidden = true
            self.pickerView.isHidden = true
        })
    }
    
    func makePickerView() {
        let bounds = view.bounds
        
        pickerView = UIDatePicker(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206))
        pickerView.backgroundColor = .lightGray
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(donePickerAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPickerAction))
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44))
        toolbar.tintColor = .red
        toolbar.barTintColor = .darkText
        toolbar.sizeToFit()
        toolbar.items = [cancelButton, spaceButton, doneButton]
        
        fadeView = UIView(frame: bounds)
        fadeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        
        pickerView.isHidden = true
        toolbar.isHidden = true
        fadeView.isHidden = true
        
        view.addSubview(fadeView)
        view.addSubview(toolbar)
        view.addSubview(pickerView)
    }
}

extension NewsViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let activity = UIActivityIndicatorView()
        activity.tag = 123
        activity.frame = CGRect(x: webView.bounds.width/2 - 20, y: webView.bounds.height/2 - 20, width: 40, height: 40)
        activity.style = .whiteLarge
        activity.color = AMGButton()._color
        activity.startAnimating()
        activity.hidesWhenStopped = true
        webView.addSubview(activity)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        for subview in webView.subviews {
            if subview.tag == 123 { subview.removeFromSuperview() }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        for subview in webView.subviews {
            if subview is UIActivityIndicatorView { subview.removeFromSuperview() }
        }
    }
}

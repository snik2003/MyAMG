//
//  InfoSertificateViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 06/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class InfoSertificateViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: SelectSertificateViewController!
    var ssTypes: [AMGSSType] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var cacheHeights: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "infoCell")
        titleLabel.text = "Информация о Сертификатах"
    }

    @objc func selectSertificateAction(sender: UIButton) {
        delegate.selectedIndexPath = IndexPath(row: sender.tag, section: 0)
        delegate.tableView.selectRow(at: delegate.selectedIndexPath, animated: false, scrollPosition: .top)
        delegate.order.scTypeId = ssTypes[sender.tag].id
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ssTypes.count
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
            let size = CGSize(width: screenWidth - 40, height: 10000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributtes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18)]
            
            let height = (ssTypes[indexPath.row].descr.boundingRect(with: size, options: options, attributes: attributtes as [NSAttributedString.Key : Any], context: nil).height) / 18 * 22 + 113
            cacheHeights[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for subview in cell.subviews {
            if subview.tag == 123 { subview.removeFromSuperview() }
        }
        
        let type = ssTypes[indexPath.row]
        
        let size = CGSize(width: screenWidth - 40, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributtes = [NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18)]
        
        let height = (type.descr.boundingRect(with: size, options: options, attributes: attributtes as [NSAttributedString.Key : Any], context: nil).height) / 18 * 22
        
        let view = UIView()
        view.tag = 123
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: height + 113)
        view.backgroundColor = .clear
        cell.addSubview(view)
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 20, y: 10, width: screenWidth - 40, height: 40)
        nameLabel.text = type.text
        nameLabel.textColor = .black
        nameLabel.font = UIFont(name: "DaimlerCA-Regular", size: 26)
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        view.addSubview(nameLabel)
        
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 20, y: 65, width: screenWidth - 40, height: height)
        textLabel.text = type.descr
        textLabel.textColor = UIColor(white: 0, alpha: 0.6)
        textLabel.font = UIFont(name: "DaimlerCS-Regular", size: 18)
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5
        textLabel.clipsToBounds = true
        view.addSubview(textLabel)
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 24
        style.maximumLineHeight = 24
        style.alignment = NSTextAlignment.left
        
        let attributtes2 = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name: "DaimlerCS-Regular", size: 18)]
        textLabel.attributedText = NSAttributedString(string: type.descr, attributes: attributtes2 as [NSAttributedString.Key : Any])
        textLabel.sizeToFit()
        
        let button = UIButton()
        button.tag = indexPath.row
        button.frame = CGRect(x: 0, y: height + 65, width: screenWidth, height: 48)
        button.backgroundColor = .clear
        button.setTitle("ВЫБРАТЬ СЕРТИФИКАТ", for: .normal)
        button.setTitleColor(UIColor(white: 0, alpha: 0.8), for: .normal)
        button.titleLabel?.font = UIFont(name: "DaimlerCS-Regular", size: 12)
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(selectSertificateAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
        
        let separator = UIView()
        separator.frame = CGRect(x: 20, y: height + 112, width: screenWidth - 20, height: 1)
        separator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.addSubview(separator)
        
        cell.selectionStyle = .none
        return cell
    }
}

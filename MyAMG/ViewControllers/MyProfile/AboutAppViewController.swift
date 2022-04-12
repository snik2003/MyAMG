//
//  AboutAppViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit


class AboutAppViewController: InnerViewController {

    let dateVersion = "01 октября 2019 года"
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Лицензионный договор"
        setTextView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setTextView() {
        textView.text = textView.text.replacingOccurrences(of: "$NUM_VERSION", with: MMDevice.applicationShortVersionString())
            //applicationVersionString())
        textView.text = textView.text.replacingOccurrences(of: "$DATE_VERSION", with: dateVersion)
        
        textView.attributedText = addBoldText(fullString: textView.text, baseFont: UIFont(name: "DaimlerCS-Regular", size: 17)!, boldFont: UIFont(name: "DaimlerCS-Demi", size: 18)!)
    }
    
    func addBoldText(fullString: String, baseFont: UIFont, boldFont: UIFont) -> NSAttributedString {
        
        let baseFontAttribute = [NSAttributedString.Key.font : baseFont]
        let boldFontAttribute = [NSAttributedString.Key.font : boldFont]
        
        let attributedString = NSMutableAttributedString(string: fullString, attributes: baseFontAttribute)
        
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "Лицензиар:") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "Условия использования приложения My AMG для конечного пользователя") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "1. Сбор и обработка данных") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "2. Передача данных") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "3. Push-уведомления и иные коммуникации") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "4. Безопасность данных") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: "5. Контактное лицо по вопросам защиты персональных данных") ?? fullString.startIndex..<fullString.endIndex, in: fullString))
        
        
        return attributedString
    }
}

//
//  AMGButton.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

@IBDesignable

class AMGButton: UIButton {

    var _color: UIColor! = UIColor(red: 217/255, green: 37/255, blue: 43/255, alpha: 1)
    var _margin: CGFloat! = 22
    var _direct: Bool! = true
    
    @IBInspectable var margin: Double {
        get { return Double(_margin)}
        set { _margin = CGFloat(newValue)}
    }
    
    @IBInspectable var fillColor: UIColor? {
        get { return _color }
        set{ _color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        self.setTitle(titleLabel?.text?.uppercased(), for: .normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if (_direct) {
            context.beginPath()
            context.move(to: CGPoint(x: rect.minX + _margin, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX - _margin, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.minX + _margin, y: rect.minY))
            context.closePath()
        } else {
            context.beginPath()
            context.move(to: CGPoint(x: rect.minX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX - _margin, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.minX + _margin, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            context.closePath()
        }
        
        context.setFillColor(_color.cgColor)
        context.fillPath()
    }
}

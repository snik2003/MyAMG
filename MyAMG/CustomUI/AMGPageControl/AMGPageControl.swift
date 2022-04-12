//
//  AMGPageControl.swift
//  MyAMG
//
//  Created by Сергей Никитин on 18/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class AMGPageControl: UIPageControl {

    var currentPageImage = UIImage(named: "checked")
    var otherPagesImage = UIImage(named: "unchecked")
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        transform = CGAffineTransform(scaleX: 2, y: 2)
        
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
    }
    
    private func updateDots() {
        
        for (index, subview) in subviews.enumerated() {
            let imageView: UIImageView
            if let existingImageview = getImageView(forSubview: subview) {
                imageView = existingImageview
            } else {
                let frame = subview.frame
                imageView = UIImageView(image: otherPagesImage)
                imageView.frame = CGRect(x: frame.width/2 - 4, y: frame.height/2 - 4, width: 8, height: 8)
                
                imageView.center = subview.center
                subview.addSubview(imageView)
                subview.clipsToBounds = false
            }
            imageView.image = currentPage == index ? currentPageImage : otherPagesImage
        }
    }
    
    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
                } as? UIImageView
            
            return view
        }
    }
}

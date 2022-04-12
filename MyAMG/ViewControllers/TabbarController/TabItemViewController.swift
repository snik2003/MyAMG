//
//  TabItemViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 16/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import SwiftyJSON

class TabItemViewController: InnerViewController {

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    
    var fadeView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fadeView.isHidden = true
        fadeView.backgroundColor = UIColor(white: 0, alpha: 0.55)
        self.view.addSubview(fadeView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setBackgroundGradient()
        fadeView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func profileButtonAction(sender: UIButton) {
        let profileVC = ProfileMasterViewController()
        profileVC.modalPresentationStyle = .overCurrentContext
        self.present(profileVC, animated: true, completion: { self.fadeView.isHidden = false })
    }
    
    func getUserConsent() {
        AMGUserConsent.shared.isSuccess = false
        AMGUserConsent.shared.agreePhone = false
        AMGUserConsent.shared.agreeEmail = false
        AMGUserConsent.shared.agreeSMS = false
        
        API_WRAPPER.srvGetConsent(forUser: AMGUser.shared.userUUID, success: { response in
            guard let data = response, let json = try? JSON(data: data) else { return }
            self.hideHUD()
            let consent = AMGUserConsent(json: json)
            AMGUserConsent.shared.isSuccess = true
            AMGUserConsent.shared.agreePhone = consent.agreePhone
            AMGUserConsent.shared.agreeEmail = consent.agreeEmail
            AMGUserConsent.shared.agreeSMS = consent.agreeSMS
        }, failure: { _ in
            self.hideHUD()
        })
    }
    
    func setBackgroundGradient() {
        for view in self.view.subviews {
            if view.tag == 2345 { view.removeFromSuperview() }
        }
        
        let backview = UIView()
        backview.tag = 234
        backview.frame = self.view.bounds
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds;
        gradient.colors = [UIColor(white: 0.11, alpha: 1).cgColor, UIColor.black.cgColor]
        gradient.zPosition = -1;
        
        self.view.layer.insertSublayer(gradient, at: 0)
    }
}

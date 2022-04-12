//
//  AMGAlertController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 14/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

enum TypeAlert {
    case AlertWithTitleAndMessage
    case AlertWithErrorMessage
    case AlertWithYesAndNo
    case AlertWithDoubleActions
    case AlertWithThreeActions
    case AlertWithoutMessageView
}

class AMGAlertController: UIViewController {

    var header: String = ""
    var message: String = ""
    
    var customActionName: String = ""
    var cancelActionName: String = ""
    var okActionName: String = ""
    var action1Name: String = ""
    var action2Name: String = ""
    
    var customActionColor: UIColor!
    var cancelActionColor: UIColor!
    var okActionColor: UIColor!
    var action1Color: UIColor!
    var action2Color: UIColor!

    var customActionCompletion:()->(Void) = {}
    var cancelActionCompletion:()->(Void) = {}
    var okActionCompletion:()->(Void) = {}
    var action1Completion:()->(Void) = {}
    var action2Completion:()->(Void) = {}
    
    var typeAlert = TypeAlert.AlertWithErrorMessage
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var customActionView: UIView!
    @IBOutlet weak var cancelActionView: UIView!
    @IBOutlet weak var okActionView: UIView!
    @IBOutlet weak var doubleActionView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var customActionLabel: UILabel!
    @IBOutlet weak var cancelActionLabel: UILabel!
    @IBOutlet weak var okActionLabel: UILabel!
    @IBOutlet weak var action1Label: UILabel!
    @IBOutlet weak var action2Label: UILabel!
    
    @IBOutlet weak var customActionButton: AMGButton!
    @IBOutlet weak var cancelActionButton: AMGButton!
    @IBOutlet weak var okActionButton: AMGButton!
    @IBOutlet weak var action1Button: AMGButton!
    @IBOutlet weak var action2Button: AMGButton!
    
    @IBOutlet weak var customActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var okActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var okActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doubleActionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var MainViewCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var cancelButtonActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonActionTrailingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelLabelActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var cancelLabelActionTrailingConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var okButtonActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okButtonActionTrailingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okLabelActionLeadingConstaint: NSLayoutConstraint!
    @IBOutlet weak var okLabelActionTrailingConstaint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.layer.cornerRadius = 6
        
        titleLabel.text = header;
        messageLabel.text = message;
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20;
        style.maximumLineHeight = 20;
        style.alignment = NSTextAlignment.center;
        let attributtes = [NSAttributedString.Key.paragraphStyle: style];
        
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributtes)
        messageLabel.sizeToFit()
        
        if (typeAlert == TypeAlert.AlertWithTitleAndMessage) {
            
            customActionLabel.text = "";
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 0;
            
            cancelActionLabel.text = "";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 0;
            
            okActionLabel.text = "Закрыть";
            okActionViewHeightConstraint.constant = 60;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == TypeAlert.AlertWithErrorMessage) {
            
            customActionLabel.text = ""
            customActionViewTopConstraint.constant = 0
            customActionViewHeightConstraint.constant = 0
            
            cancelActionLabel.text = "Закрыть"
            cancelActionViewTopConstraint.constant = 0
            cancelActionViewHeightConstraint.constant = 60
            
            okActionLabel.text = "";
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 0;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == TypeAlert.AlertWithYesAndNo) {
            
            customActionLabel.text = "";
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 0;
            
            cancelActionLabel.text = cancelActionName;
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 42;
            
            cancelButtonActionBottomConstraint.constant = 2
            cancelButtonActionLeadingConstaint.constant = 51;
            cancelLabelActionLeadingConstaint.constant = 73;
            okButtonActionTrailingConstaint.constant = 51;
            okLabelActionTrailingConstaint.constant = 73;
            
            okActionLabel.text = okActionName;
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 60;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == TypeAlert.AlertWithDoubleActions) {
            
            customActionLabel.text = "";
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 0;
            
            cancelActionLabel.text = "";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 0;
            
            okActionLabel.text = "";
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 0;
            
            action1Label.text = action1Name
            action2Label.text = action2Name
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 60
            
        } else if (typeAlert == TypeAlert.AlertWithThreeActions) {
            
            customActionLabel.text = customActionName;
            customActionViewTopConstraint.constant = 0;
            customActionViewHeightConstraint.constant = 60;
            
            cancelActionLabel.text = cancelActionName;
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 60;
            
            okActionLabel.text = okActionName;
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 60;
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
            
        } else if (typeAlert == TypeAlert.AlertWithoutMessageView) {
            
            messageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            messageView.isHidden = true
            
            cancelActionLabel.text = "Отмена";
            cancelActionViewTopConstraint.constant = 0;
            cancelActionViewHeightConstraint.constant = 60;
            
            okActionLabel.text = okActionName;
            okActionViewTopConstraint.constant = 0;
            okActionViewHeightConstraint.constant = 60;
            
            if (customActionName != "") {
                customActionLabel.text = customActionName;
                customActionViewTopConstraint.constant = 0;
                customActionViewHeightConstraint.constant = 60;
            } else {
                customActionLabel.text = "";
                customActionViewTopConstraint.constant = 0;
                customActionViewHeightConstraint.constant = 0;
            }
            
            action1Label.text = ""
            action2Label.text = ""
            doubleActionViewTopConstraint.constant = 0
            doubleActionViewHeightConstraint.constant = 0
        }
        
        if let color = customActionColor {
            customActionButton._color = color
        }
        
        if let color = cancelActionColor {
            cancelActionButton._color = color
        }
        
        if let color = okActionColor {
            okActionButton._color = color
        }
        
        if let color = action1Color {
            action1Button._color = color
        }
        
        if let color = action2Color {
            action2Button._color = color
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.transition(with: mainView, duration: 0.25, options: .transitionFlipFromTop, animations: {
            self.mainView.isHidden = false
        }, completion: nil)
        
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (self.view.bounds.height < 600) {
            mainViewLeadingConstraint.constant = 20
        }
    }
    
    @IBAction func customAction(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: customActionCompletion)
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: cancelActionCompletion)
    }
    
    @IBAction func okAction(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: okActionCompletion)
    }
    
    @IBAction func action1(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: action1Completion)
    }
    
    @IBAction func action2(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: action2Completion)
    }
}

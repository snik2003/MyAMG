//
//  ViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 13/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import SwiftyJSON


class StartViewController: UIViewController {

    var playVideo = true
    
    let playerController = AVPlayerViewController()
    let playerController2 = AVPlayerViewController()
    
    @IBOutlet weak var bgImage: UIImageView!
    
    var logoImage = UIImageView()
    var loginButton = AMGButton()
    var regButton = UIButton()
    
    var logoImage2 = UIImageView()
    var loginButton2 = AMGButton()
    var regButton2 = UIButton()
    
    var screenHeight: CGFloat = 0
    var screenWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AMGSettings.shared.loadSettings()
        if (playVideo) { playLoadingVideo() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!playVideo) { playVideoBG() }
        
        logoImage.isHidden = true
        loginButton.isHidden = true
        regButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        placeUIObjectAbovePLayer()
        placeUIObjectAboveViewController()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private func playLoadingVideo() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "Loading", ofType:"mp4")
        
        let filePathURL = NSURL.fileURL(withPath: path!)
        let player = AVPlayer(url: filePathURL)
        
        playerController.view.frame = self.view.frame
        playerController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerController.player = player
        playerController.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
        
        self.navigationController?.present(playerController, animated: false) {
            if !AMGSettings.shared.soundOn { player.volume = 0 }
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    private func playVideoBG() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "videobg", ofType:"mp4")
        
        let filePathURL = NSURL.fileURL(withPath: path!)
        let player = AVPlayer(url: filePathURL)
        
        playerController2.view.frame = self.view.frame
        playerController2.contentOverlayView?.frame = self.view.frame
        playerController2.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerController2.player = player
        playerController2.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController2.player?.currentItem, queue: nil, using: { _ in
            if !AMGSettings.shared.soundOn { player.volume = 0 }
            player.seek(to: CMTime.zero)
            player.play()
        })
        
        self.navigationController?.present(playerController2, animated: false) {
            if !AMGSettings.shared.soundOn { player.volume = 0 }
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
        playerController.dismiss(animated: false) {
            
            AMGUser.shared.loadCurrentUser()
            
            if (AMGUser.shared.isRegistered) {
                AMGUser.shared.loginForRegisteredUser()
            } else {
                if (self.playVideo) { self.playVideoBG() }
            }
            
            AMGAutorizationManager().launch()
        }
    }
    
    @objc func loginButtonAction2() {
        playerController2.dismiss(animated: false) {
            self.bgImage.isHidden = false
            self.logoImage.isHidden = false
            self.loginButton.isHidden = false
            self.regButton.isHidden = false
            
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .overCurrentContext
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @objc func loginButtonAction() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .overCurrentContext
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @objc func regButtonAction2() {
        playerController2.dismiss(animated: false, completion: {
            self.bgImage.isHidden = false
            self.logoImage.isHidden = false
            self.loginButton.isHidden = false
            self.regButton.isHidden = false
            
            let regVC = RegViewController()
            regVC.modalPresentationStyle = .overCurrentContext
            self.present(regVC, animated: false, completion: nil)
            regVC.dismiss(animated: false, completion: nil)
            
            AMGUser.shared.userUUID = ""
            
            self.showHUD()
            API_WRAPPER.srvGetGUID({ data in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    if var guid = String(data: data!, encoding: String.Encoding.utf8) {
                        guid = guid.replacingOccurrences(of: "\"", with: "")
                        if (guid.count > 0) {
                            AMGUser.shared.userUUID = guid
                            let regVC = RegViewController()
                            regVC.modalPresentationStyle = .overCurrentContext
                            self.present(regVC, animated: true, completion: nil)
                            return
                        }
                        self.showServerError()
                    }
                }
            }, failure: { _ in
                OperationQueue.main.addOperation {
                    self.hideHUD()
                    self.showServerError()
                }
            })
        })
    }
    
    @objc func regButtonAction() {
        AMGUser.shared.userUUID = ""
        
        self.showHUD()
        API_WRAPPER.srvGetGUID({ data in
            OperationQueue.main.addOperation {
                self.hideHUD()
                if var guid = String(data: data!, encoding: String.Encoding.utf8) {
                    guid = guid.replacingOccurrences(of: "\"", with: "")
                    if (guid.count > 0) {
                        AMGUser.shared.userUUID = guid
                        let regVC = RegViewController()
                        regVC.modalPresentationStyle = .overCurrentContext
                        self.present(regVC, animated: true, completion: nil)
                        return
                    }
                    self.showServerError()
                }
            }
        }, failure: { _ in
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    func showHUD() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func hideHUD() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().hideActivityIndicator()
            
            if (UIApplication.shared.isIgnoringInteractionEvents) {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func showErrorAlert(WithTitle title: String, andMessage text: String, completion:@escaping ()->(Void)) {
        
        let alertVC = AMGAlertController()
        
        alertVC.typeAlert = TypeAlert.AlertWithErrorMessage
        alertVC.header = title
        alertVC.message = text
        
        alertVC.customActionCompletion = {}
        alertVC.cancelActionCompletion = completion
        alertVC.okActionCompletion = {}
        
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showServerError() {
        showErrorAlert(WithTitle: "Внимание!", andMessage: "Ошибка при обращении к серверу. Попробуйте повторить позже.", completion: {})
    }
    
    func placeUIObjectAbovePLayer() {
        
        logoImage2.frame = CGRect(x: (screenWidth - 261) / 2, y: 56, width: 261, height: 22)
        logoImage2.image = UIImage(named: "amgLogo")
        logoImage2.clipsToBounds = true
        logoImage2.contentMode = .scaleAspectFit
        playerController2.contentOverlayView?.addSubview(logoImage2)
        
        loginButton2.removeTarget(self, action: nil, for: .touchUpInside)
        loginButton2.frame = CGRect(x: 50, y: screenHeight - 160, width: screenWidth - 100, height: 50)
        loginButton2.addTarget(self, action: #selector(loginButtonAction2), for: .touchUpInside)
        loginButton2.setTitle("Войти", for: .normal)
        loginButton2.titleLabel?.textColor = .white
        loginButton2.titleLabel?.font = UIFont(name: "DaimlerCS-Demi", size: 18)
        playerController2.contentOverlayView?.addSubview(loginButton2)
        
        regButton2.removeTarget(self, action: nil, for: .touchUpInside)
        regButton2.frame = CGRect(x: 50, y: screenHeight - 90, width: screenWidth - 100, height: 30)
        regButton2.addTarget(self, action: #selector(regButtonAction2), for: .touchUpInside)
        regButton2.setTitle("Регистрация", for: .normal)
        regButton2.titleLabel?.textColor = .white
        regButton2.titleLabel?.font = UIFont(name: "DaimlerCS-Demi", size: 18)
        playerController2.contentOverlayView?.addSubview(regButton2)
    }
    
    func placeUIObjectAboveViewController() {
        
        logoImage.frame = CGRect(x: (screenWidth - 261) / 2, y: 56, width: 261, height: 22)
        logoImage.image = UIImage(named: "amgLogo")
        logoImage.clipsToBounds = true
        logoImage.contentMode = .scaleAspectFit
        view.addSubview(logoImage)
        
        loginButton.removeTarget(self, action: nil, for: .touchUpInside)
        loginButton.frame = CGRect(x: 50, y: screenHeight - 160, width: screenWidth - 100, height: 50)
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.textColor = .white
        loginButton.titleLabel?.font = UIFont(name: "DaimlerCS-Demi", size: 18)
        view.addSubview(loginButton)
        
        regButton.removeTarget(self, action: nil, for: .touchUpInside)
        regButton.frame = CGRect(x: 50, y: screenHeight - 90, width: screenWidth - 100, height: 30)
        regButton.addTarget(self, action: #selector(regButtonAction), for: .touchUpInside)
        regButton.setTitle("Регистрация", for: .normal)
        regButton.titleLabel?.textColor = .white
        regButton.titleLabel?.font = UIFont(name: "DaimlerCS-Demi", size: 18)
        view.addSubview(regButton)
    }
}


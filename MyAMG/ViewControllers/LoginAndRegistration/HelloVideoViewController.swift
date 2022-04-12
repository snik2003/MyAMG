//
//  HelloVideoViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 03/09/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class HelloVideoViewController: UIViewController {

    let playerController = AVPlayerViewController()
    
    var dismissButton = UIButton()
    var closeButton = UIButton()
    
    var screenHeight: CGFloat = 0
    var screenWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        playHelloVideo()
        placeUIObjectAboveViewController()
    }
    
    private func playHelloVideo() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "Insta", ofType:"mp4")
        
        let filePathURL = NSURL.fileURL(withPath: path!)
        let player = AVPlayer(url: filePathURL)
        
        playerController.view.frame = self.view.frame
        playerController.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerController.player = player
        playerController.showsPlaybackControls = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
        
        self.present(playerController, animated: false) {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        closeButton.isHidden = false
        dismissButton.setTitle("Повторить", for: .normal)
        dismissButton.removeTarget(self, action: nil, for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(repeatAction), for: .touchUpInside)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
    }
    
    func placeUIObjectAboveViewController() {
        
        dismissButton.frame = CGRect(x: 50, y: screenHeight - 90, width: screenWidth - 100, height: 30)
        dismissButton.setTitle("Пропустить", for: .normal)
        dismissButton.removeTarget(self, action: nil, for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        dismissButton.titleLabel?.textColor = .white
        dismissButton.titleLabel?.font = UIFont(name: "DaimlerCS-Demi", size: 18)
        playerController.contentOverlayView?.addSubview(dismissButton)
        
        closeButton.frame = CGRect(x: screenWidth - 52, y: 5, width: 40, height: 40)
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(named: "close2"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.isHidden = true
        playerController.contentOverlayView?.addSubview(closeButton)
    }
    
    @objc func repeatAction() {
        dismissButton.setTitle("Пропустить", for: .normal)
        dismissButton.removeTarget(self, action: nil, for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
        playerController.dismiss(animated: false) {
            OperationQueue.main.addOperation {
                self.playHelloVideo()
                self.placeUIObjectAboveViewController()
            }
        }
    }
    
    @objc func dismissAction() {
        playerController.player?.pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerController.player?.currentItem)
        playerController.dismiss(animated: false) {
            AMGUser.shared.loadCurrentUser()
            AMGUser.shared.loginForRegisteredUser()
        }
    }
}

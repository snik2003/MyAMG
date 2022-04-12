//
//  CaptureVINViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 27/07/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureVINViewController: InnerViewController {

    let screenName = "vin_recognize"
    
    var delegate: InnerViewController!
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var cameraButtonCircle: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var capturedImage = UIImageView()
    
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session queue",
                                     attributes: [],
                                     target: nil)
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    var setupResult: SessionSetupResult = .success
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YMReport(message: screenName)
        
        titleLabel.text = "Сканировать VIN"
        
        cameraButtonCircle.layer.cornerRadius = cameraButtonCircle.bounds.width/2
        cameraButton.layer.cornerRadius = cameraButton.bounds.width/2
        cameraButton.layer.borderWidth = 2.0
        cameraButton.layer.borderColor = UIColor.white.cgColor
        
        checkAuthorization()
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                DispatchQueue.main.async { [unowned self] in
                    self.previewView.layoutSubviews()
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                    self.previewLayer.frame = self.previewView.layer.bounds
                    self.previewLayer.videoGravity = .resizeAspectFill;
                    self.previewView.layer.addSublayer(self.previewLayer)
                    
                    self.setupPreviewView()
                    
                    let topY = self.previewView.bounds.height/2 - 25
                    let width = self.previewView.bounds.width - 80
                    self.capturedImage.frame = CGRect(x: 40, y: topY, width: width, height: 40)
                    self.previewView.addSubview(self.capturedImage)
                    
                    self.session.startRunning()
                }
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    self.showAlertWithDoubleActions(title: "Внимание!", text: "Отсутствует разрешение на использование камеры в приложении.\n\nПожалуйста, измените настройки приватности для приложения \"My AMG\".", title1: "Настройки", title2: "Отмена", completion: {
                        
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }, completion2: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    self.showAttention(message: "Неизвестная ошибка при обращении к камере")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    func setupPreviewView() {
        
        capturedImage.layer.borderWidth = 3
        capturedImage.layer.borderColor = AMGButton()._color.cgColor
        
        let upLeftPoint = CGPoint(x: 20, y: 20)
        let upRightPoint = CGPoint(x: previewView.bounds.width - 20, y: 20)
        let downLeftPoint = CGPoint(x: 20, y: previewView.bounds.height - 20)
        let downRightPoint = CGPoint(x: previewView.bounds.width - 20, y: previewView.bounds.height - 20)
        
        drawHorizontLineToPreviewView(from: upLeftPoint)
        drawVerticalLineToPreviewView(from: upLeftPoint)
        
        drawHorizontLineToPreviewView(from: CGPoint(x: upRightPoint.x - 50, y: upRightPoint.y))
        drawVerticalLineToPreviewView(from: upRightPoint)
        
        drawHorizontLineToPreviewView(from: downLeftPoint)
        drawVerticalLineToPreviewView(from: CGPoint(x: downLeftPoint.x, y: downLeftPoint.y - 50))
        
        drawHorizontLineToPreviewView(from: CGPoint(x: downRightPoint.x - 48, y: downRightPoint.y))
        drawVerticalLineToPreviewView(from: CGPoint(x: downRightPoint.x, y: downRightPoint.y - 48))
    }
    
    func drawHorizontLineToPreviewView(from x1: CGPoint) {
        let line = UIView()
        line.frame = CGRect(x: x1.x, y: x1.y, width: 50, height: 3)
        line.backgroundColor = AMGButton()._color
        previewView.addSubview(line)
    }
    
    func drawVerticalLineToPreviewView(from x1: CGPoint) {
        let line = UIView()
        line.frame = CGRect(x: x1.x, y: x1.y, width: 3, height: 50)
        line.backgroundColor = AMGButton()._color
        previewView.addSubview(line)
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted { self.setupResult = .notAuthorized }
            })
        default:
            setupResult = .notAuthorized
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            let dualCameraDeviceType: AVCaptureDevice.DeviceType
            if #available(iOS 11, *) {
                dualCameraDeviceType = .builtInDualCamera
            } else {
                dualCameraDeviceType = .builtInDuoCamera
            }
            
            if let dualCameraDevice = AVCaptureDevice.default(dualCameraDeviceType, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    @IBAction private func capturePhoto(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        if self.videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }
        
        if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
        }
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CaptureVINViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
                
                if var image = UIImage(data: dataImage) {
                    let scale = image.size.width / previewView.bounds.width
                    let vinWidth = capturedImage.bounds.width * scale
                    let vinHeight = capturedImage.bounds.height * scale
                    let vinRect = CGRect(x: (image.size.width - vinWidth)/2, y: (image.size.height - vinHeight)/2, width: vinWidth, height: vinHeight)
                    
                    image = image.fixOrientationOfImage()
                    self.capturedImage.image = image.cropToRect(rect: vinRect)
                    self.vinRecognize(image: self.capturedImage.image)
                }
            }
        }
        
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        showHUD()
        guard let data = photo.fileDataRepresentation(), var image = UIImage(data: data) else {
            hideHUD()
            showAlert(WithTitle: "Внимание!", andMessage: "Возникла неизвестная ошибка при сканрировании VIN номера.", completion: {
                self.dismiss(animated: true, completion: nil)
            })
            return
        }
        
        let scale = image.size.width / previewView.bounds.width
        let vinWidth = capturedImage.bounds.width * scale
        let vinHeight = capturedImage.bounds.height * scale
        let vinRect = CGRect(x: (image.size.width - vinWidth)/2, y: (image.size.height - vinHeight)/2, width: vinWidth, height: vinHeight)
        
        image = image.fixOrientationOfImage()
        
        self.hideHUD()
        self.capturedImage.image = image.cropToRect(rect: vinRect)
        self.vinRecognize(image: self.capturedImage.image)
    }
    
    func vinRecognize(image: UIImage?) {
        
        if !CheckConnection() { return }
        
        showHUD()
        MMPhotoTextRecognizer.recognizeVIN(image!, completion: { result, text, errorMessage in
            
            self.hideHUD()
            OperationQueue.main.addOperation {
                switch result {
                case MMPhotoTextRecognizerResultOK:
                    self.dismiss(animated: true, completion: {
                        if let controller = self.delegate as? MyAutoViewController {
                            self.YMReport(message: controller.screenName, parameters: ["action":"vin_recognised_successfully"])
                            controller.vinTextField.text = text
                        } else if let controller = self.delegate as? RegViewController {
                            self.YMReport(message: controller.screenName, parameters: ["action":"vin_recognised_successfully"])
                            controller.vinTextField.text = text
                        }
                    })
                default:
                    self.YMReport(message: self.screenName, parameters: ["error":"vin_recognise_failed"])
                    self.showAlertWithDoubleActions(title: "Внимание!", text: errorMessage!, title1: "Повторить", title2: "Отмена", completion: {
                        self.capturedImage.image = nil
                    }, completion2: {
                        self.dismiss(animated: true, completion: {
                            if let controller = self.delegate as? MyAutoViewController {
                                controller.vinTextField.becomeFirstResponder()
                            } else if let controller = self.delegate as? RegViewController {
                                controller.vinTextField.becomeFirstResponder()
                            }
                        })
                    })
                }
            }
        })
    }
}

//
//  sendWithQR.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 DigiliraPay. All rights reserved.
//

import UIKit
import AVFoundation


class sendWithQR: UIView {
    
    @IBOutlet weak var galleryButtonView: UIView!
    @IBOutlet weak var qrAreaView: UIView!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var qrverisi:String?
    let digiliraPay = digiliraPayApi()
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    weak var delegate: SendWithQrDelegate?
    
    func openCamera() {
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            if let outputs = captureSession.outputs as? [AVCaptureMetadataOutput] {
                for output in outputs {
                    captureSession.removeOutput(output)
                }
            }
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            delegate?.sendWithQRError(error: error)
            return
        }
        qrCodeFrameView = UIView()
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = CGRect(x: 0,
                                          y: qrAreaView.frame.minY,
                                          width: UIScreen.main.bounds.size.width,
                                          height: UIScreen.main.bounds.size.height)
        
        self.layer.addSublayer(videoPreviewLayer!)
        
        captureSession.startRunning()
        
        self.bringSubviewToFront(qrCodeFrameView!)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let myView = UIView(frame: CGRect(x: 0, y: qrAreaView.frame.minY, width: screenSize.width, height: screenSize.height - qrAreaView.frame.minY))
         
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect.init(x: 0, y: screenSize.height - qrAreaView.frame.minY - 100, width: screenSize.width, height: 100)
        
        myView.addSubview(blurEffectView)
        self.addSubview(myView)
         
        let closeView = UIView(frame: CGRect(x: screenSize.width / 2 - 25, y: screenSize.height - 75, width: 50, height:50))
        closeView.layer.cornerRadius = 25
        closeView.backgroundColor = .white
        
        let myLogo = UIImageView(frame: CGRect(x: 15, y: 15, width: 20, height: 20))
     
        myLogo.image = UIImage(named: "exit")
        closeView.addSubview(myLogo)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exit))
        closeView.addGestureRecognizer(tap)
        
        setShadExt(view: closeView, cornerRad: 25, mask: true)
        self.addSubview(closeView)
        
    }
    
    @IBAction func btnGallery(_ sender: Any) {
        
    }
    @objc func openGallery()
    {
        
    }
    
    @objc func exit() {
        captureSession.stopRunning()
        delegate?.dismissSendWithQr(url: "")
    }
    
    @IBAction func exitButton(_ sender: Any)
    {
        captureSession.stopRunning()
        delegate?.dismissSendWithQr(url: "")
    }
}


extension sendWithQR: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            
            return
            
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as!  AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
                
                if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                    for input in inputs {
                        captureSession.removeInput(input)
                    }
                }
                
                if let outputs = captureSession.outputs as? [AVCaptureMetadataOutput] {
                    for output in outputs {
                        captureSession.removeOutput(output)
                    }
                }
                qrverisi = metadataObj.stringValue!
                
                delegate?.dismissSendWithQr(url: qrverisi!)
                captureSession.stopRunning()
                
                
            }
        }
    }
    
}

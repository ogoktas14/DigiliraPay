//
//  sendWithQR.swift
//  DigiliraPay
//
//  Created by Yusuf Özgül on 5.09.2019.
//  Copyright © 2019 Ilao. All rights reserved.
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

 
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    
    weak var delegate: SendWithQrDelegate?
    
    
    override func didMoveToSuperview() {
        openCamera()
    }
    
    override func awakeFromNib()
    {
        
        
       
    }
    
    
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
                   print(error)
                   return
               }
               qrCodeFrameView = UIView()
        
               // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
               videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
               videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
               videoPreviewLayer?.frame = qrAreaView.frame
               
               self.layer.addSublayer(videoPreviewLayer!)
               
        
               
               
               // Start video capture.
               captureSession.startRunning()
               
               // Move the message label and top bar to the front
              

               
               
               // Initialize QR Code Frame to highlight the QR code

               
               
               self.bringSubviewToFront(qrCodeFrameView!)
        
        
    }
    
    @objc func openGallery()
    {
        
    }
    
    func getOrder (QR: String) {
 
        digiliraPay.postData(PARAMS: QR
        ) { (json) in
            
            DispatchQueue.main.async {
                
                let order = digilira.order.init(_id: (json["id"] as? String)!,
                                                merchant: (json["merchant"] as? String)!,
                                                user: json["merchant"] as? String,
                                                language: json["language"] as? String,
                                                order_ref: json["order_ref"] as? String,
                                                createdDate: json["createdDate"] as? String,
                                                order_date: json["order_date"] as? String,
                                                order_shipping: json["order_shipping"] as? Double,
                                                conversationId: json["conversationId"] as? String,
                                                rate: (json["rate"] as? Int64)!,
                                                totalPrice: json["totalPrice"] as? Double,
                                                paidPrice: json["paidPrice"] as? Double,
                                                refundPrice: json["refundPrice"] as? Double,
                                                currency: json["currency"] as? String,
                                                currencyFiat: json["currencyFiat"] as? Double,
                                                userId: json["userId"] as? String,
                                                paymentChannel: json["paymentChannel"] as? String,
                                                ip: json["ip"] as? String,
                                                registrationDate: json["registrationDate"] as? String,
                                                wallet: (json["wallet"] as? String)!,
                                                asset: json["asset"] as? String,
                                                successUrl: json["successUrl"] as? String,
                                                failureUrl: json["failureUrl"] as? String,
                                                callbackSuccess: json["callbackSuccess"] as? String,
                                                callbackFailure: json["callbackFailure"] as? String,
                                                mobile: json["mobile"] as? Int64,
                                                status: json["status"] as? Int64)

                
                self.delegate?.sendQR(ORDER: order)

                
            }
        }
    
    }
    
    @IBAction func exitButton(_ sender: Any)
    {
        captureSession.stopRunning()
        delegate?.dismissSendWithQr()
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
                
                qrverisi = metadataObj.stringValue!
                let array = qrverisi!.components(separatedBy: CharacterSet.init(charactersIn: "://"))

                //launchApp(decodedURL: metadataObj.stringValue!)
                delegate?.dismissSendWithQr()
                captureSession.stopRunning()
                getOrder(QR:array[3])

                

            }
        }
    }
    
}

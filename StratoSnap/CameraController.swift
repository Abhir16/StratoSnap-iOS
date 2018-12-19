//
//  CameraController.swift
//  StratoSnap
//
//  Created by Abhishek  Ravi on 2018-12-15.
//  Copyright © 2018 Abhishek  Ravi. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

protocol CameraControllerDelegate: class {
    func captured(image: UIImage)
}

class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    var counter = 0
    weak var delegate: CameraControllerDelegate?
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        }
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: FIX THIS LOGIC UIImage is not being created properly!!
        DispatchQueue.main.async { [unowned self] in
            let uiImage = self.getImageFromSampleBuffer(sampleBuffer: sampleBuffer)
            print("esketit")
            self.delegate?.captured(image: uiImage!)
        }
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
}

extension CameraController {
    
    enum CameraControllerError: Swift.Error {// error types
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    print("Unable to access back camera!")
                    return
            }
            // set mode to autofocus
            try backCamera.lockForConfiguration()
            backCamera.focusMode = .continuousAutoFocus
            backCamera.unlockForConfiguration()
            
            self.rearCamera = backCamera
        }
        
        func configureDeviceInputs() throws {
            //3
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            //4
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera!)
            if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
                let captureOutputFrames = AVCaptureVideoDataOutput()
                captureOutputFrames.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                guard captureSession.canAddOutput(captureOutputFrames) else { return }
                captureSession.addOutput(captureOutputFrames)
            }
            
            captureSession.startRunning()
        }
        
//        func convert(cmage:CIImage) -> UIImage
//        {
//            let context:CIContext = CIContext.init(options: nil)
//            let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
//            let image:UIImage = UIImage.init(cgImage: cgImage)
//            return image
//        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}

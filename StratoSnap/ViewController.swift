//
//  ViewController.swift
//  StratoSnap
//
//  Created by Abhishek  Ravi on 2018-12-15.
//  Copyright © 2018 Abhishek  Ravi. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    @IBOutlet fileprivate var capturePreviewView: PreviewView!
    let cameraController = CameraController()
    
    @IBOutlet weak var captureButton: UIButton!
    
    @IBAction func captureClicked(_ sender: Any) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            print("Image Captured!")
            
            try? PHPhotoLibrary.shared().performChangesAndWait {// save to library
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    ///Displays a preview of the video output generated by the device's cameras.
    
    ///Allows the user to put the camera in photo mode.
    @IBOutlet fileprivate var photoModeButton: UIButton!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    
    ///Allows the user to put the camera in video mode.
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //capturePreviewView.session = cameraController.captureSession
        print("hello world")
        
        cameraController.delegate = self
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        //        func styleCaptureButton() {
        //            captureButton.layer.borderColor = UIColor.black.cgColor
        //            captureButton.layer.borderWidth = 2
        //
        //            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        //        }
        //        styleCaptureButton()
        configureCameraController()
    }
    
    
}

extension ViewController: CameraControllerDelegate {
    
    func captured(image: UIImage) {
        DispatchQueue.main.async(execute: {
            print("esketit")
        })
    }
    func handleFaces(request: VNRequest, error: Error?) {
        print("handling faces!!")
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.capturePreviewView.removeMask()
            for face in results {
                self.capturePreviewView.drawFaceboundingBox(face: face)
            }
        }
    }
}

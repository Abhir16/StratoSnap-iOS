//
//  PreviewView.swift
//  StratoSnap
//
//  Created by Abdulhadi Mohamed on 2/12/19.
//  Copyright © 2019 Abhishek  Ravi. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

enum GimbalState {
    case idle
    case capture
    case moveUp
    case moveDown
}

class PreviewView: UIView {
    
    private var maskLayer = [CAShapeLayer]()
    private var boundingBoxLayer = CAShapeLayer()
    private var state: GimbalState = .idle
    private var captureCount: CGFloat = 0.0
    private static var captureMax: CGFloat = 50
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    public func createBoundBoxLayer(settings: FlightSettings) {
        let rect = CGRect(x: frame.width * settings.position! ,y: 0.0, width: frame.width * settings.height! ,height: frame.height)
        boundingBoxLayer.frame = rect
        boundingBoxLayer.borderColor = UIColor.green.cgColor
        boundingBoxLayer.opacity = 0.75
        boundingBoxLayer.borderWidth = 2.0
        layer.insertSublayer(boundingBoxLayer, at: 1)
        print("bounding box topleft coord is " + boundingBoxLayer.frame.height.description + " " + boundingBoxLayer.frame.width.description)
        
    }
    
    private func drawFace(in rect: CGRect) -> Void {
        let mask = CAShapeLayer()
        mask.frame = rect //CGRect(origin: rect.origin,  size: CGSize(width: rect.size.height, height: rect.size.width))
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0
        
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
    }
    
    // Create a new layer drawing the bounding box
    public func getCaptureState() -> Bool {
        var upWeight: CGFloat = 0.0
        var downWeight:CGFloat = 0.0
        var captureWeight:CGFloat = 0.0
        for layer in maskLayer {
            let topLeft = CGPoint(x:layer.frame.minX, y:layer.frame.minY);
            let topRight = CGPoint(x:layer.frame.maxX, y:layer.frame.minY);
            let bottomLeft = CGPoint(x:layer.frame.minY, y:layer.frame.maxY);
            let bottomRight = CGPoint(x:layer.frame.maxX, y:layer.frame.maxY);
            let height = layer.frame.height
            let width = layer.frame.width
            let area = height * width
            // TODO: change the capture condition such that if over x % of bounding box hieght is filled, capture picture
            print("this is the area" + area.description)
            if ( boundingBoxLayer.frame.contains(topLeft) && ( width > boundingBoxLayer.frame.width || boundingBoxLayer.frame.contains(bottomLeft) )
                || boundingBoxLayer.frame.contains(bottomLeft) && ( (width > boundingBoxLayer.frame.width)  || boundingBoxLayer.contains(topLeft) )) {
                captureWeight += area
            }
            else if (boundingBoxLayer.frame.minX < topLeft.x) {
                downWeight += area
            }
            else {
                upWeight += area
            }
        }
        let maxWeight = max(downWeight, upWeight, captureWeight )
        if maxWeight.isEqual(to: 0.0) {
            state = .idle
            print("need to idle!")
        }
        else if (maxWeight.isEqual(to: downWeight)) {
            state = .moveDown
            print("need to move up!")
        }
        else if (maxWeight.isEqual(to: upWeight)) {
            state = .moveUp
            print("need to move down!")
        }
        else {
            state = .capture
            print("need to capture!")
            
            if self.captureCount < PreviewView.captureMax {
                return true
            }
            print("...captureCount is " + self.captureCount.description )
            
            self.captureCount += 1
        }
        
        return false
    }
    
    public func drawFaceboundingBox(face : VNFaceObservation) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        var facebounds = face.boundingBox.applying(translate).applying(transform)
        // temporary, need to find the proper transform to achieve same result as below - required for landscape
        facebounds = CGRect(origin: facebounds.origin,  size: CGSize(width: facebounds.size.height, height: facebounds.size.width))
        
        drawFace(in:facebounds)
        
    }
    
    public func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}


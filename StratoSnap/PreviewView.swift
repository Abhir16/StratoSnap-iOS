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
    private var upCount: CGFloat = 0.0
    private var downCount: CGFloat = 0.0
    private static var UpThreshold:CGFloat = 2.0
    private static var DownThreshold:CGFloat = 2.0
    private var consecutiveCaptureCount: CGFloat = 0.0
    private static var CONFIDENCE_THRESHOLD: CGFloat = 2
    private static var INTERSECTION_THRESHOLD: CGFloat = 0.5
    private var increment: CGFloat = 5.0
    private var position:CGFloat = 50
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
        
        let url = URL(string: "http://172.20.10.6/dji_naza_web_interface/ccommand.php?move_gimbal_value="+position.description+"&"+"move_gimbal_time=1")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
//
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
    private func sendPositionRequest() {
    
        let url = URL(string: "http://172.20.10.6/dji_naza_web_interface/ccommand.php?move_gimbal_value="+self.position.description+"&"+"move_gimbal_time=1")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
    
    // Create a new layer drawing the bounding box
    public func getCaptureState() -> Bool {
        var upWeight: CGFloat = 0.0
        var downWeight:CGFloat = 0.0
        var captureWeight:CGFloat = 0.0
        
        for layer in maskLayer {
            let height = layer.frame.height
            let width = layer.frame.width
            let area = height * width
            let intersectingRect = boundingBoxLayer.frame.intersection(layer.frame)
            
            let percent_intersection = intersectingRect.width / width
            print("this is the intersection " + percent_intersection.description)
            print("percent intersection: " + percent_intersection.description)
            if ( percent_intersection >= PreviewView.INTERSECTION_THRESHOLD) {
                captureWeight += area
            }
            else if (boundingBoxLayer.frame.midX < layer.frame.midX) {
                downWeight += area
            }
            else {
                upWeight += area
            }
        }
        let maxWeight = max(downWeight, upWeight, captureWeight )
        if maxWeight.isEqual(to: 0.0) {
            state = .idle
            self.downCount = 0
            self.upCount = 0
            self.consecutiveCaptureCount = 0
            print("need to idle!")
        }
        else if (maxWeight.isEqual(to: downWeight)) {
            if (upCount > PreviewView.UpThreshold) {
                state = .moveDown
                self.position = min(100, position + increment)
                sendPositionRequest()
                self.upCount = 0
            }
            self.upCount += 1
            self.downCount = 0
            self.consecutiveCaptureCount = 0
            print("need to move up! " + position.description)
        }
        else if (maxWeight.isEqual(to: upWeight)) {
            if (self.downCount > PreviewView.DownThreshold) {
                state = .moveUp
                self.position = max(0, position - increment)
                sendPositionRequest()
                self.downCount = 0
            }
            self.downCount += 1
            self.upCount = 0
            self.consecutiveCaptureCount = 0
            print("need to move down! " + position.description)
        }
        else {
            state = .capture
            print("need to capture!")
//            if self.consecutiveCaptureCount >= PreviewView.CONFIDENCE_THRESHOLD {
//                self.consecutiveCaptureCount = 0.0
//                return true
//            }
            self.downCount = 0
            self.upCount = 0
            self.consecutiveCaptureCount += 1.0
        }
        
        return false
    }
    
    public func drawFaceboundingBox(face : VNFaceObservation) {
        
        let boundingBox = face.boundingBox
        
        let size = CGSize(width: boundingBox.width * frame.height,
                                 height: boundingBox.height * frame.width)

        let origin = CGPoint(x: (1 - boundingBox.maxY) * frame.width,
                             y: (1 - boundingBox.maxX) * frame.height)
        
        drawFace(in:CGRect(origin: origin, size: size))
        
    }
    
    public func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}


//
//  PictureSettingsController.swift
//  StratoSnap
//
//  Created by Abdulhadi Mohamed on 2/24/19.
//  Copyright © 2019 Abhishek  Ravi. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass


class PictureSettingsController: UIViewController {
    var startingYOffset: CGFloat = 0
    var endingYOffset: CGFloat = 0
    
    @IBOutlet weak var ImageBox: UIView!
    @IBOutlet weak var BoundingBox: UIView!
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(boundingBoxViewPanned(recognizer:)))
        return recognizer
    }()
    
    private lazy var pinchRecognizer: UIPinchGestureRecognizer = {
        let recognizer = UIPinchGestureRecognizer()
        recognizer.addTarget(self, action: #selector(boundingBoxViewPinched(recognizer:)))
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PictureSettingsController has loaded!")
       BoundingBox.addGestureRecognizer(panRecognizer)
    BoundingBox.addGestureRecognizer(pinchRecognizer)
        
        let propertyAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 5.0, curve: UIView.AnimationCurve.easeInOut)
        
        propertyAnimator.addAnimations {
            self.BoundingBox.center.y = self.ImageBox.center.y
        }
        propertyAnimator.startAnimation()
        
    }
    
    @objc private func boundingBoxViewPanned(recognizer: UIPanGestureRecognizer)  {
        print("panning motion detected!")
        
//        switch recognizer.state {
//        case .possible:
//            <#code#>
//        case .changed:
//            <#code#>
//        case .ended:
//            <#code#>
//        case .cancelled:
//            <#code#>
//        case .failed:
//            <#code#>
//        case .began:
//            <#code#>
//        }
    }
    
    @objc private func boundingBoxViewPinched(recognizer: UIPinchGestureRecognizer)  {
        print("pinching motion detected!")
//        switch recognizer.state {
//        case .possible:
//            <#code#>
//        case .changed:
//            <#code#>
//        case .ended:
//            <#code#>
//        case .cancelled:
//            <#code#>
//        case .failed:
//            <#code#>
//        case .began:
//            <#code#>
//        }
    }
}

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

struct FlightSettings {
    // store position and height as ImageBoxHeight normalized floats
    var position: CGFloat?
    var height: CGFloat?
    var altitude: CGFloat?
    init(position:CGFloat? = 0.0, height:CGFloat? = 0.0, altitude:CGFloat = 50.0) {
        self.position = position
        self.height = height
        self.altitude = altitude
    }
}

class PictureSettingsController: UIViewController {
    
    struct Constants {
        static let BoundingBoxTopSpacingIntial: CGFloat = 0.0
        static let BoundingBoxHeightInitial: CGFloat = 80
        static let ImageBoxHeight: CGFloat = 270.0
        static let ImageBoxTopSpacing: CGFloat = 130.0
        static let ImageBoxSideSpacing: CGFloat = 10.0
        static let slideAnimationDuration: CGFloat = 1.0
        static let dampingRatio:CGFloat = 0.8
        static let minimumHieght: CGFloat = 50
    }
    var currentHeight = Constants.BoundingBoxHeightInitial
    var bottomConstraintVal = -1 * (Constants.ImageBoxHeight - Constants.BoundingBoxHeightInitial)
    var topConstraintVal = Constants.BoundingBoxTopSpacingIntial
    var info:FlightSettings = FlightSettings(position: 0.0, height: Constants.BoundingBoxHeightInitial/Constants.ImageBoxHeight)
    
    private lazy var ImageBox: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        view.alpha = 1.0
        return view
    }()
    
    private lazy var BoundingBox: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.7294117647, blue: 0.2352941176, alpha: 1)
        view.alpha = 1.0
        return view
    }()
    
    
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
    
    var topConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        print("PictureSettingsController has loaded!")
        BoundingBox.addGestureRecognizer(panRecognizer)
        BoundingBox.addGestureRecognizer(pinchRecognizer)
        ImageBox.addGestureRecognizer(pinchRecognizer)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let flightSettingsController = segue.destination as? FlightSettingsController else {
            return
        }
        flightSettingsController.info = info
    }
    
    private func layout() {
        

        
        view.addSubview(ImageBox)
        ImageBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ImageBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.ImageBoxSideSpacing),
            ImageBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.ImageBoxSideSpacing ),
            ImageBox.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.ImageBoxTopSpacing ),
            ImageBox.heightAnchor.constraint(equalToConstant: Constants.ImageBoxHeight),
        ])
        
        ImageBox.addSubview(BoundingBox)
        BoundingBox.translatesAutoresizingMaskIntoConstraints = false
        
        
        let topConstraint = BoundingBox.topAnchor.constraint(equalTo: ImageBox.topAnchor, constant: topConstraintVal)
        let bottomConstraint = BoundingBox.bottomAnchor.constraint(equalTo: ImageBox.bottomAnchor, constant: bottomConstraintVal)
        
         NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            BoundingBox.leadingAnchor.constraint(equalTo:   ImageBox.leadingAnchor),
            BoundingBox.trailingAnchor.constraint(equalTo:  ImageBox.trailingAnchor)
            ])
        
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
    }
    
    
    @objc private func boundingBoxViewPanned(recognizer: UIPanGestureRecognizer)  {
        switch recognizer.state {
        case .began:
            break
            
        case .changed:
            let translation = recognizer.translation(in: BoundingBox)
            let newPosition = min(max(translation.y, 0), Constants.ImageBoxHeight - self.currentHeight)
            
            UIViewPropertyAnimator(duration: TimeInterval(Constants.slideAnimationDuration),
                                                         dampingRatio: Constants.dampingRatio) {
                                                            
                                                            self.bottomConstraint.constant = -1 * (Constants.ImageBoxHeight - (newPosition + self.currentHeight) )
                                                            self.topConstraint.constant = newPosition
                                                            self.ImageBox.layoutIfNeeded()
                                                self.info.position = newPosition / Constants.ImageBoxHeight
            }.startAnimation()
        case .ended:
            break
        default:
            break
        }
    }


    @objc private func boundingBoxViewPinched(recognizer: UIPinchGestureRecognizer)  {
        switch recognizer.state {
        case .changed:
            let scale =  recognizer.scale
            let deltaHeight = self.currentHeight * (scale - 1.0) / 2
            UIViewPropertyAnimator(duration: TimeInterval(Constants.slideAnimationDuration),
                                   dampingRatio: Constants.dampingRatio) {
                                    // Set the top/leading constraints based on the desired end position of the animation
                                    let newBottomConstraintVal = self.bottomConstraintVal + deltaHeight
                                    let newTopConstraintVal = self.topConstraintVal - deltaHeight
                                    
                                    // constrain bounding box to be within minimum hieght
                                    let newHeight = Constants.ImageBoxHeight - (-1 * newBottomConstraintVal + newTopConstraintVal)
                                    
                                    if newHeight < Constants.minimumHieght { return }
                                    
                                    // constrain bounding box to be within ImageBox
                                    self.bottomConstraint.constant = min(newBottomConstraintVal, 0)
                                    
                                    self.topConstraint.constant = max(newTopConstraintVal,  0)
                                    
                                    self.currentHeight = Constants.ImageBoxHeight - (-1 * self.bottomConstraint.constant + self.topConstraint.constant)
                                    self.ImageBox.layoutIfNeeded()
                                    
                                    self.info.position = self.topConstraint.constant / Constants.ImageBoxHeight
                                    
                                    self.info.height = self.currentHeight / Constants.ImageBoxHeight
                }.startAnimation()
        case .ended:
            break
        case .began:
            topConstraintVal = self.topConstraint.constant
            bottomConstraintVal = self.bottomConstraint.constant
            break
        default:
            break

        }
    }
}

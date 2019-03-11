//
//  DroneLaunchController.swift
//  StratoSnap
//
//  Created by Abdulhadi Mohamed on 2/24/19.
//  Copyright © 2019 Abhishek  Ravi. All rights reserved.
//

import Foundation
import UIKit


class DroneLaunchController: UIViewController {
    /// TODO: change to 30 seconds for final release
    var seconds = 2
    var timer = Timer()
    var info: FlightSettings?
    
    @IBOutlet weak var timerLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DroneLaunchController has loaded!")
        navigationItem.hidesBackButton = true
        if seconds < 10 {
            timerLabel.text = "0\(seconds)s"
        }
        else {
            timerLabel.text = "\(seconds)s"
        }
        runTimer()
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
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        if seconds < 10 {
            timerLabel.text = "0\(seconds)s"
        }
        else {
            timerLabel.text = "\(seconds)s"
        }
        if seconds == 0 {
            // TODO: send http request to drone control system to inform it about altitude hold
            timer.invalidate()
            if let navController = self.navigationController {
                let mainFlightController = MainFlightController()
                mainFlightController.info = info
                navController.pushViewController(mainFlightController,animated: true)
            }
            
        }
    }

    
    @IBAction func cancelDroneLaunch(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

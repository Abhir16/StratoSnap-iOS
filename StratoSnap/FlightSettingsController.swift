//
//  FlightSettingsController.swift
//  StratoSnap
//
//  Created by Abdulhadi Mohamed on 2/24/19.
//  Copyright © 2019 Abhishek  Ravi. All rights reserved.
//

import Foundation
import UIKit


class FlightSettingsController: UIViewController {
    @IBOutlet weak var AltitudeSlider: UISlider!
    @IBOutlet weak var AltitudeTextField: UITextView!
    let defaultAltitude:CGFloat = 50.0
    var info: FlightSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        print("HomeScreen has loaded!")
        print(info?.position)
        print(info?.height)
        info?.altitude = round(defaultAltitude)
        AltitudeTextField.text = "\(Int(round(defaultAltitude)))m"
        
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
        guard let droneLaunchController = segue.destination as? DroneLaunchController else {
            return
        }
        droneLaunchController.info = info
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        AltitudeTextField.text = "\(Int(round(AltitudeSlider.value)))m"
        self.info?.altitude = CGFloat(round(AltitudeSlider.value))
    }
    
    
}

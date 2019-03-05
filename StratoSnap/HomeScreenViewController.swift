//
//  HomeScreenViewController.swift
//  StratoSnap
//
//  Created by Abdulhadi Mohamed on 2/24/19.
//  Copyright © 2019 Abhishek  Ravi. All rights reserved.
//

import Foundation
import UIKit


class HomeScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeScreen has loaded!")

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
}

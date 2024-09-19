//
//  HomeVC.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import Foundation
import UIKit
import StoreKit

class StuHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRate(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
}

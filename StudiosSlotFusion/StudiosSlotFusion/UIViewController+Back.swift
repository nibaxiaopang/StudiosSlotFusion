//
//  UIViewController+Back.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import Foundation
import UIKit

extension UIViewController{
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

//
//  UIImage+Resize.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import Foundation
import UIKit

extension UIImage{
    
    func resize(toWidth width: CGFloat, height: CGFloat) -> UIImage? {
        
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let resizedImage = renderer.image { context in
            
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return resizedImage
    }
}

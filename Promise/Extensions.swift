//
//  Extensions.swift
//  Promise
//
//  Created by LeeDavid on 11/20/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit



// Gradient
extension UIView {
    func applyGradient(colors: [UIColor], direction: String) -> Void {
        self.applyGradient(colors: colors, locations: nil, direction: direction)
    }
    
    func applyGradient(colors: [UIColor], locations: [NSNumber]?, direction: String) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.name = "gradient"
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        
        if direction == "vertical" {
            gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        } else {
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradient() {
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if layer.name == "gradient" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
}


// Character Spacing
extension UILabel {
    func adjustTextSpacing(_ spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: text!)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: text!.characters.count))
        attributedText = attributedString
    }
}


extension UITextField {
    func adjustTextSpacing(_ spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: text!)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: text!.characters.count))
        attributedText = attributedString
    }
}








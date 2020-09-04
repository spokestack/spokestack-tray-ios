//
//  AnimatedGradientView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/22/20.
//

import Foundation
import UIKit

final class AnimatedGradientView: UIView {
    
    // MARK: Internal (properties)
    
    var gradientColors: Array<CGColor> = [] {
        
        didSet {
            self.gradient.colors = gradientColors
        }
    }
    
    // MARK: Private (properties)
    
    lazy private var gradient: CAGradientLayer = {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        let startLocations: Array<NSNumber> = [
            0.0,
            0.33,
            0.66,
            1.0
        ]

        gradient.locations = startLocations
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradient.colors = self.gradientColors
        
        return gradient
    }()
    
    lazy private var belowgradient: CAGradientLayer = {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradient.colors = self.gradientColors.reversed()
        
        return gradient
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.addSublayer(self.gradient)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.gradient.frame = self.bounds
    }
    
    // MARK: Internal (methods)
    
    func startAnimation() -> Void {
        self.alpha = 1.0
        self.performAnimation()
    }
    
    func stopAnimation() -> Void {
        self.gradient.removeAnimation(forKey: "loadingAnimation")
        self.alpha = 0.0
    }
    
    // MARK: Private (methods)
    
    private func performAnimation() -> Void {
        
        let animation = CABasicAnimation(keyPath: "colors")
        let reversedColors: Array<CGColor> = self.gradientColors.reversed()
        
        animation.fromValue = self.gradientColors
        animation.toValue = reversedColors
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity

        self.gradient.add(animation, forKey: "loadingAnimation")
    }
}

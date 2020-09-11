//
//  GrabberHandleView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/9/20.
//

import Foundation
import UIKit

class GrabberHandleView: UIView {

    // MARK: Internal (properties)
    
    var barColor = UIColor(displayP3Red: 0.76, green: 0.77, blue: 0.76, alpha: 1.0) {
    
        didSet {
            backgroundColor = barColor
        }
    }

    // MARK: Initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        
        super.init(frame: .zero)
        self.backgroundColor = barColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Overrides (methods)

    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.render()
    }

    // MARK: Private (methods)
    
    private func render() {
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.height * 0.5
    }
}


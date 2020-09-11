//
//  ContainerView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/20/20.
//

import Foundation
import UIKit

class ContainerView: UIView {

    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        
        super.init(frame: .zero)
        self.backgroundColor = .systemBlue
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Overrides (methods)

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return super.hitTest(point, with: event)
        }
        guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
            return nil
        }

        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return nil
    }
}

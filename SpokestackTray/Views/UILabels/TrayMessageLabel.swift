//
//  TrayMessageLabel.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

final class TrayMessageLabel: UILabel {
    
    // MARK: Internal (properties)
    
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    // MARK: Overrides (properties)
    
    override var intrinsicContentSize: CGSize {

        let size = super.intrinsicContentSize

        return CGSize(width: size.width + self.edgeInsets.left + self.edgeInsets.right,
                      height: size.height + self.edgeInsets.top + self.edgeInsets.bottom)
    }

//    override var bounds: CGRect {
//        didSet {
//            preferredMaxLayoutWidth = self.bounds.width - (self.edgeInsets.left + self.edgeInsets.right)
//        }
//    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: Overrides (methods)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.edgeInsets))
    }
    
    // MARK: Private (methods)
    
    private func setup() -> Void {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.preferredFont(forTextStyle: .callout)
        self.layer.cornerRadius = 7.0
        self.layer.masksToBounds = true
        self.textAlignment = .center
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textColor = .black
    }
}

//
//  MicrophoneView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/9/20.
//

import Foundation
import UIKit

final class MicrophoneImageView: UIImageView {

    // MARK: Initializers
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Overrides (methods)
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2.0
    }
    
    // MARK: Private (methods)
    
    private func setup() -> Void {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        self.backgroundColor = .blue
        self.layer.masksToBounds = false
    }
}

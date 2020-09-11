//
//  MicrophoneView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

final class MicrophoneView: UIView {
    
    // MARK: Internal (properties)
    
    var orientation: TrayConfiguration.TrayDirection = .left
    
    // MARK: Internal (properties)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
    
    // MARK: Private (properties)
    
    lazy private var microphoneImageView: UIImageView = {
       
        let imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .ultraLight))
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()

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
        
        self.addSubview(self.microphoneImageView)

        let imageWidth: CGFloat = 20.0
        let imageHeight: CGFloat = 20.0
        let imageOffset: CGFloat = self.orientation == .left ?  10.0 : -10.0
        
        self.microphoneImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.microphoneImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: imageOffset).isActive = true
        self.microphoneImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        self.microphoneImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = "#D83E68".spsk_color
        self.layer.masksToBounds = false
    }
}


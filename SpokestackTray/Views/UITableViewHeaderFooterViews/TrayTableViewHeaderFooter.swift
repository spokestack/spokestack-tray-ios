//
//  TrayTableViewHeaderFooter.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 9/3/20.
//

import Foundation
import UIKit

class TrayTableViewHeaderFooter: UIView {
    
    // MARK: Private (properties)
    
    lazy private var logoImageView: UIImageView = {

        let imageView: UIImageView = UIImageView(frame: .zero)
        let bundle: Bundle = Bundle(for: TrayTableViewHeaderFooter.self)

        imageView.image = UIImage(named: "powered.by.spokestack", in: bundle, with: nil) ?? UIImage(systemName: "arrow.left")!
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        
        return imageView
    }()

    // MARK: Initializer

    override init(frame: CGRect) {
     
        super.init(frame: frame)
        
        self.addSubview(self.logoImageView)
        self.backgroundColor = .white
        
        self.logoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.logoImageView.widthAnchor.constraint(equalToConstant: 177).isActive = true
        self.logoImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

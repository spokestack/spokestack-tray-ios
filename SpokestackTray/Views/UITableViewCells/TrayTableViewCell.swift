//
//  TrayTableViewCell.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

fileprivate let LeadingMargin: CGFloat = 40.0
fileprivate let TrailingMargin: CGFloat = 40.0

enum TrayTableViewCellMessageAlignment {
    case left
    case right
}

class TrayTableViewCell: TableViewCell {
    
    // MARK: Internal (properties)
    
    var message: TrayMessage? {
        
        didSet {
            
            if let newMessage: TrayMessage = message {
                
                self.messageLabel.text = newMessage.message
                
                if newMessage.alignment == .left {
                    
                    self.messageLabel.textAlignment = .left
                    self.messageLabel.backgroundColor = "#CCE4FF".spsk_color
                    
                    /// Disable the current user message constraints
                    
                    let disabledConstraints: Array<NSLayoutConstraint> = [
                        self.leftMessageConstraint,
                        self.rightMessageConstraint
                    ].compactMap({$0})
                    
                    /// Disable any current constraints
                    
                    NSLayoutConstraint.deactivate(disabledConstraints)
                    
                    let activeConstraints: Array<NSLayoutConstraint> = [
                        self.rightMessageConstraint,
                        self.leftMessageConstraint
                    ].compactMap({$0})
                    
                    NSLayoutConstraint.deactivate(activeConstraints)
                    
                    /// Message Label
                    
                    self.leftMessageConstraint = self.messageLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                                                            constant: TrailingMargin)

//                    self.rightMessageConstraint = self.messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -LeadingMargin)
                    

                    /// Activate Constraints
                    
                    NSLayoutConstraint.activate(
                        [
                            self.leftMessageConstraint,
//                            self.rightMessageConstraint
                        ]
                    )
                    
                } else {
                    
                    self.messageLabel.textAlignment = .right
                    self.messageLabel.backgroundColor = "#F6F9FC".spsk_color
                    
                    /// Disable the current user message constraints
                    
                    let disabledConstraints: Array<NSLayoutConstraint> = [
                        self.rightMessageConstraint,
                        self.leftMessageConstraint
                    ].compactMap({$0})
                    
                    /// Disable any current constraints
                    
                    NSLayoutConstraint.deactivate(disabledConstraints)
                    
                    let activeConstraints: Array<NSLayoutConstraint> = [
                        self.rightMessageConstraint,
                        self.leftMessageConstraint
                    ].compactMap({$0})
                    
                    NSLayoutConstraint.deactivate(activeConstraints)
                    
                    /// Message Label
                    
//                    self.leftMessageConstraint = self.messageLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
//                                                                                            constant: LeadingMargin)
                    
                    self.rightMessageConstraint = self.messageLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                                                              constant: -TrailingMargin)

                    /// Activate Constraints
                    
                    NSLayoutConstraint.activate(
                        [
//                            self.leftMessageConstraint,
                            self.rightMessageConstraint
                        ]
                    )
                }
            }
        }
    }
    
    // MARK: Private (properties)
    
    private var leftMessageConstraint: NSLayoutConstraint!
    
    private var rightMessageConstraint: NSLayoutConstraint!
    
    lazy private var messageLabel: TrayMessageLabel = {
       
        let label: TrayMessageLabel = TrayMessageLabel()
        label.preferredMaxLayoutWidth = self.contentView.bounds.width - 40.0
        return label
    }()
    
    // MARK: Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides (methods)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: Private (methods)
    
    private func setup() -> Void {
        
        self.contentView.addSubview(self.messageLabel)
        
        self.messageLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0).isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10.0).isActive = true
    }
}

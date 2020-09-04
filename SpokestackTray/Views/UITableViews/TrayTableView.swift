//
//  TrayTableView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

final class TrayTableView: TableView {
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableView.Style) {
        
        super.init(frame: frame, style: style)

        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 50.0
        self.separatorStyle = .none
        self.register(TrayTableViewCell.self, forCellReuseIdentifier: TrayTableViewCell.reuseIdentifier)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
}

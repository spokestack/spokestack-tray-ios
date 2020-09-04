//
//  TableView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

class TableView: UITableView {
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableView.Style) {
        
        super.init(frame: frame, style: style)

        self.cellLayoutMarginsFollowReadableWidth = false
        self.tableFooterView = UIView(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
}

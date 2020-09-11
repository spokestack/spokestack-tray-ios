//
//  ReuseableView.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

protocol ReuseableView: class { }

extension ReuseableView where Self: UIView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

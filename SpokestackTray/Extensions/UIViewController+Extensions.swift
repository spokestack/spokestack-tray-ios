//
//  UIViewController+Extensions.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/9/20.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Internal (properties)
    
    func spsk_addToParentController(_ viewController: UIViewController) -> Void {
        
        viewController.addChild(self)
        viewController.view.addSubview(self.view)
        self.didMove(toParent: viewController)
    }
    
    func spsk_removeFromParentController() -> Void {
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

//
//  IntentResult.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation

open class IntentResult {
    
    // MARK: Public (properties)
    
    open var node: String = ""
    
    open var prompt: String = ""
    
    open var data: AnyObject?
    
    // MARK: Initializers
    
    public init(node: String = "", prompt: String = "", data: AnyObject? = nil) {
        
        self.node = node
        self.prompt = prompt
        self.data = data
    }
}

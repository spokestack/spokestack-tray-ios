//
//  IntentResult.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation

open class IntentResult {
    
    // MARK: Open (properties)
    
    /// - Returns String
    open var node: String = ""
    
    /// - Returns String
    open var prompt: String = ""
    
    /// - Returns Optional AnyObject
    open var data: AnyObject?
    
    // MARK: Initializers
    
    /// Returns instance of `IntentResult`
    /// - Parameters:
    ///   - node: String
    ///   - prompt: String
    ///   - data: Optional AnyObject
    public init(node: String = "", prompt: String = "", data: AnyObject? = nil) {
        
        self.node = node
        self.prompt = prompt
        self.data = data
    }
}

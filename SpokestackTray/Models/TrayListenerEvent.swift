//
//  TrayListenerEvent.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation
import UIKit

/// TrayListenerType
/// - Returns String
public enum TrayListenerType: String {
    case none
    case activate
    case change
    case classification
    case deactive
    case error
    case initialize
    case recognize
    case start
    case stop
    case success
    case timeout
    case startedSpeaking
    case finishedSpeaking
}

public class TrayListenerEvent {
    
    // MARK: Public (properties)

    /// - Returns Optional String
    public var error: String?
    
    /// - Returns Optional String
    public var message: String?
    
    /// - Returns Optional AnyObject
    public var result: AnyObject?
    
    /// - Returns Optional CGFloat
    public var confidence: CGFloat?
    
    /// - Returns Optional String
    public var intent: String?
    
    /// - Returns Optional String
    public var transcript: String?
    
    /// - Returns Optional TrayListenerType
    public var type: TrayListenerType = .none
    
    /// - Returns Optional String
    public var url: String?
}

extension TrayListenerEvent: CustomStringConvertible {
    
    /// - Returns String
    public var description: String {
        return """
            Error \(String(describing: error))
            Message \(String(describing: message))
            Result \(String(describing: result))
            Confidence \(String(describing: confidence))
            Intent \(String(describing: intent))
            Transcript \(String(describing: transcript))
            Type \(type.rawValue)
            URL \(String(describing: url))
        """
    }
}

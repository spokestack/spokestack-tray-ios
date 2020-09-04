//
//  TrayListenerEvent.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation
import UIKit

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
    case startSpeaking
    case finishedSpeaking
}

public class TrayListenerEvent {
    
    // MARK: Public (properties)
    
    public var error: String?
    
    public var message: String?
    
    public var result: AnyObject?
    
    public var confidence: CGFloat?
    
    public var intent: String?
    
    public var transcript: String?
    
    public var type: TrayListenerType = .none
    
    public var url: String?
}

extension TrayListenerEvent: CustomStringConvertible {
    
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

//
//  LogController.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 9/3/20.
//

import Foundation
import OSLog

public class LogController {
    
    // MARK: Public (properties)
    
    public static let shared: LogController = LogController()
    
    // MARK: Private (properties)
    
    private lazy var logger: OSLog = {
        
        let bundleID: String = Bundle(for: LogController.self).bundleIdentifier ?? "spokestack-ios-tray"
        return OSLog(subsystem: bundleID, category: "Pipeline")
    }()

    // MARK: Initializers

    private init() {}
    
    // MARK: Internal (methods)
    
    public func log(_ message: String, level: OSLogType = .debug) -> Void {
        os_log("%@", log: self.logger, type: level, message)
    }
}

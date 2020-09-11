//
//  TrayMessage.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/27/20.
//

import Foundation

struct TrayMessage {
    
    /// Tray alignment
    /// - Returns TrayTableViewCellMessageAlignment
    let alignment: TrayTableViewCellMessageAlignment
    
    /// Message
    /// - Returns String
    let message: String
}

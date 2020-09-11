//
//  URL+Extensions.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/24/20.
//

import Foundation
import UIKit

extension URL {
    
    // MARK: Public (properties)
    
    public static var spsk_documentsDirectory: URL {
        
        let paths: Array<URL> = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static var spsk_tempDirectory: URL {
        return NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    }
}

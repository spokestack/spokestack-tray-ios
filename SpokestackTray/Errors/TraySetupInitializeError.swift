//
//  TrayInitializerSetupError.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/27/20.
//

import Foundation

enum TraySetupInitializeError: Error {
    
    case unknown
    case invalidModelDownloadStatus
    case deniedMicrophone
    case deniedSpeech
    case deniedBoth
}

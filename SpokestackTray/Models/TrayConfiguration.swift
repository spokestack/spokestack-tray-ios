//
//  TrayConfiguration.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/23/20.
//

import Foundation
import UIKit
import Spokestack

open class TrayConfiguration {
    
    // MARK: Public (properites)
    
    public enum TrayDirection {
        case left
        case right
    }
    
    /// Determines if the tray opens from the left or right
    /// Defaults to `.left`
    /// - Returns: TrayDirection
    open var orientation: TrayDirection = .left
    
    /// The width of the microphone button
    /// Defaults to `60.0`
    /// - Returns CGFloat
    open var buttonWidth: CGFloat = 60.0
    
    /// Indicates whether to speak the initial greeting
    /// Defaults to`true`
    /// - Returns Bool
    open var sayGreeting: Bool = true
    
    /// The default greeting
    /// Defaults to `Welcome to Spokestack`
    /// - Returns String
    open var greeting: String = "Welcome to Spokestack"
    
    /// Client ID for requests
    /// Defaults to `f0bc990c-e9db-4a0c-a2b1-6a6395a3d97e`
    /// - Returns String
    open var cliendId: String = "f0bc990c-e9db-4a0c-a2b1-6a6395a3d97e"
    
    /// Client Secret for requests to Spokestack APIs like TTS and ASR.
    /// Defaults to `5BD5483F573D691A15CFA493C1782F451D4BD666E39A9E7B2EBE287E6A72C6B6`
    /// - Returns String
    open var clientSecret: String = "5BD5483F573D691A15CFA493C1782F451D4BD666E39A9E7B2EBE287E6A72C6B6"

    /// The `TimeInterval` for delaying the close animation
    /// Defaults to `0.0`
    /// - Returns TimeInterval
    open var closeDelay: TimeInterval = 0.0

    /// Animation duration for opening / closing the tray
    /// Defaults to `0.45`
    /// - Returns TimeInterval
    open var duration: TimeInterval = 0.45
    
    /// Callback for handling successfuly NLU classifications
    /// Defaults to `nil`
    /// - Returns ((_ intent: String, _ slots: Dictionary<String, Slot>?, _ utterance: String?) -> IntentResult)
    open var handleIntent: ((_ intent: String, _ slots: Dictionary<String, Slot>?, _ utterance: String?) -> IntentResult)?
    
    /// Animation easing
    /// Defaults to `curveEaseInOut`
    /// - Returns UIView.AnimationOptions
    open var easing: UIView.AnimationOptions = .curveEaseInOut

    /// Callback that is used to edit any of the transcripts before it is classified by the `NLU`
    /// Defaults `nil`
    /// - Returns ((_ transcript: String) -> String)?
    open var editTranscript: ((_ transcript: String) -> String)?
    
    /// Array of nodes that will trigger the closing of the tray
    /// Defaults to `[]`
    /// - Returns Array<String>
    open var exitNodes: Array<String> = []
    
    /// Font used for table view cells
    /// Defaults to `UIFont.preferredFont(forTextStyle: .callout)`
    /// - Returns: UIFont
    open var fontFamily: UIFont = UIFont.preferredFont(forTextStyle: .callout)
    
    /// Defaults to `[.red, .white, .blue]`
    /// - Returns Array<UIColor>
    open var gradientColors: Array<UIColor> = [
        .red,
        .white,
        .blue
    ]
    
    /// Indicator on whether or not to the device's  haptic feedback feature
    /// Defaults  to `true`
    /// - Returns: Bool
    open var useHaptic: Bool = true
    
    /// Defaults to `0.75`
    /// - Returns CGFloat
    open var minHeightPercenter: CGFloat = 0.75

    /// Defaults to `0.30`
    /// - Returns CGFloat
    open var maxHeightPercentage: CGFloat = 0.30
    
    /// Defaults to `[:]`
    /// - SeeAlso `Constants.swift` for keys
    /// - Returns Dictionary<String, String>
    open var nluModelURLs: Dictionary<String, String> = [:]
    
    /// Defaults to `nil`
    /// - Returns (() -> Void)
    open var onClose: (() -> Void)?
    
    /// Defaults to `nil`
    /// - Returns ((_ event: TrayListenerEvent) -> Void)
    open var onEvent: ((_ event: TrayListenerEvent) -> Void)?

    /// Defaults to `nil`
    /// - Returns (() -> Void)
    open var onOpen: (() -> Void)?

    /// Defaults to `UIImage`
    /// - Returns UIImage?
    open var soundOffImage: UIImage? = UIImage(named: "icon.sound.off", in: Bundle(for: TrayConfiguration.self), with: nil)

    /// Defaults to `UIImage`
    /// - Returns UIImage?
    open var soundOnImage: UIImage? = UIImage(named: "icon.sound.on", in: Bundle(for: TrayConfiguration.self), with: nil)

    /// Defaults to `TTSInputFormat`
    /// - Returns TTSInputFormat
    open var ttsFormat: TTSInputFormat = .text

    /// Defaults to `demo-male`
    /// - Returns String
    open var voice: String = "demo-male"
    
    /// URLs to the wakeword models
    /// Defaults to `[:]`
    /// - SeeAlso `Constants.swift` for keys
    /// - Returns  Dictionary<String, String>
    open var wakewordModelURLs: Dictionary<String, String> = [:]
    
    /// The profile used for the speech pipeline
    /// Defaults to `.tfLiteWakewordAppleSpeech`
    /// - Returns: SpeechPipelineProfiles
    open var speechPipelineProfile: SpeechPipelineProfiles = .tfLiteWakewordAppleSpeech
    
    /// The trace logging level for the speech pipleline
    /// Defaults to `.PERF`
    /// - Returns: Trace.Level
    open var traceLevel: Trace.Level = .PERF
    
    // MARK: Initializers
    
    public init() {}
}

extension TrayConfiguration {
    
    /// Indicator of whether or not the wakeword models have successfully downloaded
    /// Saved to `UserDefaults`
    /// - Returns: Bool
    static var hasDownloadWakewordModels: Bool {
        
        set {
            
            let defaults: UserDefaults = UserDefaults.standard
            defaults.set(newValue, forKey: HasDownloadedWakeWordModelsKey)
        }
        get {
            
            let defaults: UserDefaults = UserDefaults.standard
            return defaults.bool(forKey: HasDownloadedWakeWordModelsKey)
        }
    }
    
    /// Indicator of whether or not the nlu models have successfully downloaded
    /// Saved to `UserDefaults`
    /// - Returns: Bool
    static var hasDownloadNLUModels: Bool {
        
        set {
            
            let defaults: UserDefaults = UserDefaults.standard
            defaults.set(newValue, forKey: HasDownloadedNLUModelsKey)
        }
        get {
            
            let defaults: UserDefaults = UserDefaults.standard
            return defaults.bool(forKey: HasDownloadedNLUModelsKey)
        }
    }
}

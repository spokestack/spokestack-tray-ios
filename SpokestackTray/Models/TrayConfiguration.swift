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

    open var buttonWidth: CGFloat = 60.0
    
    open var sayGreeting: Bool = true
    
    open var greeting: String = "Welcome to Spokestack"
    
    open var cliendId: String = ""

    open var clientSecret: String = ""

    open var closeDelay: TimeInterval = 0.0

    open var duration: TimeInterval = 0.45
    
    open var handleIntent: ((_ intent: String, _ slots: Dictionary<String, Slot>?, _ utterance: String?) -> IntentResult)?

    open var easing: UIView.AnimationOptions = .curveEaseInOut

    open var editTranscript: ((_ transscript: String) -> String)?

    open var exitNodes: Array<String> = []

    open var gradientColors: Array<UIColor> = [.red, .white, .blue]
    
    open var minHeightPercenter: CGFloat = 0.75
    
    open var maxHeightPercentage: CGFloat = 0.30
    
    open var nluModelURLs: Dictionary<String, String> = [:]
    
    open var onClose: (() -> Void)?

    open var onEvent: ((_ event: TrayListenerEvent) -> Void)?

    open var onOpen: (() -> Void)?

    open var soundOffImage: UIImage? = UIImage(named: "icon.sound.off", in: Bundle(for: TrayConfiguration.self), with: nil)

    open var soundOnImage: UIImage? = UIImage(named: "icon.sound.on", in: Bundle(for: TrayConfiguration.self), with: nil)

    open var ttsFormat: TTSInputFormat = .text

    open var voice: String = "demo-male"
    
    open var wakewordModelURLs: Dictionary<String, String> = [
        WakeWordModelDetectKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/detect.tflite",
        WakeWordModelEncodeKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/encode.tflite",
        WakeWordModelFilterKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/filter.tflite"
    ]
    
    // MARK: Initializers
    
    public init() {}
}

extension TrayConfiguration {
    
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

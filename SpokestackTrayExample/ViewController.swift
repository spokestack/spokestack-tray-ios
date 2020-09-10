//
//  ViewController.swift
//  SpokestackTrayExample
//
//  Created by Cory D. Wiles on 8/7/20.
//

import UIKit
import SpokestackTray
import Spokestack
import SwiftUI

enum IntentResultAmazonType: String {
    case `repeat` = "AMAZON.RepeatIntent"
    case yes = "AMAZON.YesIntent"
    case no = "AMAZON.NoIntent"
    case stop = "AMAZON.StopIntent"
    case cancel = "AMAZON.CancelIntent"
    case fallback = "AMAZON.FallbackIntent"
    case recipe = "RecipeIntent"
    case help = "AMAZON.HelpIntent"
}

extension String {
    
    var spstk_ns: NSString {
        return self as NSString
    }

    var spstk_color: UIColor {

        let hexString: NSString = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).spstk_ns
        
        if hexString.hasPrefix("#") {
            
            let hexColorStartIndex: String.Index = self.index(self.startIndex, offsetBy: 1)
            let hexColor: String = String(self[hexColorStartIndex...])
            
            if hexColor.count == 6 {
                 
                let scanner: Scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                let mask = 0x000000FF

                if scanner.scanHexInt64(&hexNumber) {

                    let r = Int(hexNumber >> 16) & mask
                    let g = Int(hexNumber >> 8) & mask
                    let b = Int(hexNumber) & mask
                    
                    let red   = CGFloat(r) / 255.0
                    let green = CGFloat(g) / 255.0
                    let blue  = CGFloat(b) / 255.0

                    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                 }
             }
        }
        
        return .black
    }
}

class ViewController: UIViewController {
    
    // MARK: Private (properties)
    
    lazy private var instructionsView: InstructionsView = {
        return InstructionsView()
    }()
    
    lazy private var hostingController: UIHostingController = {
        return UIHostingController(rootView: instructionsView)
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        /// Child view controller
        
        self.addHostingController()

        let configuration: TrayConfiguration = TrayConfiguration()
        
        /// When the tray is opened for the first time this is the synthesized
        /// greeting that will be "said" to the user
        
        configuration.greeting = """
        Welcome! This example uses models for Minecraft. Try saying, \"How do I make a castle?\"
        """
        
        /// When the tray is listening or processing speech there is a animated gradient that
        /// sits on top of the tray. The default values are red, white and blue
        
        configuration.gradientColors = [
            "#61fae9".spstk_color,
            "#2F5BEA".spstk_color,
            UIColor.systemRed
        ]
        
        /// Apart of the initialization of the tray is to download the nlu and wakeword models.
        /// These are the default Spokestack models, but you can replace with your own
        
        configuration.nluModelURLs = [
            NLUModelURLMetaDataKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/nlu.tflite",
            NLUModelURLNLUKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/vocab.txt",
            NLUModelURLVocabKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/metadata.json"
        ]
        configuration.wakewordModelURLs = [
            WakeWordModelDetectKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/detect.tflite",
            WakeWordModelEncodeKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/encode.tflite",
            WakeWordModelFilterKey: "https://d3dmqd7cy685il.cloudfront.net/model/wake/spokestack/filter.tflite"
        ]
        
        /// The handleIntent callback is how the SpeechController and the TrayViewModel know if
        /// NLUResult should be processed and what text should be added to the tableView.
        
        let greeting: IntentResult = IntentResult(node: IntentResultNode.greeting.rawValue, prompt: configuration.greeting)
        var lastNode: IntentResult = greeting

        configuration.handleIntent = {intent, slots, utterance in

            switch intent {
                case IntentResultAmazonType.repeat.rawValue:
                    return lastNode
                case IntentResultAmazonType.yes.rawValue:
                    lastNode = IntentResult(node: IntentResultNode.search.rawValue, prompt: "I heard you say yes! What would you like to make?")
                case IntentResultAmazonType.no.rawValue:
                    lastNode = IntentResult(node: IntentResultNode.exit.rawValue, prompt: "I heard you say no. Goodbye")
                case IntentResultAmazonType.stop.rawValue,
                     IntentResultAmazonType.cancel.rawValue,
                     IntentResultAmazonType.fallback.rawValue:
                    lastNode = IntentResult(node: IntentResultNode.exit.rawValue, prompt: "Goodbye!")
                case IntentResultAmazonType.recipe.rawValue:
                    
                    if let whatToMakeSlot: Dictionary<String, Slot> = slots,
                       let slot: Slot = whatToMakeSlot["Item"],
                       let item: String = slot.value as? String {
                    
                        lastNode = IntentResult(node: IntentResultNode.recipe.rawValue,
                                                prompt: """
                                                If I were a real app, I would show a screen now on how to make a \(item). Want to continue?
                                                """
                                    )
                    }
                    
                case IntentResultAmazonType.help.rawValue:
                    lastNode = greeting
                default:
                    lastNode = greeting
            }
            
            return lastNode
        }
        
        /// Which NLUNodes should trigger the tray to close automatically
        
        configuration.exitNodes = [
            IntentResultNode.exit.rawValue
        ]
        
        /// Callback when the tray is opened. The call back is called _after_ the animation has finished
        
        configuration.onOpen = {
            LogController.shared.log("isOpen")
        }
        
        /// Callback when the tray is closed. The call back is called _after_ the animation has finished
        
        configuration.onClose = {
            LogController.shared.log("onClose")
        }
        
        /// Callback when a `TrayListenerType` has occured
        
        configuration.onEvent = {event in
            LogController.shared.log("onEvent \(event)")
        }
        
        let tray: SpokestackTrayViewController = SpokestackTrayViewController(self, configuration: configuration)
        tray.addToParentView()
        tray.listen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.removeHostingController()
    }
    
    // MARK: Private (methods)
    
    private func addHostingController() -> Void {

        self.addChild(self.hostingController)
        self.hostingController.view.frame = self.view.frame
        self.view.addSubview(self.hostingController.view)
        self.hostingController.didMove(toParent: self)
    }
    
    private func removeHostingController() -> Void {
        
        self.hostingController.willMove(toParent: nil)
        self.hostingController.view.removeFromSuperview()
        self.hostingController.removeFromParent()
    }
}


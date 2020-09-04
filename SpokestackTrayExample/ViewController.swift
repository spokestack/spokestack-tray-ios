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
    
    lazy private var instructionsView: InstructionsView = {
        return InstructionsView()
    }()
    
    lazy private var hostingController: UIHostingController = {
        return UIHostingController(rootView: instructionsView)
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.removeHostingController()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        /// Child view controller
        
        self.addHostingController()

        let configuration: TrayConfiguration = TrayConfiguration()
        
        configuration.greeting = """
        Welcome! This example uses models for Minecraft. Try saying, \"How do I make a castle?\"
        """
        configuration.gradientColors = [
            "#61fae9".spstk_color,
            "#2F5BEA".spstk_color,
            UIColor.systemRed
        ]
        configuration.nluModelURLs = [
            NLUModelURLMetaDataKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/nlu.tflite",
            NLUModelURLNLUKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/vocab.txt",
            NLUModelURLVocabKey: "https://d3dmqd7cy685il.cloudfront.net/nlu/production/shared/XtASJqxkO6UwefOzia-he2gnIMcBnR2UCF-VyaIy-OI/metadata.json"
        ]
        
        configuration.cliendId = "f7e4a3c5-8468-44a9-917b-64169227caba"
        configuration.clientSecret = "A5ED55BA8E7BCF553A2DE6822E15AEBCB2A3245739097D135A80D83462072115"
        
        let greeting: IntentResult = IntentResult(node: InterntResultNode.greeting.rawValue, prompt: configuration.greeting)
        var lastNode: IntentResult = greeting

        configuration.handleIntent = {intent, slots, utterance in

            switch intent {
                case IntentResultAmazonType.repeat.rawValue:
                    return lastNode
                case IntentResultAmazonType.yes.rawValue:
                    lastNode = IntentResult(node: InterntResultNode.search.rawValue, prompt: "I heard you say yes! What would you like to make?")
                case IntentResultAmazonType.no.rawValue:
                    lastNode = IntentResult(node: InterntResultNode.exit.rawValue, prompt: "I heard you say no. Goodbye")
                case IntentResultAmazonType.stop.rawValue,
                     IntentResultAmazonType.cancel.rawValue,
                     IntentResultAmazonType.fallback.rawValue:
                    lastNode = IntentResult(node: InterntResultNode.exit.rawValue, prompt: "Goodbye!")
                case IntentResultAmazonType.recipe.rawValue:
                    
                    if let whatToMakeSlot: Dictionary<String, Slot> = slots,
                       let slot: Slot = whatToMakeSlot["Item"],
                       let item: String = slot.value as? String {
                    
                        lastNode = IntentResult(node: InterntResultNode.recipe.rawValue,
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
        
        configuration.exitNodes = [
            InterntResultNode.exit.rawValue
        ]
        
        configuration.onOpen = {
            LogController.shared.log("isOpen")
        }
        
        configuration.onClose = {
            LogController.shared.log("onClose")
        }
        
        configuration.onEvent = {event in
            LogController.shared.log("onEvent \(event)")
        }
        
        let tray: SpokestackTrayViewController = SpokestackTrayViewController(self, configuration: configuration)
        tray.addToParentView()
        tray.listen()
    }
    
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


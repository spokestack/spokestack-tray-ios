//
//  UIColor+Extensions.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

extension String {
    
    var spsk_ns: NSString {
        return self as NSString
    }
    
    var spsk_color: UIColor {
        
        let hexString: NSString = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).spsk_ns
        
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

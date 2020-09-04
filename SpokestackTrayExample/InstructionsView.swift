//
//  InstructionsView.swift
//  SpokestackTrayExample
//
//  Created by Cory D. Wiles on 9/1/20.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
    
        VStack(alignment: .leading, spacing: 10.0) {
            
            Text("Spokestack Example App (Minecraft)")
                .font(.headline)
            Text("Slide the tray open (➜)")
                .font(.subheadline)
                .bold()
            Text(
                """
                After you've given the tray microphone permission, say \"Spokestack\" to open the tray again.
                """
            )
            .font(.callout)
            Spacer()
        }
        .padding()
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}

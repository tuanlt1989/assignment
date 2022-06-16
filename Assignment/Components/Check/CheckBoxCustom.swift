//
//  CheckBoxCustom.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import SwiftUI

struct CheckBoxCustom: View {
    
    @Binding var checked: Bool? // Checkbox
    var id: String = "" // Id
    var label: String = "" // Label
    var callback: ((String, Bool) -> ())? // Callback
    var singleChoice: Bool = false // Single choice or multi choice
    
    var body: some View {
        Button(action: {
            if let callback = callback {
                callback(self.id, !self.checked!)
            }
        }) {
            HStack {
                Group {
                    checked! ? Image.icSquareChecked : Image.icSquareCheck
                }
                .foregroundColor(checked! ? Color.main : Color.mainText)
                if (!self.label.isEmpty) {
                    Text(self.label).modifier(TextModifierCustom(fontColor: checked! ? Color.main : Color.mainText))
                }
            }
        }
    }
}

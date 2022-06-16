//
//  TextModifierCustom.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI

struct TextModifierCustom: ViewModifier {
    var fontType: AppTypography.FontFamilyTheme? // Font type
    var fontSize: AppTypography.FontSizeTheme? // Font size
    var fontColor: Color? // Color
    
    func body(content: Content) -> some View {
        content
            .font(Font.Typography.apply(font: fontType ?? .main, size: fontSize ?? .medium))
            .foregroundColor(fontColor ?? .mainText)
    }
}

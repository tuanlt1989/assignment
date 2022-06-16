//
//  AppTheme.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI
///
// MARK: Base color palette materials
///
/// 1. Level 2 base
struct BaseColor {
    /// dynamic color sets (with dark and light mode)
    let contrastPrimary = Color("contrastPrimary")
    let contrastSecondary = Color("contrastSecondary")
    let themePrimary = Color("themePrimary")
    let themeSecondary = Color("themeSecondary")
    let brandPrimary = Color("brandPrimary")
    
    /// staic color sets (not updating along with color mode)
    let darkPrimary = Color("darkPrimary")
    let lightPrimary = Color("lightPrimary")
    let gray = Color("gray")
}

/// 2. Level 3 tokens
struct AppColor {
    let baseColor = BaseColor()
    
    let highlight: Color!
    let inactive: Color!
    
    let textDefault: Color!
    let textTheme: Color!
    let textNote: Color!
    let textHighlight: Color!
    let textLight: Color!
    
    let buttonTheme: Color!
    let buttonContrast: Color!
    let buttonHighlight: Color!
    
    let backgroundDefault: Color!
    let backgroundTheme: Color!
    
    init() {
        /// themePrimary
        self.textTheme = baseColor.themePrimary
        self.buttonTheme = baseColor.themePrimary
        self.backgroundTheme = baseColor.themePrimary
        
        /// themeSecondary
        self.textNote = baseColor.themeSecondary
        
        /// contrastPrimary
        self.buttonContrast = baseColor.contrastPrimary
        self.textDefault = baseColor.contrastPrimary
        self.backgroundDefault = baseColor.contrastPrimary
        
        /// brand
        self.highlight = baseColor.brandPrimary
        self.buttonHighlight = baseColor.brandPrimary
        self.textHighlight = baseColor.brandPrimary
        
        /// lightPrimary
        self.textLight = baseColor.lightPrimary
        
        /// gray
        self.inactive = baseColor.gray
    }
}

///
// MARK: Add palatte to Color struct
///
///
/// Base colors are not exposed at same layer as Color.Token but inside of which,
/// because we encourage using Token colors instead of Base colors in most cases.
///
extension Color {
    static let MainTheme = AppColor()
}

///
// MARK: Base typography materials
///
struct AppTypography {

    ///
    // 1. Prepare base materials
    ///
    
    /// a. Level 1 base settings
    private enum FontSize: CGFloat {
        case
        small = 12.5,
        medium = 15,
        xmedium = 16,
        large = 18,
        xlarge = 24,
        big = 36
    }
    private enum FontFamily: String {
        case
        HelveticaNeue = "HelveticaNeue",
        Georgia = "Georgia",
        RobotoRegular = "Roboto-Regular",
        RobotoBold = "Roboto-Bold",
        RobotoItalic = "Roboto-Italic"
    }
    
    /// b. Level 2 tokens
    enum FontSizeTheme: CGFloat {
        case
        small,
        medium,
        xmedium,
        large,
        xlarge,
        big
        
        func getValue() -> CGFloat {
            switch self {
            case .small:
                return FontSize.small.rawValue
            case .medium:
                return FontSize.medium.rawValue
            case .xmedium:
                return FontSize.xmedium.rawValue
            case .large:
                 return FontSize.large.rawValue
            case .xlarge:
                return FontSize.xlarge.rawValue
            case .big:
                  return FontSize.big.rawValue
            }
        }
    }
    enum FontFamilyTheme: String {
        case
        main,
        base,
        bold,
        italic
        
        func getValue() -> String {
            switch self {
            case .main:
                return FontFamily.RobotoRegular.rawValue
            case .bold:
                return FontFamily.RobotoBold.rawValue
            case .italic:
                 return FontFamily.RobotoItalic.rawValue
            case .base:
                 return FontFamily.HelveticaNeue.rawValue
            }
        }
    }

    ///
    // 2. Expose data
    ///
    let mainFont: Font!
    let baseFont: Font!
    let boldFont: Font!
    let italicFont: Font!
    
    let main: String!
    let base: String!
    let bold: String!
    let italic: String!
    
    let mainS: CGFloat!
    let baseS: CGFloat!
    let largeS: CGFloat!
    
    init() {
        self.mainFont = Font.custom(FontFamilyTheme.main.getValue(), size: FontSizeTheme.medium.getValue())
        self.baseFont = Font.custom(FontFamilyTheme.base.getValue(), size: FontSizeTheme.medium.getValue())
        self.boldFont = Font.custom(FontFamilyTheme.bold.getValue(), size: FontSizeTheme.medium.getValue())
        self.italicFont = Font.custom(FontFamilyTheme.italic.getValue(), size: FontSizeTheme.medium.getValue())
        self.main = FontFamilyTheme.main.getValue();
        self.base = FontFamilyTheme.base.getValue();
        self.bold = FontFamilyTheme.bold.getValue();
        self.italic = FontFamilyTheme.italic.getValue();
        self.mainS = FontSizeTheme.medium.getValue();
        self.baseS = FontSizeTheme.xmedium.getValue();
        self.largeS = FontSizeTheme.xlarge.getValue();
    }
}

/// Helper functions
extension AppTypography {
    public func apply(font: FontFamilyTheme, size: FontSizeTheme) -> Font {
        return Font.custom(font.getValue(), size: size.getValue())
    }
}

///
// MARK: Expose Typography to Font struct
///
/// ------
/// To set environment Font, please chain setting
/// `.environment(\.font, Font.Typography.mainFont)`
/// to entry View of the app.
/// ------
///
extension Font {
    static let Typography = AppTypography()
}

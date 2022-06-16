//
//  EmptyViewCustom.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI
import i18nSwift

struct EmptyViewCustom : View {
    var content = i18n.t(.noData) // Content default
    
    var body: some View {
        VStack(alignment: .center){
            Text(content).modifier(TextModifierCustom(fontColor: .mainTextLight))
        }
    }
}

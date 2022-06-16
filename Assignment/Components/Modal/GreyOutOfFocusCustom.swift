//
//  GreyOutOfFocusCustom.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation

import SwiftUI

public struct GreyOutOfFocusCustom: View {
    let opacity: CGFloat
    let callback: (() -> ())?
    
    public init(
        opacity: CGFloat = 0.1,
        callback: (() -> ())? = nil
    ) {
        self.opacity = opacity
        self.callback = callback
    }
    
    var greyView: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .opacity(Double(opacity))
            .onTapGesture {
                callback?()
            }
            .edgesIgnoringSafeArea(.all)
    }
    
    public var body: some View {
        greyView
    }
}

struct GreyOutOfFocusCustom_Previews: PreviewProvider {
    static var previews: some View {
        GreyOutOfFocusCustom()
    }
}

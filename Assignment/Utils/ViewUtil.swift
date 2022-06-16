//
//  ViewUtil.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import SwiftUI

struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false // Did load
    private let action: (() -> Void)? // Action call

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

struct LoadingCustom: ViewModifier {
    var isLoading: Bool = false // Variable show loading
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if(isLoading) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .main))
                    .position(x: UIScreen.main.bounds.width / 2, y:  UIScreen.main.bounds.height / 2 - 50)
            }
        }
    }
}

extension View {
    
    /// On load
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
    /// Show loading
    func showLoading(isLoading: Bool) -> some View {
        modifier(LoadingCustom(isLoading: isLoading))
    }
}

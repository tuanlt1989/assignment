//
//  ModalView.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import SwiftUI
import Combine

public struct ModalCustom : View {
    // Content of Modal
    private var content: ContentModalView
    @State var offset = UIScreen.main.bounds.height
    @Binding var isShowing: Bool // Showing or not
    @State var isDragging = false
    let callback: (() -> ())? // Call when hide
    let heightToDisappear = UIScreen.main.bounds.height
    let backgroundColor: Color // Background color
    let outOfFocusOpacity: CGFloat
    let minimumDragDistanceToHide: CGFloat
    var isCenter: Bool = false // Is center app or not
    @State private var bottomPadding: CGFloat = 0
    
    func hide() {
        offset = heightToDisappear
        isDragging = false
        isShowing = false
        if let callback = callback {
            callback()
        }
    }
    
    func dragGestureOnChange(_ value: DragGesture.Value) {
        isDragging = true
        if value.translation.height > 0 {
            offset = value.location.y
            let diff = abs(value.location.y - value.startLocation.y)
            
            let conditionOne = diff > minimumDragDistanceToHide
            let conditionTwo = value.location.y >= 200
            
            
            if conditionOne || conditionTwo {
                hide()
            }
        }
    }
    
    var interactiveGesture: some Gesture {
        DragGesture()
            .onChanged({ (value) in
                dragGestureOnChange(value)
            })
            .onEnded({ (value) in
                isDragging = false
            })
    }
    
    var outOfFocusArea: some View {
        Group {
            if isShowing {
                GreyOutOfFocusCustom(opacity: outOfFocusOpacity) {
                    self.hide()
                }
            }
        }
    }
    
    var modalView: some View {
        VStack {
            if (!isCenter) {
                Spacer()
            }
            content
            .background(backgroundColor)
            .cornerRadius(.cornerRadius12)
            .offset(y: offset)
        }
        
    }
    
    var bodyContent: some View {
        ZStack() {
            outOfFocusArea
            modalView
        }
    }
    
    func onUpdateIsShowing(_ isShowing: Bool) {
        if isShowing && isDragging {
            return
        }
        
        DispatchQueue.main.async {
            offset = isShowing ? 0 : heightToDisappear
        }
    }
    
    public var body: some View {
        Group {
            if isShowing {
                bodyContent
            }
        }
        .onReceive(Just(isShowing), perform: { isShowing in
            onUpdateIsShowing(isShowing)
        })
    }
}

extension ModalCustom {
    
    public init(
        isShowing: Binding<Bool>,
        backgroundColor: Color = Color.white,
        outOfFocusOpacity: CGFloat = 0.5,
        minimumDragDistanceToHide: CGFloat = 150,
        isCenter: Bool = false,
        callback: (() -> ())? = nil
    ) {
        _isShowing = isShowing
        self.backgroundColor = backgroundColor
        self.outOfFocusOpacity = outOfFocusOpacity
        self.minimumDragDistanceToHide = minimumDragDistanceToHide
        self.content = ContentModalView()
        self.callback = callback
        self.isCenter = isCenter
    }
    
    public func modalContent<Content: View>(@ViewBuilder contentModal: () -> Content) -> some View {
        let v = contentModal()
        var result = self
        result.content.content = AnyView(v)
        return result
    }
}

struct ContentModalView: View {
    
    var content: AnyView?
    
    var body: some View {
        if content != nil {
            content
        } else {
            Color.clear
        }
    }
}

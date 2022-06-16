//
//  AddTaskModal.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import SwiftUI
import i18nSwift

struct AddTaskModal: View {
    
    @State var value: String = "" // Value
    @State var warningContent: String = "" // Warn content
    @EnvironmentObject var global: GlobalModel // Global info
    
    /// Title
    var title: some View {
        Text(warningContent).modifier(TextModifierCustom(fontType: .bold, fontSize: .small, fontColor: .red))
    }
    
    var buttonCancelAndAgree: some View {
        HStack(spacing: .padding16) {
            Button(action: {
                global.isAddTask.toggle()
            }) {
                Text(i18n.t(.cancel)).modifier(TextModifierCustom())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .padding12)
            .background(Color.white)
            .cornerRadius(.cornerRadius)
            Button(action: {
                if(value.isEmpty) {
                    warningContent = i18n.t(.warningContent)
                } else {
                    warningContent = ""
                    global.isAddTask.toggle()
                    NotificationCenter.default.post(name: Notification.Name(NotificationType.addTask), object: nil, userInfo: ["Content": value, "UUID": UUID()])
                }
            }) {
                Text(i18n.t(.create)).modifier(TextModifierCustom(fontColor: .white))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .padding12)
            .background(Color.main)
            .cornerRadius(.cornerRadius)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Content
    var content: some View {
        VStack(alignment: .leading) {
            if(!warningContent.isEmpty) {
                title
            }
            TextField(i18n.t(.writeNewTask), text: $value)
                .modifier(TextModifierCustom(fontColor: .mainText))
                .multilineTextAlignment(.leading)
                .autocapitalization(.none)
        }
        .padding(.padding16)
        .background(Color.white)
        .cornerRadius(.cornerRadius12)
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            Text(i18n.t(.createTask)).modifier(TextModifierCustom(fontType: .bold, fontSize: .large))
            content
            buttonCancelAndAgree
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.top, .horizontal], .padding16)
        .background(Color.background)
        .padding(.bottom, .paddingBottomModal)
    }
}

//
//  TabBarView.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI
import i18nSwift

struct TabBarView: View {
    @State private var selectedTab = TabPosition.tab1 // Tab choose
    @EnvironmentObject var global: GlobalModel // Global info
    
    /// Render tab item
    func renderTabItem(position: TabPosition, title: String, iconSelected: Image, iconUnSelected: Image, proxy: ScrollViewProxy) -> some View {
        Button(action: {
            if (self.selectedTab == position) {
                withAnimation {
                    proxy.scrollTo(position)
                }
            }
            self.selectedTab = position
        } ) {
            VStack() {
                selectedTab == position ? iconSelected.foregroundColor(.main): iconUnSelected.foregroundColor(.mainTextLight)
                Text(title).modifier(TextModifierCustom(fontType: selectedTab == position ? .bold : .main, fontSize: .small, fontColor: selectedTab == position ? .main : .mainTextLight)).lineLimit(1)
            }
        }
    }
    
    var body: some View {
        ZStack{
            NavigationView {
                ScrollViewReader { proxy in
                    ZStack(alignment: Alignment.bottom) {
                        TabView(selection: $selectedTab) {
                            TaskListView(taskType: .all)
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                                .tag(TabPosition.tab1)
                            TaskListView(taskType: .complete)
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                                .tag(TabPosition.tab2)
                            TaskListView(taskType: .incomplete)
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                                .tag(TabPosition.tab3)
                        }
                        HStack(alignment: .center) {
                            renderTabItem(position: TabPosition.tab1, title: i18n.t(.all), iconSelected: Image.icAll, iconUnSelected: Image.icAll, proxy: proxy)
                                .frame(maxWidth: .infinity)
                            renderTabItem(position: TabPosition.tab2, title: i18n.t(.complete), iconSelected: Image.icComplete, iconUnSelected: Image.icComplete, proxy: proxy)
                                .frame(maxWidth: .infinity)
                            renderTabItem(position: TabPosition.tab3, title: i18n.t(.incomplete), iconSelected: Image.icIncomplete, iconUnSelected: Image.icIncomplete, proxy: proxy)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, .padding16)
                        .background(Color.white)
                    }
                    .ignoresSafeArea(.keyboard)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .overlay(
                ModalCustom(isShowing: $global.isAddTask).modalContent(contentModal: {
                    AddTaskModal()
                })
            )
        }
    }
}

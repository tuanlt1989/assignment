//
//  TaskListView.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI
import i18nSwift

struct TaskListView: View {
    
    @StateObject var viewModel = TaskListViewModel() // Task list view model
    var taskType: TaskType = .all // Tag type
    @EnvironmentObject var global: GlobalModel // Global info
    
    /// Content
    var content: some View {
        CustomList(data: $viewModel.tasks,
                   isShowNoData: $viewModel.isShowNoData,
                   onRefresh: viewModel.onRefresh(refreshComplete:),
                   header: {
            HStack {
                Text(viewModel.getTitleName())
                    .modifier(TextModifierCustom(fontType: .bold, fontSize: .large))
                Spacer()
                Button(action: {
                    global.isAddTask = true
                }) {
                    Image.icAdd.foregroundColor(Color.main)
                }
            }
            .padding(.padding16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }) {
            item in
            HStack {
                CheckBoxCustom(checked: .constant(item.isComplete ?? false), label: item.content ?? "", callback: {id, isChoose in
                    viewModel.saveTask(item, isChoose: isChoose)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.padding12)
                .background(Color.white)
                .cornerRadius(.cornerRadius12)
                .overlay(RoundedRectangle(cornerRadius: .cornerRadius12).stroke(Color.white, lineWidth: 1))
                .shadow(color: Color.white, radius: .cornerRadius)
            }
            .padding(.horizontal, .padding16)
        }
    }
    
    var body: some View {
        content
            .onLoad(perform: {
                viewModel.taskType = taskType
                viewModel.getTasks()
            })
            .background(Color.background)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: NotificationType.addTask))) { notification in
                guard let value = notification.userInfo?["Content"] as? String else { return }
                guard let uuid = notification.userInfo?["UUID"] as? UUID else { return }
                viewModel.addTask(TaskModel(id: uuid, content: value, isComplete: false, date: Date()))
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: NotificationType.updateTask))) { notification in
                // Temp get all task from begin
                viewModel.getTasks()
                NotificationCenter.default.removeObserver(self)
            }
            .showLoading(isLoading: viewModel.isLoading)
            .showMessage(isPresenting: $viewModel.isShowMessage){
                AlertToastCustom(title: i18n.t(.notification), subTitle: viewModel.message)
            }
            .blur(radius: global.isAddTask ? .cornerRadius : 0)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskListView(taskType: .all).environmentObject(GlobalModel())
            TaskListView(taskType: .complete).environmentObject(GlobalModel())
        }
    }
}


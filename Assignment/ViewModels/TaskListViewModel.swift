//
//  TaskListViewModel.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import CoreData

class TaskListViewModel: BaseViewModel {
    
    @Published var tasks: [TaskModel] = [] // List task
    @Published var taskType: TaskType = .all // Task type
    let container: NSPersistentContainer // Container
    
    override init() {
        container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get task
    func getTasks() {
        var predicate: NSPredicate? = nil
        self.isLoading = true
        self.tasks = []
        if(taskType == .incomplete) {
            predicate = NSPredicate(format: "is_complete = false")
        } else if(taskType == .complete) {
            predicate = NSPredicate(format: "is_complete = true")
        }
        let request : NSFetchRequest<Tasks> = Tasks.fetchRequest()
        if(predicate != nil) {
            request.predicate = predicate
        }
        let sort = NSSortDescriptor(key: #keyPath(Tasks.date), ascending: false)
        request.sortDescriptors = [sort]
        do {
            let entriesCoreData = try container.viewContext.fetch(request)
            tasks = entriesCoreData.map {
                TaskModel(id: $0.id, content: $0.content, isComplete: $0.is_complete, date: $0.date)
            }
            self.isLoading = false
            self.refreshComplete?()
        } catch {
            self.isShowMessage = true
            self.message = "Fetch failed: Error \(error.localizedDescription)"
            tasks = []
        }
        self.isShowNoData = tasks.count == 0
    }
    
    /// Find task
    func findTask(_ task: TaskModel) -> Tasks? {
        let request : NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let predicate = NSPredicate(format: "id = %@", task.id!.uuidString)
        request.predicate = predicate
        do {
            let taskEntity = try container.viewContext.fetch(request).first
            return taskEntity
        } catch let error {
            self.isShowMessage = true
            self.message = "Error: \(error.localizedDescription)"
        }
        return nil
    }
    
    /// Add task
    func addTask(_ task: TaskModel) {
        let taskExisted = findTask(task)
        if (taskExisted != nil) {
            return
        }
        let taskEntity = Tasks(context: container.viewContext)
        do {
            taskEntity.id = task.id
            taskEntity.content = task.content
            taskEntity.date = task.date
            taskEntity.is_complete = false
            try container.viewContext.save()
            NotificationCenter.default.post(name: Notification.Name(NotificationType.updateTask), object: nil, userInfo: nil)
        } catch let error {
            self.isShowMessage = true
            self.message = "Error: \(error)"
        }
    }
    
    /// Save task
    func saveTask(_ task: TaskModel, isChoose: Bool) {
        let request : NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let predicate = NSPredicate(format: "id = %@", task.id!.uuidString)
        request.predicate = predicate
        do {
            let taskEntity = try container.viewContext.fetch(request).first
            // Update task data
            if let i = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[i].isComplete = isChoose
            }
            taskEntity?.is_complete = isChoose
            try container.viewContext.save()
            NotificationCenter.default.post(name: Notification.Name(NotificationType.updateTask), object: nil, userInfo: nil)
        } catch let error {
            self.isShowMessage = true
            self.message = "Error: \(error.localizedDescription)"
        }
    }
    
    /// Load more
    func loadMore() {
        self.getTasks()
    }
    
    /// Onrefresh
    func onRefresh(refreshComplete: @escaping RefreshComplete) {
        self.refreshComplete = refreshComplete
        self.isRefresh = true
        self.getTasks()
    }
    
    /// Get title task name
    func getTitleName() -> String {
        switch(taskType) {
        case .all:
            return "All Task"
        case .complete:
            return "Complete task"
        default:
            return "Incomplete Task"
        }
    }
}

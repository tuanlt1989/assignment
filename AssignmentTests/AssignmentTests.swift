//
//  AssignmentTests.swift
//  AssignmentTests
//
//  Created by Tuan on 14/06/2022.
//

import XCTest
@testable import Assignment

class AssignmentTests: XCTestCase {

    /// Tesst add task
    func testAddTask() {
        let viewModel = TaskListViewModel()
        let task = TaskModel(id: UUID(), content: "Test add task", isComplete: false, date: Date())
        viewModel.addTask(task)
        let entity = viewModel.findTask(task)
        XCTAssertNotNil(entity)
    }
    
    /// Test get task
    func testGetTask() {
        let viewModel = TaskListViewModel()
        let task = TaskModel(id: UUID(), content: "Test get task", isComplete: false, date: Date())
        viewModel.addTask(task)
        viewModel.getTasks()
        XCTAssertNotEqual(viewModel.tasks.count, 0)
    }

}

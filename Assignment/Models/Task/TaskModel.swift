//
//  TaskModel.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation

struct TaskModel: Hashable {
    var id: UUID? // id
    var content: String? // Content
    var isComplete: Bool? // Is complete
    var date: Date? // Date
}

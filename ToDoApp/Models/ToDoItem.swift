//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Laura Evans on 1/21/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation

struct TodoItem: Codable {
    var title: String
    var completed: Bool
    var createdAt: Date
    var itemIdentifier: UUID
    
    func saveItem() {
        DataManager.save(self, with: itemIdentifier.uuidString)
    }
    
    func deleteItem() {
        DataManager.delete(itemIdentifier.uuidString)
    }
    
    mutating func markAsCompleted() {
        self.completed = true
        self.saveItem()
    }
    
}

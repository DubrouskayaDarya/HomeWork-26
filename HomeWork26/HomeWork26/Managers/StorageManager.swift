//
//  StorageManager.swift
//  HomeWork26
//
//  Created by Дарья Дубровская on 13.03.22.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {

    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error")
        }
    }

    static func saveTasksList(tasksList: TasksList) {
        try! realm.write({
            realm.add(tasksList)
        })
    }

    static func deleteList(_ tasksList: TasksList) {
        try! realm.write {
            let tasks = tasksList.tasks

            realm.delete(tasks)
            realm.delete(tasksList)
        }
    }

    static func editList(_ tasksList: TasksList,
                         newListName: String,
                         complition: @escaping () -> Void) {
        do {
            try realm.write {
                tasksList.name = newListName
                complition()
            }
        } catch {
            print("editList error")
        }
    }

    static func makeAllDone (_ tasksList: TasksList,
                             complition: @escaping () -> Void) {
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplete")
            complition()
        }
    }
    
    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }
    
    static func editTask(task: Task, newNameTask: String, newNote: String) {
        try! realm.write {
            task.name = newNameTask
            task.note = newNote
        }
    }
    
    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    static func makeDone(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
}

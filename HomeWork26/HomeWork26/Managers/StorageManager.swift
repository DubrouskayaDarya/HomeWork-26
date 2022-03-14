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
    
}

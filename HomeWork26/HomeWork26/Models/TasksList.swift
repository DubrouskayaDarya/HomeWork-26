//
//  TasksList.swift
//  HomeWork26
//
//  Created by Дарья Дубровская on 13.03.22.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}

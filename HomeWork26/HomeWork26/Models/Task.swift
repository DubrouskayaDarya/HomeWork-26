//
//  Task.swift
//  HomeWork26
//
//  Created by Дарья Дубровская on 13.03.22.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}

//
//  Task.swift
//  taskapp
//
//  Created by masao on 2019/05/12.
//  Copyright © 2019 TiraTom. All rights reserved.
//

import Foundation
import RealmSwift


class Task: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var date = Date()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

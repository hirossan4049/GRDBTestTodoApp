//
//  ViewController.swift
//  GRDBTest
//
//  Created by craptone on 2021/10/15.
//

import UIKit
import GRDB


struct Todo: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var title: String
    var createAt: Date
    var updateAt: Date
}

class ViewController: UIViewController {
    private lazy var dbQueue: DatabaseQueue = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return try! DatabaseQueue(path: dir.absoluteString + "database.sqlite")
    }()
    
    private var todos: [Todo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupDb()
        
        todos = fetch()


        
        print(fetch())
    }
    
    func setupDb() {
        //FIXME: これでいいのか？
        try? dbQueue.write { db in
            try db.create(table: "todo") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("createAt", .date).notNull()
                t.column("updateAt", .date).notNull()
            }
        }
    }
    
    func add() {
        try! dbQueue.write { db in
            try Todo(id: nil, title: "sakura", createAt: Date(), updateAt: Date()).insert(db)
        }
    }
    
    func fetch() -> [Todo] {
        return try! dbQueue.read { db in
            try Todo.fetchAll(db)
        }
    }


}


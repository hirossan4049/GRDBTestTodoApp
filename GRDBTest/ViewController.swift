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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private lazy var dbQueue: DatabaseQueue = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return try! DatabaseQueue(path: dir.absoluteString + "database.sqlite")
    }()
    
    private var todos: [Todo] = []
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupDb()
        
        todos = fetch().reversed()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    @IBAction func addTapped() {
        add(todo: Todo(id: nil, title: textField.text!, createAt: Date(), updateAt: Date()))
        todos = fetch().reversed()
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        
        textField.text = ""
        textField.resignFirstResponder()
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
    
    func add(todo: Todo) {
        try! dbQueue.write { db in
            try todo.insert(db)
        }
    }
    
    func fetch() -> [Todo] {
        return try! dbQueue.read { db in
            try Todo.fetchAll(db)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = todos[indexPath.row].title
        return cell
    }
    


}


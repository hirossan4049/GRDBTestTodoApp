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
        
        todos = fetch()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    @IBAction func addTapped() {
        add(todo: Todo(id: nil, title: textField.text!, createAt: Date(), updateAt: Date()))
        todos = fetch()
        
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
        }.reversed()
    }
    
    func deleteTodo(todo: Todo) {
        try! dbQueue.write { db in
            try todo.delete(db)
        }
    }
    
    func updateTodo(todo: Todo) {
        try! dbQueue.write { db in
            try todo.update(db)
        }
    }
    
    func editAlert(indexPath: IndexPath) {
        var todo = todos[indexPath.row]
        let ac = UIAlertController(title: "Edit \(todo.title)", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?.first?.text = todo.title

        let submitAction = UIAlertAction(title: "Update", style: .default) { [unowned ac] _ in
            todo.title = ac.textFields?.first!.text! ?? ""
            
            self.updateTodo(todo: todo)
            
            self.todos = self.fetch()
            self.tableView.reloadRows(at: [indexPath], with: .top)
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = todos[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.editAlert(indexPath: indexPath)
            completionHandler(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteTodo(todo: self.todos[indexPath.row])
            self.todos = self.fetch()
            self.tableView.deleteRows(at: [indexPath], with: .top)

            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    


}


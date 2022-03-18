//
//  TasksTableViewController.swift
//  HomeWork26
//
//  Created by Дарья Дубровская on 13.03.22.
//

import UIKit
import RealmSwift

class TasksTableViewController: UITableViewController {

    var currentTasksList: TasksList!

    private var notCompletedTasks: Results<Task>!
    private var competedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = currentTasksList.name
        filteringTasks()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtomSystemItemSelector))
        navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : competedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Not Complete Tasks" : "Completed Tasks"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : competedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : competedTasks[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(task)
        }
        let doneText = task.isComplete ? "notDone" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }

        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])

        return swipeActions
    }

    private func filteringTasks() {
        notCompletedTasks = currentTasksList.tasks.filter("isComplete = false")
        competedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}

extension TasksTableViewController {

    @objc private func addBarButtomSystemItemSelector() {
        alertForAddAndUpdateList()
    }

    private func alertForAddAndUpdateList(_ taskName: Task? = nil) {

        let title = "Task Value"
        let message = (taskName == nil) ? "Please insert new task value" : "Please edit your task"
        let doneButtonName = (taskName == nil) ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var taskTextField: UITextField!
        var noteTextField: UITextField!


        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty else { return }

            if let taskName = taskName {
                if let newNote = noteTextField.text, !newNote.isEmpty {
                    StorageManager.editTask(task: taskName, newNameTask: newNameTask, newNote: newNote)
                } else {
                    StorageManager.editTask(task: taskName, newNameTask: newNameTask, newNote: "")
                }
                self.filteringTasks()
            } else {
                let task = Task()
                task.name = newNameTask
                if let note = noteTextField.text, !note.isEmpty {
                    task.note = note
                }
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "New task"

            if let taskName = taskName {
                taskTextField.text = taskName.name
            }
        }

        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = "Note"

            if let taskName = taskName {
                noteTextField.text = taskName.note
            }
        }
        present(alert, animated: true)
    }
}

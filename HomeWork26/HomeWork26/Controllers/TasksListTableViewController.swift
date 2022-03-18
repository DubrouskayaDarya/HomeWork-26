//
//  TasksListTableViewController.swift
//  HomeWork26
//
//  Created by Дарья Дубровская on 13.03.22.
//

import UIKit
import RealmSwift
import SwiftUI

class TasksListTableViewController: UITableViewController {

    var tasksLists: Results<TasksList>!
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        tasksLists = realm.objects(TasksList.self).sorted(byKeyPath: "name")

        addTasksListsObserver()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtomSystemItemSelector))
        navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    @IBAction func sortingSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tasksList = tasksLists[indexPath.row]
        cell.configure(with: tasksList)
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let currentList = tasksLists[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])

        return swipeActions
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as! TasksTableViewController
            tasksVC.currentTasksList = tasksList
        }
    }

    @objc private func addBarButtomSystemItemSelector () {
        alertForAddAndUpdatesListTasks {
            print("ListTasks")
        }
    }

    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil,
        complition: @escaping () -> Void) {

        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButtonName = tasksList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var alertTextField: UITextField!

        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else { return }

            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName, complition: complition)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName

                StorageManager.saveTasksList(tasksList: tasksList)
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "ListName"
        }
        present(alert, animated: true)
    }

    private func addTasksListsObserver() {
        notificationToken = tasksLists.observe { change in
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")

//                if !modifications.isEmpty {
//                    var indexPathArray = [IndexPath]()
//                    for row in modifications {
//                        indexPathArray.append(IndexPath(row: row, section: 0))
//                    }
//                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
//                }
//
//                if !deletions.isEmpty {
//                    var indexPathArray = [IndexPath]()
//                    for row in deletions {
//                        indexPathArray.append(IndexPath(row: row, section: 0))
//                    }
//                    self.tableView.deleteRows(at: indexPathArray, with: .automatic)
//                }
//
//                if !insertions.isEmpty {
//                    var indexPathArray = [IndexPath]()
//                    for row in insertions {
//                        indexPathArray.append(IndexPath(row: row, section: 0))
//                    }
//                    self.tableView.insertRows(at: indexPathArray, with: .automatic)
//                }

            case .error(let error):
                print("error: \(error)")
            }
        }
    }
}


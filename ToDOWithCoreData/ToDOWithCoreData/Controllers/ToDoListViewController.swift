//
//  ToDoListViewController.swift
//  ToDOWithCoreData
//
//  Created by Jain, Abhilash Reddy [GCB-OT] on 11/10/18.
//  Copyright © 2018 Citi. All rights reserved.
//

import UIKit
import CoreData

struct Constants {
    static let itemsPlist = "items.plist"
    static let alertControllerTitle = "Add New Item"
    static let alertActionTitle = "Add Item"
    static let addTextFieldPlaceHolder = "Enter New Item Name"
    static let toDoListCellIdentifier = "toDoListCell"
}

class ToDoListViewController: UITableViewController {
    
    lazy var itemArray = [ItemsEntity]()
    lazy var defaults = UserDefaults.standard
//    lazy var itemsList = Items() //documentDirectory
    let defaultDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.itemsPlist)
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromCoreData()
    }
    
    //MARK: - Bar Button Action -
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var myTextField = UITextField()
        let alert = UIAlertController(title: Constants.alertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.alertActionTitle, style: .default) {[weak self] (action) in
            guard let newItem = myTextField.text else{return}
//            self?.itemsList.title = newItem this line is used for documentDirectory
            guard let managedObjectContext = self?.context else{return}
            let itemList = ItemsEntity(context: managedObjectContext)
            itemList.title = newItem
            itemList.done = false
            self?.itemArray.append(itemList)
            self?.saveDataToCoreData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.addTextFieldPlaceHolder
            myTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Saving And Loading Data using CoreData -
    
    private func saveDataToCoreData() {
        guard let managedObjectContext = context else{return}
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                debugPrint("context saving error \(error)")
            }
        }
        tableView.reloadData()
    }
    
    private func fetchDataFromCoreData() {
        guard let managedObjectContext = context else{return}
        let request: NSFetchRequest<ItemsEntity> = ItemsEntity.fetchRequest()
        do {
            itemArray = try managedObjectContext.fetch(request)
        } catch {
             debugPrint("context Fetch error \(error)")
        }
    }
    
    //MARK: - Saving And Loading Data using documentDirtectory -
   /* private func saveToDoListData() {
        let plistEncoder = PropertyListEncoder()
        do {
            let dataToSave = try plistEncoder.encode(itemArray)
            if let directoryPath = defaultDirectoryPath {
                try dataToSave.write(to: directoryPath)
            }
        } catch {
            debugPrint(" Encoder Error: \(error)")
        }
        tableView.reloadData()
    }
    
    private func loadToDoListData() {
        let plistDecoder = PropertyListDecoder()
        if let dataPath = defaultDirectoryPath, let data = try? Data(contentsOf: dataPath) {
            do {
                let fetchedData = try plistDecoder.decode([Items].self, from: data)
                itemArray = fetchedData
            } catch {
                debugPrint("Decoder Error:\(error)")
            }
        }
    }*/
}
//MARK: - TableView Delegate and Datasource methods-
extension ToDoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.toDoListCellIdentifier, for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveDataToCoreData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


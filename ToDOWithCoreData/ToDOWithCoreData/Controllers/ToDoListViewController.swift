//
//  ToDoListViewController.swift
//  ToDOWithCoreData
//
//  Created by Jain, Abhilash Reddy [GCB-OT] on 11/10/18.
//  Copyright  All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    @IBOutlet var serachBar: UISearchBar!
    lazy var itemArray = [ItemsEntity]()
    lazy var defaults = UserDefaults.standard
    //    lazy var itemsList = Items() //documentDirectory
    let defaultDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.itemsPlist)
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var selectedCategory: CategoryEntity? {
        didSet {
            fetchDataFromCoreData()
        }
    }
    
    //MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Bar Button Action -
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var myTextField = UITextField()
        let alert = UIAlertController(title: Constants.itemsAlertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.itemsAlertActionTitle, style: .default) {[weak self] (action) in
            guard let newItem = myTextField.text else{return}
            //            self?.itemsList.title = newItem this line is used for documentDirectory
            guard let managedObjectContext = self?.context else{return}
            let itemList = ItemsEntity(context: managedObjectContext)
            itemList.parentRelation = self?.selectedCategory
            itemList.title = newItem
            itemList.done = false
            self?.itemArray.append(itemList)
            self?.saveDataToCoreData(managedObjectContext)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.itemsTextFieldPlaceHolder
            myTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Loading Data using CoreData -
    private func fetchDataFromCoreData(with request:NSFetchRequest<ItemsEntity> = ItemsEntity.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let selectedValue = selectedCategory?.categoryName else {return}
        let categoryPredicate = NSPredicate(format: "parentRelation.categoryName MATCHES %@", selectedValue)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        guard let managedObjectContext = context else{return}
        do {
            itemArray = try managedObjectContext.fetch(request)
        } catch {
            debugPrint("context Fetch error \(error)")
        }
        tableView.reloadData()
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
        guard let managedContext = context else{return}
        saveDataToCoreData(managedContext)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: -SerachBar Delegate Methods -
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        let request: NSFetchRequest<ItemsEntity> = ItemsEntity.fetchRequest()
        /*Title is attribute name in Coredata,
         Contains is the keyword,[cd] for ignoring case sensitivity,
        %@ is to look for any text*/
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchDataFromCoreData(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchDataFromCoreData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


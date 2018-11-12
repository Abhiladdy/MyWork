//
//  ToDoListViewController.swift
//  ToDOWithCoreData
//
//  Created by Jain, Abhilash Reddy [GCB-OT] on 11/10/18.
//  Copyright  All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    @IBOutlet var serachBar: UISearchBar!
    lazy var itemArray = [ItemsEntity]()
    lazy var defaults = UserDefaults.standard
    let realm = try! Realm()
    var itemsFromRealm: Results<ItemsDataModel>?
    //    lazy var itemsList = Items() //documentDirectory
    let defaultDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.itemsPlist)
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // Selected CategoryValue from CoreData
    var selectedCategory: CategoryEntity? {
        didSet {
            fetchDataFromCoreData()
        }
    }
    
    // Selected CategoryValue from Realm
    var selectedCategoryFromRealm: CategoryDataModel? {
        didSet {
            fetchDataFromRealm()
        }
    }
    
    //MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        fetchDataFromRealm()
    }
    
    //MARK: - Bar Button Action -
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var myTextField = UITextField()
        let alert = UIAlertController(title: Constants.itemsAlertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.itemsAlertActionTitle, style: .default) {[weak self] (action) in
            guard let newItemTitle = myTextField.text else{return}
            //  self?.itemsList.title = newItem this line is used for documentDirectory
            //  self?.setValuesForDataSource(newItem) CoreData setup
            self?.setValuesForRealm(newItemTitle)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.itemsTextFieldPlaceHolder
            myTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Writing Data-
    private func setValuesForDataSource(_ newItemTitle: String) {
        guard let managedObjectContext = context else{return}
        let itemList = ItemsEntity(context: managedObjectContext)
        itemList.parentRelation = selectedCategory
        itemList.title = newItemTitle
        itemList.done = false
        itemArray.append(itemList)
        saveDataToCoreData(managedObjectContext)
    }
    
    private func setValuesForRealm(_ newItemTitle: String) {
        if let currentCategory = selectedCategoryFromRealm {
            do {
                try realm.write {
                    let newItemList = ItemsDataModel()
                    newItemList.title = newItemTitle
                    newItemList.isSelected = false
                    newItemList.dateCreated = Date()
                    if !newItemTitle.isEmpty {
                        currentCategory.itemsRelation.append(newItemList)
                    }
                }
            } catch {
                debugPrint("Items write error \(error)")
            }
            tableView.reloadData()
        }
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
    
    private func fetchDataFromRealm() {
        itemsFromRealm = selectedCategoryFromRealm?.itemsRelation.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Saving And Loading Data using documentDirtectory -
     // UnComment below code to use document directory to store data
     /*private func saveToDoListData() {
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
        return itemsFromRealm?.count ?? 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.toDoListCellIdentifier, for: indexPath)
        cell.textLabel?.text = itemsFromRealm?[indexPath.row].title ?? Constants.itemsListEmpty
        cell.accessoryType = itemsFromRealm?[indexPath.row].isSelected ?? false ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Below lines are used to update checkmark in Realm DB
        if let itemList = itemsFromRealm?[indexPath.row] {
            do {
                try realm.write {
                    itemList.isSelected = !itemList.isSelected
                }
            } catch {
                debugPrint("Checkmark update error \(error)")
            }
        }
        //UnComment below lines to use coreData
       /* guard let managedContext = context else{return}
        saveDataToCoreData(managedContext)*/
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: -SerachBar Delegate Methods -
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        itemsFromRealm = itemsFromRealm?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        /* Uncomment Below code to use core data
        let request: NSFetchRequest<ItemsEntity> = ItemsEntity.fetchRequest()
        /*Title is attribute name in Coredata,
         Contains is the keyword,[cd] for ignoring case sensitivity,
        %@ is to look for any text*/
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchDataFromCoreData(with: request)*/
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchDataFromRealm()
            /* Uncomment Below code to fetch data from core data
            fetchDataFromCoreData()*/
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


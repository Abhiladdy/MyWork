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
import ChameleonFramework

class ToDoListViewController: SwipeCellKitTableViewController {
    
    @IBOutlet var serachBar: UISearchBar!
    let toDoListViewModel = ToDoListViewModel()
    
    //MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedCategoryName = toDoListViewModel.selectedCategoryFromRealm?.categoryName {
            title = selectedCategoryName
        }
        toDoListViewModel.fetchDataFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let categoryHexColor = toDoListViewModel.selectedCategoryFromRealm?.color  else {return}
        updateNavBar(categoryHexColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateNavBar("002D72") // Original NavBar color
    }
    
    func updateNavBar(_ hexColor: String) {
        guard let navBar =  navigationController?.navigationBar else {fatalError("Navigation Bar is nil")}
        guard let navBarColor = UIColor(hexString: hexColor) else{return}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        serachBar.barTintColor = navBarColor
    }
    
    //MARK: - Bar Button Action -
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var myTextField = UITextField()
        let alert = UIAlertController(title: Constants.itemsAlertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.itemsAlertActionTitle, style: .default) {[weak self] (action) in
            guard let newItemTitle = myTextField.text else{return}
            self?.toDoListViewModel.setValuesForRealm(newItemTitle)
            self?.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.itemsTextFieldPlaceHolder
            myTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func updateDataModel(at indexPath: IndexPath) {
        toDoListViewModel.updateDataModel(at: indexPath)
    }
}
//MARK: - TableView Delegate and Datasource methods-
extension ToDoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoListViewModel.itemsFromRealm?.count ?? 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = toDoListViewModel.itemsFromRealm?[indexPath.row].title ?? Constants.itemsListEmpty
        cell.accessoryType = toDoListViewModel.itemsFromRealm?[indexPath.row].isSelected ?? false ? .checkmark : .none
        guard let items = toDoListViewModel.itemsFromRealm else {return cell}
        guard let selectedCategoryColorValue = toDoListViewModel.selectedCategoryFromRealm?.color else {return cell}
        cell.backgroundColor = UIColor(hexString: selectedCategoryColorValue)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items.count))
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? UIColor.white, returnFlat: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Below lines are used to update checkmark in Realm DB
        toDoListViewModel.updateSelectedCellValue(at: indexPath)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: -SerachBar Delegate Methods -
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        toDoListViewModel.itemsFromRealm = toDoListViewModel.itemsFromRealm?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            toDoListViewModel.fetchDataFromRealm()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


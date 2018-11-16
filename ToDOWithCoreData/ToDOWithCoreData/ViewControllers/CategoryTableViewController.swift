//
//  CategoryTableViewController.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/11/18.
//  Copyright All rights reserved.
//

import UIKit
import ChameleonFramework

class CategoryTableViewController: SwipeCellKitTableViewController {
    
    fileprivate let categoryViewModel = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        categoryViewModel.fetchDataFromRealmDB()
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let alertView = UIAlertController(title: Constants.itemsAlertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.itemsAlertActionTitle, style: .default) { [weak self](action) in
            guard let newCategory = categoryTextField.text else{return}
            self?.categoryViewModel.setValuesForRealm(newCategory)
            self?.tableView.reloadData()
        }
        alertView.addTextField { (alertTextField) in
            categoryTextField.placeholder = Constants.categoryTextFieldPlaceHolder
            categoryTextField = alertTextField
        }
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func setBackButtonUI() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setBackButtonUI()
        let todoListVC = segue.destination as? ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            todoListVC?.toDoListViewModel.selectedCategoryFromRealm = categoryViewModel.categoriesFromRealm?[indexPath.row]
        }
    }
    
    //MARK: - Updating DataModel -
    override func updateDataModel(at indexPath: IndexPath) {
        categoryViewModel.updateDataModel(at: indexPath)
    }
}

//MARK: - TableView Delegate and Datasoures Methods -
extension CategoryTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryViewModel.categoriesFromRealm?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryViewModel.categoriesFromRealm?[indexPath.row], let categoryHexValue = UIColor(hexString: category.color) {
            cell.textLabel?.text = category.categoryName
            cell.backgroundColor = categoryHexValue
            cell.textLabel?.textColor = ContrastColorOf(categoryHexValue, returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.itemListVcIdentifier, sender: self)
    }
}



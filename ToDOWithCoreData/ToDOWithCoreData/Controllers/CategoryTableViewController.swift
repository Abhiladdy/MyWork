//
//  CategoryTableViewController.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/11/18.
//  Copyright All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    lazy var categoryList = [CategoryEntity]()
    let realm = try! Realm()
    var categoriesFromRealm: Results<CategoryDataModel>?
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        //fetchDataFromCoreData() //Fetching Data from Core Data
        fetchDataFromRealmDB()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let alertView = UIAlertController(title: Constants.itemsAlertControllerTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.itemsAlertActionTitle, style: .default) { [weak self](action) in
            guard let newCategory = categoryTextField.text else{return}
//            self?.setValuesForDataSource(newCategory) //From CoreData
            self?.setValuesForRealm(newCategory)
        }
        alertView.addTextField { (alertTextField) in
            categoryTextField.placeholder = Constants.categoryTextFieldPlaceHolder
            categoryTextField = alertTextField
        }
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    
    //MARK: - Writing Data-
    private func setValuesForDataSource(_ newCategory: String) {
        guard let managedContext = context else{return}
        let newCategoryList = CategoryEntity(context: managedContext)
        categoryList.append(newCategoryList)
        newCategoryList.categoryName = newCategory
        saveDataToCoreData(managedContext)
    }
    
    private func setValuesForRealm(_ newCategory: String) {
        let newCategoryList = CategoryDataModel()
        newCategoryList.categoryName = newCategory
        saveDataToRealm(newCategoryList)
    }
    
    //MARK: - Saving Data to Realm DB -
    func saveDataToRealm(_ realmObject: Object) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(realmObject)
            }
        } catch {
            debugPrint("Realm DB Write Error \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Fetch Data From Core Data -
    private func fetchDataFromCoreData(with request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()) {
        request.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        do {
            guard let managedContext = context else {return}
            categoryList = try managedContext.fetch(request)
        } catch {
            debugPrint("Category List Fetch Error \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Fetch Data From Realm -
    private func fetchDataFromRealmDB() {
        categoriesFromRealm = realm.objects(CategoryDataModel.self)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backButton
        let todoListVC = segue.destination as? ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
             //When Using CoreData
            // todoListVC?.selectedCategory = categoryListEmpty?[indexPath.row]
            todoListVC?.selectedCategoryFromRealm = categoriesFromRealm?[indexPath.row]
        }
    }
}

//MARK: - TableView Delegate and Datasoures Methods -
extension CategoryTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesFromRealm?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryListCellIdentifier, for: indexPath)
        cell.textLabel?.text = categoriesFromRealm?[indexPath.row].categoryName ?? Constants.categoryListEmpty
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.itemListVcIdentifier, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0;
    }
    
    //MARK: - work in progress colors -
    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        
        let grad = CAGradientLayer()
        grad.frame = cell.bounds
        grad.colors = [(UIColor(red: 204.0 / 255.0, green: 239.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)).cgColor, (UIColor(red: 178.0 / 255.0, green: 231.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)).cgColor, (UIColor(red: 153.0 / 255.0, green: 223.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)).cgColor, (UIColor(red: 127.0 / 255.0, green: 215.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)).cgColor]
        
        cell.backgroundView = UIView()
        cell.backgroundView?.layer.insertSublayer(grad, at: UInt32(indexPath.row))
        
        let selectedGrad = CAGradientLayer()
        selectedGrad.frame = cell.bounds
        selectedGrad.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.layer.insertSublayer(selectedGrad, at: 0)
    }*/
    
}



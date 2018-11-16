//
//  ToDoListViewModel.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/15/18.
//

import Foundation
import RealmSwift
import UIKit

class ToDoListViewModel {
    //MARK: - Properties
    fileprivate let realm = try! Realm()
    var itemsFromRealm: Results<ItemsDataModel>?
    var selectedCategoryFromRealm: CategoryDataModel? {
        didSet {
            fetchDataFromRealm()
        }
    }
    
    //MARK: - Fetching Data from Realm DB
    func fetchDataFromRealm() {
        itemsFromRealm = selectedCategoryFromRealm?.itemsRelation.sorted(byKeyPath: "title", ascending: true)
    }
    
    //MARK: - Saving Data to Realm DB
    func saveDataToRealm(_ realmObject: Object) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(realmObject)
            }
        } catch {
            debugPrint("Realm DB Write Error \(error)")
        }
    }
    
    //MARK: - Writing Data
    func setValuesForRealm(_ newItemTitle: String) {
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
        }
    }
    
    //MARK: - Updating Data to Realm
    func updateDataModel(at indexPath: IndexPath) {
        if let rowToBeDeleted = itemsFromRealm?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(rowToBeDeleted)
                }
            } catch {
                debugPrint("Item data delete error \(error)")
            }
        }
    }
    
    func updateSelectedCellValue(at indexPath: IndexPath) {
        if let itemList = itemsFromRealm?[indexPath.row] {
            do {
                try realm.write {
                    itemList.isSelected = !itemList.isSelected
                }
            } catch {
                debugPrint("Checkmark update error \(error)")
            }
        }
    }
}

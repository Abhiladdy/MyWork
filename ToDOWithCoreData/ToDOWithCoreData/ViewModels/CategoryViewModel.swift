//
//  CategoryViewModel.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/15/18.
//

import Foundation
import UIKit
import RealmSwift

class CategoryViewModel {
    //MARK: - Properties
    fileprivate let realm = try! Realm()
    var categoriesFromRealm: Results<CategoryDataModel>?
    
    //MARK: - Writing Data
    func setValuesForRealm(_ newCategory: String) {
        let newCategoryList = CategoryDataModel()
        newCategoryList.categoryName = newCategory
        newCategoryList.color = UIColor.randomFlat.hexValue()
        saveDataToRealm(newCategoryList)
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
    
    //MARK: - Fetch Data From Realm
    func fetchDataFromRealmDB() {
        categoriesFromRealm = realm.objects(CategoryDataModel.self)
    }
    
    //MARK: - Updating DataModel
    func updateDataModel(at indexPath: IndexPath) {
        if let rowTobeDeleted = categoriesFromRealm?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(rowTobeDeleted)
                }
            } catch {
                debugPrint("delete error \(error)")
            }
        }
    }
    
}

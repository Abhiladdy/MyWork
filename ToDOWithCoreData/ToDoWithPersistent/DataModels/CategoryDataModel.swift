//
//  RealmDataModel.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/12/18.
//

import Foundation
import RealmSwift

/* Realm Table for CategoryList */
final class CategoryDataModel: Object {
    @objc dynamic var categoryName = ""
    let itemsRelation = List<ItemsDataModel>()
}

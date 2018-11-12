//
//  ItemsDataModel.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/12/18.
//

import Foundation
import RealmSwift

/* Realm Table for ItemsList */
final class ItemsDataModel: Object {
    @objc dynamic var title = ""
    @objc dynamic var isSelected = false
    @objc dynamic var dateCreated: Date?
    var parentRelation = LinkingObjects(fromType: CategoryDataModel.self, property: "itemsRelation")
}

//
//  CommonExtensions.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/11/18.
//  Copyright  All rights reserved.
//

import UIKit
import CoreData

extension UITableViewController {
    //MARK: - Saving Data to CoreData -
    func saveDataToCoreData(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("context saving error \(error)")
            }
        }
        tableView.reloadData()
    }
    
}

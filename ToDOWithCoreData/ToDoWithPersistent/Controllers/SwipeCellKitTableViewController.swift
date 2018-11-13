//
//  SwipeCellKitTableViewController.swift
//  ToDOWithCoreData
//
//  Created by Abhilash Reddy Jain on 11/12/18.
//

import UIKit
import SwipeCellKit

class SwipeCellKitTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 90.0
    }

    // MARK: - Table view data source -
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? SwipeTableViewCell
            else{return UITableViewCell()}
        cell.delegate = self
        return cell
    }

    //This functions helps to delete row, when user click's on delete button
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {[weak self] action, indexPath in
            self?.updateDataModel(at: indexPath)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "deleteIcon")
        return [deleteAction]
    }
    
    //This functions helps to delete row, when user swipes to right on delete button
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    //This function helps to update Realm Database
    func updateDataModel(at indexPath: IndexPath) {
        //To handle Realm DataModels
    }
}

//
//  ItemDetails.swift
//  ToDOWithCoreData
//
//  Created by Jain, Abhilash Reddy [GCB-OT] on 11/10/18.
//  Copyright © 2018 Citi. All rights reserved.
//

import Foundation
/*This is Data Model useful to store data in document directory*/
struct Items: Codable {
    var title = ""
    var done = false
}

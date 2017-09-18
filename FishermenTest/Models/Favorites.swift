//
//  Favorites.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import Foundation
import RealmSwift

class Favorites: Object {
    
    dynamic var id: String = "Favorites"
    var contacts = List<Contact>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

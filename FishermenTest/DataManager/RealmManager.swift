//
//  RealmManager.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import RealmSwift

class RealmManager {
    
    // MARK: - Variables
    
    static let shared = RealmManager()
    
    var realm: Realm
    
    // MARK: - Life cycle
    
    private init(){
        realm = try! Realm()
    }
    
    // MARK: - Methods
    
    func save(object: Object, update: Bool = true) {
        
        try! realm.write({
            realm.add(object, update: update)
        })
    }
    
    func save(objects: [Object], update: Bool) {
        
        try! realm.write({
            // If update = true, objects that are already in the Realm will be
            // updated instead of added a new.
            realm.add(objects, update: update)
        })
    }
    
    func getObjectsWith(type: Object.Type) -> Results<Object>? {
        
        return realm.objects(type)
    }
    
    func remove(type: Object) {
        
        try! realm.write({
            realm.delete(type)
        })
    }
    
}

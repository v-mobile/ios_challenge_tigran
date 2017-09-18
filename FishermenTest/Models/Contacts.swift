//
//  Contacts.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Contacts: Object, ResponseObjectSerializable {
    
    dynamic var id: String = "Users"
    var contacts = List<Contact>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        guard let arr = json.array else {
            return
        }
        for item in arr {
            let contact = Contact(json: JSON(item.dictionaryValue))
            contacts.append(contact!)
        }
    }
    
    class func getContacts(completionHandler: @escaping (Contacts?, Info?, ApiError?) -> Void) {
        let url = "/?results=20"
        TestAPI.shared.invokeRequestWithObject(method: .get, url: url, queryParams: nil, bodyPayload: nil) { (object: Contacts?, info: Info?, error: ApiError?) in
            completionHandler(object, info, error)
        }
    }
    
    class func getContactsWith(seed: String, page: Int, pageSize: Int, completionHandler: @escaping (Contacts?, Info?, ApiError?) -> Void) {
        let url = "/?page=\(page)&results=\(pageSize)&seed=\(seed)"
        TestAPI.shared.invokeRequestWithObject(method: .get, url: url, queryParams: nil, bodyPayload: nil) { (object: Contacts?, info: Info?, error: ApiError?) in
            completionHandler(object, info, error)
        }
    }
    
}

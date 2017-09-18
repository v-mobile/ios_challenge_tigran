//
//  Contact.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import RealmSwift
import SwiftyJSON

enum Nationalities: String {
    //    AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NL, NZ, TR, US
    case AU = "au"
    case BR = "br"
    case CA = "ca"
    case CH = "ch"
    case DE = "de"
    case DK = "dk"
    case ES = "es"
    case FI = "fi"
    case FR = "fk"
    case GB = "gb"
    case IE = "ie"
    case IR = "ir"
    case NL = "nl"
    case NZ = "nz"
    case TR = "tr"
    case US = "us"
}

enum AttachmentType: Int {
    case PDFType = 0
    case WordType = 1
    case ExcelType = 2
    case ImageType = 3
}

class Name: ResponseObjectSerializable {
    dynamic var title = ""
    dynamic var firstname = ""
    dynamic var lastname = ""
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        title = json["title"].stringValue
        firstname = json["first"].stringValue
        lastname = json["last"].stringValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["title"] = title as AnyObject?
        json["first"] = firstname as AnyObject?
        json["last"] = lastname as AnyObject?
        
        return json
    }
}

class Location: ResponseObjectSerializable {
    dynamic var street = ""
    dynamic var city = ""
    dynamic var state = ""
    dynamic var postcode: Int = 0
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        street = json["street"].stringValue
        city = json["city"].stringValue
        state = json["state"].stringValue
        postcode = json["postcode"].intValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["street"] = street as AnyObject?
        json["city"] = city as AnyObject?
        json["state"] = state as AnyObject?
        json["postcode"] = postcode as AnyObject?
        
        return json
    }
}

class Picture: ResponseObjectSerializable {
    dynamic var largeImageUrl = ""
    dynamic var mediumImageUrl = ""
    dynamic var thumbnailUrl = ""
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        largeImageUrl = json["large"].stringValue
        mediumImageUrl = json["medium"].stringValue
        thumbnailUrl = json["thumbnail"].stringValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["large"] = largeImageUrl as AnyObject?
        json["medium"] = mediumImageUrl as AnyObject?
        json["thumbnail"] = thumbnailUrl as AnyObject?
        
        return json
    }
}

class Identifier: ResponseObjectSerializable {
    dynamic var name = ""
    dynamic var value = ""
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        name = json["name"].stringValue
        value = json["value"].stringValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["name"] = name as AnyObject?
        json["value"] = value as AnyObject?
        
        return json
    }
}


class Contact: Object, ResponseObjectSerializable {
    //    dynamic var id:String = ""
    dynamic var gender: String = ""
    dynamic var title = ""
    dynamic var firstname = ""
    dynamic var lastname = ""
    dynamic var street = ""
    dynamic var city = ""
    dynamic var state = ""
    dynamic var postcode: Int = 0
    
    dynamic var email: String = ""
    dynamic var dob: String = ""
    dynamic var phone = ""
    dynamic var cell = ""
    dynamic var largeImageUrl = ""
    dynamic var mediumImageUrl = ""
    dynamic var thumbnailUrl = ""
    dynamic var name = ""
    dynamic var value = ""
    dynamic var nationality: String = "us"
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        gender = json["gender"].stringValue
        
        if let name = Name(json: json["name"]) {
            title = name.title
            firstname = name.firstname
            lastname = name.lastname
        }
        if let location = Location(json: json["location"]) {
            street = location.street
            city = location.city
            state = location.state
            postcode = location.postcode
        }
        if let picture = Picture(json: json["picture"]) {
            largeImageUrl = picture.largeImageUrl
            mediumImageUrl = picture.mediumImageUrl
            thumbnailUrl = picture.thumbnailUrl
        }
        if let identifier = Identifier(json: json["id"]) {
            name = identifier.name
            value = identifier.value
        }
        
        email = json["email"].stringValue
        dob = json["dob"].stringValue
        phone = json["phone"].stringValue
        cell = json["cell"].stringValue
        
        nationality = json["nat"].stringValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["gender"] = gender as AnyObject?
        json["title"] = title as AnyObject?
        json["first"] = firstname as AnyObject?
        json["last"] = lastname as AnyObject?
        json["street"] = street as AnyObject?
        json["city"] = city as AnyObject?
        json["state"] = state as AnyObject?
        json["postcode"] = postcode as AnyObject?
        json["large"] = largeImageUrl as AnyObject?
        json["medium"] = mediumImageUrl as AnyObject?
        json["thumbnail"] = thumbnailUrl as AnyObject?
        
        json["name"] = name as AnyObject?
        json["value"] = value as AnyObject?
        json["nat"] = nationality as AnyObject?
        
        return json
    }
    
}



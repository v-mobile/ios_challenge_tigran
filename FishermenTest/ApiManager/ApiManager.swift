//
//  ApiManager.swift
//  FishermenTest
//
//  Created by Tigran Kirakosyan on 9/18/17.
//  Copyright © 2017 V-Mobile LLC. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Reqres

public protocol ResponseObjectSerializable {
    init?(json: SwiftyJSON.JSON)
}

public var Manager: Alamofire.SessionManager = {
    
    var configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    
    #if DEBUG
        configuration = Reqres.defaultSessionConfiguration()
    #endif
    
    let manager = Alamofire.SessionManager(
        configuration: configuration
    )
    
    return manager
}()

enum RequestMethod {
    case get
    case put
    case post
    case delete
    
    var type: HTTPMethod {
        switch self {
        case .get:
            return HTTPMethod.get
        case .put:
            return HTTPMethod.put
        case .post:
            return HTTPMethod.post
        case .delete:
            return HTTPMethod.delete
        }
    }
}

public enum ApiError: Error {
    case network(error: NSError)
    case parsing
    case serialization
    case backend(message: String)
    case custom(reason: String)
    
    var message: String {
        switch self {
        case .network(let error):
            return error.domain
        case .parsing:
            return "retry_error"
        case .serialization:
            return "retry_error"
        case .backend(let message):
            return message
        case .custom(let reason):
            return reason
        }
    }
    
}

class Info: ResponseObjectSerializable {
    dynamic var seed = ""
    dynamic var results: Int = 0
    dynamic var page: Int = 0
    dynamic var version = ""
    
    required convenience init?(json: SwiftyJSON.JSON) {
        self.init()
        seed = json["seed"].stringValue
        results = json["results"].intValue
        page = json["page"].intValue
        version = json["version"].stringValue
    }
    
    func objectToJSON() -> [String: Any] {
        var json = [String: AnyObject]()
        json["seed"] = seed as AnyObject?
        json["results"] = results as AnyObject?
        json["page"] = page as AnyObject?
        json["version"] = version as AnyObject?
        
        return json
    }
}

class TestAPI {
    
    // MARK: - Constants
    
    let appBaseUrl = "https://randomuser.me/api"
    
    // MARK: - Variables
    
    static let shared = TestAPI()
    var netManager: NetworkReachabilityManager?
    var headers: [String: String] = [:]
    
    // MARK: - Init
    
    private init() {
        
        netManager = NetworkReachabilityManager()
        netManager?.listener = { status in
            #if DEBUG
                print("Network Status Changed: \(status)")
            #endif
            switch status {
            case .notReachable:
                guard let controller =  UIApplication.shared.keyWindow?.rootViewController?.presentedViewController else {
                    return
                }
                let alert = UIAlertController(title: "Warning", message: "no_connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                controller.present(alert, animated: true, completion: nil)
                break
            case .reachable(_), .unknown:
                break;
            }
        }
        netManager?.startListening()
    }
    
    // MARK: - Handlers
    
    func handleResponse( response: DataResponse<Any>, completion: @escaping (Any?, Info?, ApiError?) -> Void) {
        
        guard let _ = response.response else {
            if let error = response.error as NSError? {
                completion(nil, nil, ApiError.network(error: error))
            } else {
                completion(nil, nil, ApiError.custom(reason: "retry_error"))
            }
            
            return
        }
        
        let (result, error) = self.parseResponse(result: response.result)
        completion(result?.result, result?.info, error)
    }
    
    func parseResponse(result: Any) -> ((result: Any?, info: Info?)?, ApiError?) {
        
        #if DEBUG
            print(result)
        #endif
        
        let res = result as? Result<Any>
        let dictionary = res?.value as? NSDictionary
        let error = dictionary?["error"] as? String
        if res != nil && dictionary != nil && error != nil {
            return (nil, ApiError.backend(message: error!))
        }
        
        guard let result = result as? Result<Any>, let dict = result.value as? NSDictionary, let data = dict["results"], let info = dict["info"] else {
            return (nil, ApiError.parsing)
        }
        let json = JSON(info)
        guard let infoObject = Info(json: json) else {
            return(nil, ApiError.serialization)
        }
        
        return ((result: data, info: infoObject), nil)
    }
    
    // MARK: - Helper Functions
    
    func setHeaders(additional: [String: String]?) {
        if let additional = additional {
            for (key, value) in additional {
                headers[key] = value
            }
        }
        headers["Content-Type"] = "application/json"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            headers["X-ClientVersion"] = "\(version).\(build)"
            headers["X-Platform"] = "iOS \(UIDevice.current.systemVersion)"
        }
    }
    
    // MARK: - Invoke Request Methods
    
    func invokeRequestWithObject<T: ResponseObjectSerializable>(method: RequestMethod, url: String, queryParams:[String:Any]? = nil, bodyPayload:NSData? = nil, additionalHeaders: [String: String]? = nil, completion: @escaping (T?, Info?, ApiError?) -> Void) {
        
        setHeaders(additional: additionalHeaders)
        let url = appBaseUrl + url
        _ = Manager.request(
            url,
            method: method.type,
            parameters: queryParams,
            encoding: JSONEncoding.prettyPrinted/*URLEncoding.default*/,
            headers: headers
            ).validate()
            .responseJSON { (response: DataResponse<Any>) in
                self.handleResponse( response: response, completion: { (result, info, error) in
                    
                    if let error = error {
                        #if DEBUG
                            print(error.message + error.localizedDescription)
                        #endif
                        completion(nil, nil, error)
                        return
                    }
                    guard let result = result else {
                        completion(nil, nil, ApiError.parsing)
                        return
                    }
                    let json = JSON(result)
                    guard let object = T(json: json) else {
                        completion(nil, nil, ApiError.serialization)
                        return
                    }
                    completion(object, info, nil)
                })
        }
    }
    
    func invokeRequestWithArray<T: ResponseObjectSerializable>(method: RequestMethod, url: String, queryParams:[String:Any]? = nil, bodyPayload:NSData? = nil, additionalHeaders: [String: String]? = nil, completion: @escaping ([T]?, Info?, ApiError?) -> Void) {
        
        setHeaders(additional: additionalHeaders)
        let url = appBaseUrl + url
        _ = Alamofire.SessionManager.default.request(
            url,
            method: method.type,
            parameters: queryParams,
            encoding: JSONEncoding.prettyPrinted/*URLEncoding.default*/,
            headers: headers
            ).validate()
            .responseJSON { (response: DataResponse<Any>) in
                self.handleResponse( response: response, completion: { (result, info, error) in
                    if let error = error {
                        completion(nil, nil, error)
                        return
                    }
                    
                    guard let result = result else {
                        completion(nil, nil, ApiError.parsing)
                        return
                    }
                    
                    let json = JSON(result)
                    guard let array = json.array else {
                        completion(nil, nil, ApiError.parsing)
                        return
                    }
                    var objects: [T] = []
                    for item in array {
                        if let object = T(json: item) {
                            objects.append(object)
                        }
                    }
                    completion(objects, info, nil)
                })
        }
    }
    
}


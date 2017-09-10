//
//  HasuraAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation
import SwiftyJSON

class HasuraAPIManager {
    var hasuraURL: URL {
        return URL(string: "https://app.admirable43.hasura-app.io/medication/")!
    }
    let session = URLSession.shared
    
    static var sharedInstance: HasuraAPIManager = {
        let apiManager = HasuraAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> HasuraAPIManager {
        return sharedInstance
    }
    
    func getUsageForDrug(_ drug: String, completionHandler: @escaping (((String, Int)?) ->())) {
        
        // Create our request URL
        
        var request = URLRequest(url: hasuraURL.appendingPathComponent(drug))
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Run the request on a background thread
        DispatchQueue.global().async {
            let task: URLSessionDataTask = self.session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "")
                    completionHandler(nil)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    // Use SwiftyJSON to parse results
                    let json = JSON(data: data)
                    let errorObj: JSON = json["error"]
                    if (errorObj.dictionaryValue != [:]) {
                        print("Error code \(errorObj["code"]): \(errorObj["message"])")
                        completionHandler(nil)
                    }
                    var instructions: String = "No instructions could be found"
                    var found = false
                    if let info = json["instructions"].string {
                        found = true
                        instructions = info
                    }
                    var maximum = 1
                    if let maxim = json["maximum"].int{
                        found = true
                        maximum = maxim
                    }
                    if found{
                        completionHandler((instructions,maximum))
                    }else{
                        completionHandler(nil)
                    }
                })
            }
            task.resume()
        }
    }
    
}

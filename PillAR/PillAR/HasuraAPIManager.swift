//
//  HasuraAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation

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
    
    func getUsageForDrug(_ drug: String, completionHandler: ((String)->(frequency: Int, maximum: Int, size: Int)?)) {
        
        // Create our request URL
        
        var request = URLRequest(url: hasuraURL.appendingPathComponent(drug))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Run the request on a background thread
        DispatchQueue.global().async {
            let task: URLSessionDataTask = self.session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    // Use SwiftyJSON to parse results
                    let json = JSON(data: data)
                    let errorObj: JSON = json["error"]
                    if (errorObj.dictionaryValue != [:]) {
                        print("Error code \(errorObj["code"]): \(errorObj["message"])")
                    }
                    print(json)
                    var responses: [String] = []
                    if let logoResults = json["responses"][0]["logoAnnotations"].array, logoResults.count > 0 {
                        for item in logoResults{
                            if let description = item["description"].string {
                                responses.append(description)
                            }
                        }
                    }
                    
                    completionHandler(responses.first)
                })
            }
            
            task.resume()
        }
        
        completionHandler(nil)
    }
    
}

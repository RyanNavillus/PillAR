//
//  HasuraAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class HasuraAPIManager {
    var hasuraURL: URL {
        return URL(string: "https://app.admirable43.hasura-app.io/")!
    }
    let session = URLSession.shared
    
    static var sharedInstance: HasuraAPIManager = {
        let apiManager = HasuraAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> HasuraAPIManager {
        return sharedInstance
    }
    
    func getUsageForDrug(_ drug: String, completionHandler: @escaping (((instructions: String,maximumDose: Int)?) ->())) {
        print("Getting usages for \(drug)")
        if  DataManager.shared().drugUsageCache[drug.lowercased()] != nil {
            print("Cache Hit !!!!!")
            let cachedResult = DataManager.shared().drugUsageCache[drug.lowercased()]
            completionHandler(cachedResult)
            return
        }
        
        // Create our request URL
        
        var request = URLRequest(url: hasuraURL.appendingPathComponent("medication/").appendingPathComponent(drug))
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
                        DataManager.shared().drugUsageCache[drug.lowercased()] = (instructions,maximum)
                        completionHandler((instructions,maximum))
                    }else{
                        completionHandler(nil)
                    }
                })
            }
            task.resume()
        }
    }
    
    
    func getLogoForDrug( drug: String, completionHandler: @escaping (UIImage)-> ()){
        if let cachedImage = DataManager.shared().logoCache[drug.lowercased()]{
            completionHandler(cachedImage)
            return
        }
        
        Alamofire.request(hasuraURL.appendingPathComponent("logo/\(drug)")).responseJSON { (response) in
            if let json = response.data {
                let data = JSON(data: json)
                print(data)
                if let urlStr = data["url"].string{
                    let url = URL(string: urlStr)!
                    self.downloadImage(url: url, searchTerm: drug, completionHandler: completionHandler)
                }
            }

        }
        
        
    }
    
    func downloadImage(url: URL, searchTerm:String, completionHandler:@escaping (UIImage)->()) {
        print("Download Started")
        print(url)
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            if let image =  UIImage(data: data){
                DataManager.shared().logoCache[searchTerm.lowercased()] = image
                DispatchQueue.main.async() { () -> Void in
                    completionHandler(image)
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}

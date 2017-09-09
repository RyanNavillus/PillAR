//
//  GoogleAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation
import UIKit

class GoogleAPIManager {
    
    let baseURL: NSURL = NSURL(string: "https://vision.googleapis.com")!
    let apiKey = "AIzaSyBNed9n7O5T6hsEJ8lrvZVz-L00Q0F_h3w" // THIS SHOULD NOT BE IN A PUBLIC REPO BUT FUCK IT SHIP IT
    
    static var sharedInstance: GoogleAPIManager = {
        let apiManager = GoogleAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> GoogleAPIManager {
        return sharedInstance
    }
    
    func identifyDrug(image: UIImage, completionHandler: (NSString, CGPoint) -> ()) {
        guard let apiURL = baseURL.appendingPathComponent("/v1/images:annotate") else {
            print("Failed to create url for identifyDrug")
            return
        }
        let requestURL = apiURL.appendingPathComponent("?key=\(apiKey)")
        let request = NSMutableURLRequest(url: requestURL) // URL for accessing vision api
        let session = URLSession.shared
        
        let imageData = UIImagePNGRepresentation(image)?.base64EncodedString(options: .lineLength64Characters)
        
        let json: [String: Any] = [
            "requests" : [
                "image" : [
                    "content" : "\(imageData)"
                ],
                "features" : [
                    [
                        "type" : "LOGO_DETECTION",
                        "maxResults" : 3
                    ]
                ]
            ]
        ]
        if JSONSerialization.isValidJSONObject(json) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                
            }
        } else {
            print("Invalid json created for identifyDrug")
            return
        }
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error -> Void in
            //Parse Json for response
            //let json = NSJSONSerialization.JSONObjectWithData(data, options: <#T##NSJSONReadingOptions#>)
        }
        return
    }
}

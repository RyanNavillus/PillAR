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
    
    public static var sharedInstance: GoogleAPIManager = {
        let apiManager = GoogleAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> GoogleAPIManager {
        return sharedInstance
    }
    
//    func identifyDrug(image: UIImage) -> (label: NSString, location: CGPoint) {
//        let requestURL = baseURL.URLByAppendingPathComponent("/v1/images:annotate").URLByAppendingPathComponent("?key=\(apiKey)")
//        let request = NSMutableURLRequest(URL: requestURL) // URL for accessing vision api
//        let session = URLSession.sharedSession()
//
//        let task = session.dataTaskWithRequest(request) {
//            data, response, error -> Void in
//            //let json = NSJSONSerialization.JSONObjectWithData(data, options: <#T##NSJSONReadingOptions#>)
//        }
//        return (label: "", location: CGPoint())
//    }
}

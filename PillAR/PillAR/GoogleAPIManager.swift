//
//  GoogleAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation

class GoogleAPIManager {
    
    let baseURL = ""
    let apiKey = "THIS SHOULD NOT BE IN A PUBLIC REPO BUT FUCK IT SHIP IT"
    
    public static var sharedInstance: GoogleAPIManager = {
        let apiManager = GoogleAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> GoogleAPIManager {
        return sharedInstance
    }
}
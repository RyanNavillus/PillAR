//
//  GoogleAPIManager.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class GoogleAPIManager {
    
    var googleAPIKey = "AIzaSyBNed9n7O5T6hsEJ8lrvZVz-L00Q0F_h3w"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    let session = URLSession.shared
    
    static var sharedInstance: GoogleAPIManager = {
        let apiManager = GoogleAPIManager()
        
        return apiManager
    }()
    
    class func shared() -> GoogleAPIManager {
        return sharedInstance
    }
    
    func identifyDrug(image: UIImage, completionHandler:@escaping (((itemName: String, instructions: String, maximum: Int)?) -> ())) {
        // Base64 encode the image and create the request
        let binaryImagePacket = base64EncodeImage(image)
        
        //FIX ME
        createRequest(with: binaryImagePacket, completionHandler: completionHandler)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(_ image: UIImage) -> (String, CGSize) {
        var imagedata = UIImagePNGRepresentation(image)!
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return (imagedata.base64EncodedString(options: .endLineWithCarriageReturn), image.size)
    }
    
    func createRequest(with imageBase64: (String, CGSize), completionHandler: @escaping (((itemName: String, instructions: String, maximum: Int)?) -> ())) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64.0
                ],
                "features": [
                    [
                        "type": "LOGO_DETECTION",
                        "maxResults": 3
                    ],
                    [
                        "type": "WEB_DETECTION",
                        "maxResults": 3
                    ]

                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
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
//                    print(json)
                    var responses: [String] = []
                    if let logoResults = json["responses"][0]["logoAnnotations"].array, logoResults.count > 0 {
                        for item in logoResults{
                            if let description = item["description"].string {
                                responses.append(description)
                            }
                        }
                    }
                    
                    if let webEntities = json["responses"][0]["webDetection"]["webEntities"].array, webEntities.count > 0 {
                        for item in webEntities {
                            if let description = item["description"].string {
                                responses.append(description)
                            }
                        }
                    }
                    let apiManager = HasuraAPIManager.shared()
                    var calls = 0
                    // Call hasura api for each result from Google
                    print(responses)
                    var lowestResponseNum = 1000
                    var lowestResponse: (instructions: String, maximum: Int)? = nil
                    for response in responses {
                        calls += 1
                        let handler = {
                            (data: (instructions: String, maximum: Int)?) in
                            calls -= 1
                            if data != nil{
                                let responseIndex = responses.index(of: response)
                                print("Response: \(responseIndex) \(response)")
                                if responseIndex! <= lowestResponseNum{
                                    lowestResponseNum = responseIndex!
                                    lowestResponse = data
                                }
                            }
                            if calls == 0{
                                if lowestResponseNum == 1000{
                                    completionHandler(nil)
                                }else{
                                    print("FINAL RESULT")
                                    print("\(responses[lowestResponseNum]), \nmax: \(lowestResponse!.maximum), \ninstructions: \(lowestResponse!.instructions)")
                                    completionHandler((responses[lowestResponseNum], lowestResponse!.instructions, lowestResponse!.maximum))
                                }
                            }
                        }

                        // For each item returned by Google, get its usage information
//                        apiManager.getUsageForDrug("\(response)", completionHandler: { (response) in
//                            if response != nil{
//
//                            }
//                        })
                        apiManager.getUsageForDrug("\(response)", completionHandler: handler)
                    }
                
                })
            }
            
            task.resume()
        }
    }
    
    func distanceFromPointToCenterSize(p1:CGPoint, s2:CGSize) -> Double {
        let midSize = CGPoint(x: s2.width / 2, y: s2.height / 2)
        let xDist = p1.x - midSize.x
        let yDist = p1.y - midSize.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    
}

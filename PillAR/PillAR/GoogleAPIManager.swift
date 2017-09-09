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
    
    func identifyDrug(image: UIImage, completionHandler: @escaping ((String?) -> ())) {
        // Base64 encode the image and create the request
        let binaryImagePacket = base64EncodeImage(image)
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
    
    func createRequest(with imageBase64: (String, CGSize), completionHandler: @escaping ((String?) -> ())) {
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
                    print(json)
                    var responses: [String] = []
                    if let logoResults = json["responses"][0]["logoAnnotations"].array, logoResults.count > 0 {
                        for item in logoResults{
                            if let description = item["description"].string {
//                            let verticiesArr = item["boundingPoly"]["vertices"].array{
//                                var total_x = 0.0
//                                var total_y = 0.0
//                                var num = 0.0
//                                for vertex in verticiesArr{
//                                    if let xVal = vertex["x"].double, let yVal = vertex["y"].double{
//                                        total_x += xVal
//                                        total_y += yVal
//                                        num += 1
//                                    }
//                                }
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
                    
//                    if responses.count > 1 {
//                        var index_closest_to_center = 0
//                        var minDistance = Double.infinity
//                        for i in 0..<responses.count{
//                            let item = responses[i]
//                            if self.distanceFromPointToCenterSize(p1: item.1, s2: item.2) < minDistance{
//                                minDistance = self.distanceFromPointToCenterSize(p1: item.1, s2: item.2)
//                                index_closest_to_center = i
//                            }
//                        }
//                        let closest = responses[index_closest_to_center]
//                        responses = Array<(String, CGPoint, CGSize)>()
//                        responses.append(closest)
//                    }
        
                    completionHandler(responses.first)
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

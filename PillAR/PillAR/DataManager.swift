//
//  DataManager.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class DataManager {
    static var sharedInstance: DataManager = {
        let dataManager = DataManager()
        return dataManager
    }()
    
    class func shared() -> DataManager {
        return sharedInstance
    }
    
    init(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
        
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 1, timeTaken: dateFormatter.date(from: "09-09-2017 7:15:11 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 2, timeTaken: dateFormatter.date(from: "09-09-2017 8:35:51 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 3, timeTaken: dateFormatter.date(from: "09-09-2017 10:15:35 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 4, timeTaken: dateFormatter.date(from: "09-09-2017 13:53:26 EST")!, actionStatement: "YOU MAY NEED TO REFIL SOON"))
        
    }
    
    
    var pillHistoryData:[HistoryData] = [HistoryData]()
    
    
    
}

struct PillHistoryKeys {
    static let name = "Name"
    static let dailyDosageMax = "DailyDosageMax"
    static let dailyDosage = "DailyDosage"
    static let timeTaken = "TimeTaken"
    static let actionStatement = "ActionStatement"
}

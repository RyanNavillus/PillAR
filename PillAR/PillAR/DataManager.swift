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
    
    var historyState:HistoryVisible = .Hidden
    
    class func shared() -> DataManager {
        return sharedInstance
    }
    
    init(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
        
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-02-2017 6:23:30 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-03-2017 6:20:15 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-04-2017 7:02:01 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-05-2017 7:45:06 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-06-2017 7:45:06 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Advil", maxDailyDosage: 3, takenToday: 1, timeTaken: dateFormatter.date(from: "09-06-2017 17:31:25 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-07-2017 6:28:56 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-08-2017 9:03:07 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Advil", maxDailyDosage: 3, takenToday: 1, timeTaken: dateFormatter.date(from: "09-09-2017 7:15:11 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 1, takenToday: 1, timeTaken: dateFormatter.date(from: "09-09-2017 8:35:51 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Advil", maxDailyDosage: 3, takenToday: 2, timeTaken: dateFormatter.date(from: "09-09-2017 11:15:35 EST")!))
        pillHistoryData.append(HistoryData(drugName: "Advil", maxDailyDosage: 3, takenToday: 3, timeTaken: dateFormatter.date(from: "09-09-2017 15:53:26 EST")!, actionStatement: "YOU MAY NEED TO REFILL SOON"))
        pillHistoryData.append(HistoryData(drugName: "Alka-Seltzer", maxDailyDosage: 5, takenToday: 1, timeTaken: dateFormatter.date(from: "09-09-2017 19:20:01 EST")!))
        
        
        pillHistoryData.sort { (h1, h2) -> Bool in
            return h1.timeTaken > h2.timeTaken 
        }
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

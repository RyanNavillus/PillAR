//
//  HistoryData.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit
struct HistoryDataKeys {
    static let name = "Name"
    static let dailyDosageMax = "DailyDosageMax"
    static let dailyDosage = "DailyDosage"
}
class HistoryData: NSObject {
    
    var drugName: String = ""
    var maxDailyDosage: Int = 0
    var takenToday: Int = 0
    var timeTaken: Date = Date()
    
    
    init(drugName: String, maxDailyDosage:Int = 4, takenToday:Int = 0, timeTaken: Date = Date()){
        self.drugName = drugName
        self.maxDailyDosage = maxDailyDosage
        self.takenToday = takenToday
        self.timeTaken = timeTaken
    }
    
}

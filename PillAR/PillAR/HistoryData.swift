//
//  HistoryData.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit
class HistoryData: NSObject {
    
    var drugName: String = ""
    var maxDailyDosage: Int = 0
    var takenToday: Int = 0
    var timeTaken: Date = Date()
    var actionStatement: String = ""
    
    init(drugName: String, maxDailyDosage:Int = 4, takenToday:Int = 0, timeTaken: Date = Date(), actionStatement: String = ""){
        self.drugName = drugName
        self.maxDailyDosage = maxDailyDosage
        self.takenToday = takenToday
        self.timeTaken = timeTaken
        self.actionStatement = actionStatement
    }
    
    func toDictionary()->[String:Any]{
        return [PillHistoryKeys.name: self.drugName, PillHistoryKeys.dailyDosageMax: self.maxDailyDosage, PillHistoryKeys.dailyDosage : self.takenToday, PillHistoryKeys.timeTaken: self.timeTaken]
    }
    
    init(dictionary: [String:Any]) {
        if let name = dictionary[PillHistoryKeys.name] as? String{
            self.drugName = name
        }
        if let maxDosage = dictionary[PillHistoryKeys.dailyDosageMax] as? Int{
            self.maxDailyDosage = maxDosage
        }
        if let dosage = dictionary[PillHistoryKeys.dailyDosage] as? Int{
            self.takenToday = dosage
        }
        if let timeTaken = dictionary[PillHistoryKeys.timeTaken] as? Date{
            self.timeTaken = timeTaken
        }
        if let actionStatment = dictionary[PillHistoryKeys.actionStatement] as? String{
            self.actionStatement = actionStatment
        }
    }
    
    
}

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
    var takenToday: Int = 1
    var timeTaken: Date = Date()
    var actionStatement: String = ""
    
    init(drugName: String, maxDailyDosage:Int = 4, todayDose: Int = 1, timeTaken: Date = Date(), actionStatement: String = "", calculateTodayDose:Bool = false){
        super.init()
        self.drugName = drugName
        self.maxDailyDosage = maxDailyDosage
        self.timeTaken = timeTaken
        self.takenToday = todayDose
        self.actionStatement = actionStatement
        if calculateTodayDose{
            self.takenToday = HistoryData.calculateTakenToday(drugName: self.drugName) + 1
        }
    }
    
    static func calculateTakenToday(drugName: String) -> Int{
        var similarPills = [HistoryData]()
        for pill in DataManager.shared().pillHistoryData {
            if pill.drugName.lowercased() == drugName.lowercased(){
                similarPills.append(pill)
            }
        }
        
        var sameDay = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        for history in similarPills{
            if dateFormatter.string(from: history.timeTaken) == dateFormatter.string(from: Date()){
                sameDay += 1
            }
        }
        return sameDay
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

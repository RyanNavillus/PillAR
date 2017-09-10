//
//  SinglePillViewController.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class SinglePillViewController: UIViewController {
    
    @IBOutlet weak var drugTitleLabel: UILabel!
    @IBOutlet weak var drugImageView: UIImageView!
    @IBOutlet weak var doseInformationLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    
    var historyEvents: [HistoryData] = [HistoryData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.allowsSelection = false
        historyTableView.separatorStyle = .none
        
        loadPillHistory()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.updateInfo()
        }
    }
    
    func updateInfo(){
        self.historyTableView.reloadData()
    }
    
    func initializeInfo(){
        loadPillHistory()
        HasuraAPIManager.shared().getLogoForDrug(drug: drugTitleLabel.text!) { (image) in
            self.drugImageView.image = image
            self.drugImageView.contentMode = .scaleAspectFit
        }
        
        var pillsTakenToday = 0
        for pill in self.historyEvents{
            if pill.timeTaken.daysBetweenDate(toDate: Date()) == 0{
                pillsTakenToday += 1
            }
        }
        
        var dailyDoseString = "Daily Dose: "
        var instructionsString = "Instructions: "
        HasuraAPIManager.shared().getUsageForDrug(drugTitleLabel.text!.lowercased()) { (result) in
            if let result = result{
                dailyDoseString.append("\(pillsTakenToday) pills taken / \(result.maximumDose) daily limit\n")
                if result.maximumDose == pillsTakenToday{
                    dailyDoseString.append("You should not take any more pills today\n")
                }else if result.maximumDose > pillsTakenToday{
                    let difference = result.maximumDose - pillsTakenToday
                    if difference == 1{
                        dailyDoseString.append("You can take up to \(difference) more pill1 today.\n")
                    }else{
                        dailyDoseString.append("You can take up to \(difference) more pills today.\n")
                    }
                }else{
                    let difference = pillsTakenToday - result.maximumDose
                    if difference == 1{
                    dailyDoseString.append("You have already taken \( difference) pill too many.  No more!\n")
                    }else{
                        dailyDoseString.append("You have already taken \( difference) pills too many.  No more!\n")  
                    }
                }
                instructionsString.append(result.instructions)
            }else{
                dailyDoseString.append("0\n")
                instructionsString.append("No instructions found 😩")
            }
            dailyDoseString.append("\(100 - self.historyEvents.count) more pills left in the bottle.")
            self.instructionsLabel.text = instructionsString
            self.doseInformationLabel.text = dailyDoseString
        }
        
        
    }
    
    func loadPillHistory(){
        historyEvents = [HistoryData]()
        for history in DataManager.shared().pillHistoryData{
            if history.drugName.lowercased() == drugTitleLabel.text!.lowercased(){
                historyEvents.append(history)
            }
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePillClicked(_ sender: Any) {
        if let pill = historyEvents.first{
            let pillName = pill.drugName
            let maxDose = pill.maxDailyDosage
            DataManager.shared().addPillHistory(drugName: pillName, maxDailyDosage: maxDose)
            loadPillHistory()
            initializeInfo()
            UIView.transition(with: self.historyTableView,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: { self.historyTableView.reloadData() })
        }
    }
}

extension SinglePillViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SingleHistoryCell", for: indexPath) as? SingleHistoryTableViewCell {
            let data = historyEvents[indexPath.row]
            cell.fullTextLabel.text = "\(data.timeTaken.timestringFromNow()) | Pill #\(data.takenToday) of the day"
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "none")!
        }
    }
    
    
    
}

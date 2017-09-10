//
//  PillListViewController.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

struct PillKeys {
    static let allTakenInstances = "AllTaken"
    static let pillName = "PillName"
    static let lastTaken = "LastTaken"
    static let dailyDose = "DailyDose"
    static let dailyDoseString = "DailyDoseString"
}

class PillListViewController: UIViewController {
    
    @IBOutlet weak var pillListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pillListTableView.separatorStyle = .none
        pillListTableView.delegate = self
        pillListTableView.dataSource = self
        
        // Do any additional setup after loading the view.
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
//            self.updateInfo()
//        }
        self.updateInfo()
    }
    
    var pillInfo:[[String: Any]] = [[String: Any]]()
    
    
    func reloadPillList(){
        pillInfo = [[String:Any]]()
        var pillTakenLists = [String:[HistoryData]]()
        for pill in DataManager.shared().pillHistoryData{
            if pillTakenLists[pill.drugName.lowercased()] != nil{
                pillTakenLists[pill.drugName.lowercased()]?.append(pill)
            }else{
                pillTakenLists[pill.drugName.lowercased()] = [pill]
            }
        }
        
        for (_, pillList) in pillTakenLists{
            var minDate:Date? = nil
            var minPill: HistoryData? = nil
            for pill in pillList{
                if minDate != nil, minPill != nil{
                    if pill.timeTaken > minDate!{
                        minDate = pill.timeTaken
                        minPill = pill
                    }
                }else{
                    minDate = pill.timeTaken
                    minPill = pill
                }
            }
            var specificPillInfo = [String: Any]()
            specificPillInfo[PillKeys.pillName] = minPill!.drugName
            specificPillInfo[PillKeys.lastTaken] = minPill!
            specificPillInfo[PillKeys.dailyDose] = minPill!.maxDailyDosage
            specificPillInfo[PillKeys.allTakenInstances] = pillList
            pillInfo.append(specificPillInfo)
        }
    }
    
    func updateInfo(){
        reloadPillList()
        self.pillListTableView.reloadData()
    }
    
    
    
}

extension PillListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pillInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AllPillListCell", for: indexPath) as? AllPillListTableViewCell {
            let data = pillInfo[indexPath.row]
            cell.selectionStyle = .none
            if let cellTitle = data[PillKeys.pillName] as? String{
                cell.pillTitleLabel.text = cellTitle
                HasuraAPIManager.shared().getLogoForDrug(drug: cellTitle, completionHandler: { (image) in
                    cell.pillImageView.image = image
                })
            }
            if let lastTakenPill = data[PillKeys.lastTaken] as? HistoryData{
                var lastTakenString = "Last Taken: " + lastTakenPill.timeTaken.timestringFromNow()
                cell.lastTakenLabel.text = lastTakenString
            }
            cell.takePillButton.tag = indexPath.row
            cell.takePillButton.addTarget(self, action: #selector(PillListViewController.takePill(sender:)), for: .touchUpInside)
            if let allPillsTaken = data[PillKeys.allTakenInstances] as? [HistoryData]{
                var pillsTakenPast24 = 0
                //Past 24 hours
                for pill in allPillsTaken{
                    if pill.timeTaken.daysBetweenDate(toDate: Date()) == 0{
                        pillsTakenPast24 += 1
                    }
                }
                let pillsTakenToday = HistoryData.calculateTakenToday(drugName: (data[PillKeys.pillName] as! String).lowercased())
                
                var dailyDoseString = "Daily Dose: "
                HasuraAPIManager.shared().getUsageForDrug(data[PillKeys.pillName] as! String) { (result) in
                    if let result = result{
                        dailyDoseString.append("\(pillsTakenToday) pills taken / \(result.maximumDose) daily limit\n")
                        dailyDoseString.append("Past 24 Hours: \(pillsTakenPast24) Pills Taken\n")
                        if result.maximumDose == pillsTakenToday{
                            dailyDoseString.append("You should not take any more pills today\n")
                        }else if result.maximumDose > pillsTakenToday{
                            let difference = result.maximumDose - pillsTakenToday
                            if difference == 1{
                                dailyDoseString.append("You can take up to \(difference) more pill today.\n")
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
                    }else{
                        dailyDoseString.append("0\n")
                    }
                    dailyDoseString.append("\(100 - allPillsTaken.count) more pills left in the bottle.")
                    cell.dailyDoseLabel.text = dailyDoseString
                }
            }
            
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "null")!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = pillInfo[indexPath.row]
        if let singlePillVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SinglePillVC") as? SinglePillViewController,  let pillName = data[PillKeys.pillName] as? String{
            singlePillVC.view.frame = UIScreen.main.bounds
            singlePillVC.drugTitleLabel.text = pillName.capitalized
            singlePillVC.initializeInfo()
            self.present(singlePillVC, animated: true, completion: nil)
        }
    }
    
    func takePill(sender:UIButton){
        let data = pillInfo[sender.tag]
        if let lastTaken = data[PillKeys.lastTaken] as? HistoryData, let pillName = data[PillKeys.pillName] as? String{
            let maxDose = lastTaken.maxDailyDosage
            DataManager.shared().addPillHistory(drugName: pillName, maxDailyDosage: maxDose)
            self.updateInfo()
            
            UIView.transition(with: self.pillListTableView,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: { self.updateInfo()
                                self.pillListTableView.reloadData() })
            
        }
    }
    
}

//
//  AllHistoryViewController.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class AllHistoryViewController: UIViewController {
    
    var historyDosages = Array<HistoryData>()
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
        
        //TODO: - add more mock data for history
        historyDosages.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 0, timeTaken: dateFormatter.date(from: "09-09-2017 2:15:11 EST")!))
        historyDosages.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 0, timeTaken: dateFormatter.date(from: "09-09-2017 2:15:11 EST")!))
        historyDosages.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 0, timeTaken: dateFormatter.date(from: "09-09-2017 2:15:11 EST")!))
        historyDosages.append(HistoryData(drugName: "Zyrtec", maxDailyDosage: 5, takenToday: 0, timeTaken: dateFormatter.date(from: "09-09-2017 8:15:11 EST")!))
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.976, alpha: 1.00)
        self.tableView.backgroundColor = nil
        let line = UIView(frame: CGRect(x: 191, y: 0, width: 10, height: self.view.frame.height))
        line.backgroundColor = UIColor(red: 0.867, green: 0.878, blue: 0.918, alpha: 1.00)
        self.view.insertSubview(line, belowSubview: tableView)
    }
}

extension AllHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyDosages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell{
            cell.backgroundColor = nil
            cell.selectionStyle = .none
            let data = historyDosages[indexPath.row]
            cell.drugNameLabel.text = data.drugName
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "h:m a"
            let time = dateformatter.string(from: data.timeTaken)
            dateformatter.dateFormat = "E MMM d yyyy"
            let date = dateformatter.string(from: data.timeTaken)
            cell.timestampLabel.text = "\(time)\n\(date)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
            
            cell.detailTimeTakenLabel.text = timestringFrom(date: data.timeTaken)
            cell.descriptionLabel.text = "\(data.takenToday) / \(data.maxDailyDosage) pills taken today"
            if data.takenToday < data.maxDailyDosage{
                let numberToTake = data.maxDailyDosage - data.takenToday
                cell.actionLabel.text = "\(numberToTake) MORE TO TAKE TODAY"
            }else if data.takenToday == data.maxDailyDosage{
                cell.actionLabel.text = "You are all set with your \(data.drugName) today"
            }else if data.takenToday > data.maxDailyDosage{
                let numberToTake = data.takenToday - data.maxDailyDosage
                cell.actionLabel.text = "YOU TOOK \(numberToTake) TOO MANY TODAY"
            }
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "NullCell")!
        }
    }
    
    func timestringFrom(date:Date)-> String{
        let now = Date()
        if now.days(from: date) > 0 {
            return "\(now.days(from: date)) days ago"
        }
        if now.hours(from: date) > 0 {
            return "\(now.hours(from: date)) hours ago"
        }
        if now.minutes(from: date) > 0 {
            return "\(now.minutes(from: date)) minutes ago"
        }
        if now.seconds(from: date) > 0 {
            return "\(now.seconds(from: date)) days ago"
        }
        return ""
    }
    
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}


//
//  AllHistoryViewController.swift
//  PillAR
//
//  Created by Avery Lamp on 9/9/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class AllHistoryViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        header.backgroundColor = nil
        tableView.tableHeaderView = header
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.976, alpha: 1.00)
        self.tableView.backgroundColor = nil
        let line = UIView(frame: CGRect(x: 189, y: 0, width: 8, height: self.view.frame.height))
        line.backgroundColor = UIColor(red: 0.867, green: 0.878, blue: 0.918, alpha: 1.00)
        self.view.insertSubview(line, belowSubview: tableView)
        
        NotificationCenter.default.addObserver(forName: pillTakenUpdateNotification, object: nil, queue: nil) { (notification) in
            self.tableView.reloadData()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.updateInfo()
        }
        
    }
    
    func updateInfo(){
        self.tableView.reloadData()
    }
}

extension AllHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared().pillHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell{
            cell.backgroundColor = nil
            cell.selectionStyle = .none
            let data = DataManager.shared().pillHistoryData[indexPath.row]
            cell.drugNameLabel.text = data.drugName
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "h:m a"
            let time = dateformatter.string(from: data.timeTaken)
            dateformatter.dateFormat = "E MMM d yyyy"
            let date = dateformatter.string(from: data.timeTaken)
            cell.timestampLabel.text = "\(time)\n\(date)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
            
            cell.detailTimeTakenLabel.text =  data.timeTaken.timestringFromNow()
            cell.descriptionLabel.text = "\(data.takenToday) / \(data.maxDailyDosage) pills taken today"
            if data.takenToday < data.maxDailyDosage{
                let numberToTake = data.maxDailyDosage - data.takenToday
                cell.actionLabel.text = "\(numberToTake) more to take today"
            }else if data.takenToday == data.maxDailyDosage{
                cell.actionLabel.text = "You are all set with your \(data.drugName) today"
            }else if data.takenToday > data.maxDailyDosage{
                let numberToTake = data.takenToday - data.maxDailyDosage
                cell.actionLabel.text = "you took \(numberToTake) too many today!!"
            }
            if data.actionStatement != ""{
                cell.actionLabel.text = data.actionStatement
            }
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "NullCell")!
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = DataManager.shared().pillHistoryData[indexPath.row]
        if let singlePillVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SinglePillVC") as? SinglePillViewController{
            singlePillVC.view.frame = UIScreen.main.bounds
           singlePillVC.drugTitleLabel.text = data.drugName.capitalized
            singlePillVC.initializeInfo()
           self.present(singlePillVC, animated: true, completion: nil)
        }
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
    
    
    func timestringFromNow()-> String{
        let now = Date()
        if now.days(from: self) > 0 {
            return "\(now.days(from: self)) days ago"
        }
        if now.hours(from: self) > 0 {
            return "\(now.hours(from: self)) hours ago"
        }
        if now.minutes(from: self) > 0 {
            return "\(now.minutes(from: self)) minutes ago"
        }
        if now.seconds(from: self) > 0 {
            return "\(now.seconds(from: self)) seconds ago"
        }
        return "Just taken"
    }
}



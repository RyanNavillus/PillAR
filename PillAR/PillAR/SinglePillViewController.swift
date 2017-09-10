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

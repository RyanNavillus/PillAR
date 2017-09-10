//
//  ViewController.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/8/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

let pillTakenUpdateNotification = Notification.Name("PillTakenNotification")
let toggleHistoryNotification = Notification.Name("ToggleHistoryNotification")
let toggleHistoryActionNotification = Notification.Name("ToggleHistoryActionNotification")

class MainHistoryViewController: UIViewController {

    @IBOutlet weak var topSharedView: UIView!
    @IBOutlet weak var lastPillLabel: UILabel!
    @IBOutlet weak var lastPillTimeLabel: UILabel!
    @IBOutlet weak var toggleHistoryButton: UIButton!
    @IBOutlet weak var toggleHistoryArrowImage: UIImageView!
    
    
    
    @IBOutlet weak var subsectionView: UIView!
    var historyTableVC:AllHistoryViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.topSharedView.layer.shadowColor = UIColor(white: 0.3, alpha: 1.0).cgColor
        
        if let historyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryTableVC") as? AllHistoryViewController{
               historyTableVC = historyVC
            historyVC.view.frame = CGRect(x: 0, y: 0, width: subsectionView.frame.size.width, height: subsectionView.frame.size.height)
            self.addChildViewController(historyVC)
            self.subsectionView.addSubview(historyVC.view)
            historyVC.didMove(toParentViewController: self)
        }
        
        refreshLastPillTaken()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainHistoryViewController.refreshLastPillTaken), name: pillTakenUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(forName: toggleHistoryNotification, object: nil, queue: nil) { (notification) in
            UIView.transition(with: self.toggleHistoryArrowImage, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if DataManager.shared().historyState == .Visible{
                    self.toggleHistoryArrowImage.image = #imageLiteral(resourceName: "downArrow")
                }else{
                    self.toggleHistoryArrowImage.image = #imageLiteral(resourceName: "upArrow")
                }
            }, completion: nil)
            UIView.transition(with: self.toggleHistoryButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if DataManager.shared().historyState == .Visible{
                    self.toggleHistoryButton.setTitle("Scan Pills", for: .normal)
                }else{
                    self.toggleHistoryButton.setTitle("View Complete History", for: .normal)
                }
            }, completion: nil)
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.updateInfo()
        }
    }
    
    func updateInfo(){
        refreshLastPillTaken()
    }
    
    func refreshLastPillTaken(){
        let lastPill = DataManager.shared().pillHistoryData.first!
        lastPillLabel.text = "Last Pill Taken: \(lastPill.drugName)"
        lastPillTimeLabel.text = "\(lastPill.timeTaken.timestringFromNow())"
    }
    
    @IBAction func toggleHistoryButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: toggleHistoryActionNotification, object: nil)
    }
    
}


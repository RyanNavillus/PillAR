//
//  ViewController.swift
//  PillAR
//
//  Created by Ryan Sullivan on 9/8/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var subsectionView: UIView!
    var historyTableVC:AllHistoryViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        if let historyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryTableVC") as? AllHistoryViewController{
               historyTableVC = historyVC
            historyVC.view.frame = CGRect(x: 0, y: 0, width: subsectionView.frame.size.width, height: subsectionView.frame.size.height)
            self.addChildViewController(historyVC)
            self.subsectionView.addSubview(historyVC.view)
            historyVC.didMove(toParentViewController: self)
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


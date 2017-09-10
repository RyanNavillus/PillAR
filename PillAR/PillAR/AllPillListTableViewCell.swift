//
//  AllPillListTableViewCell.swift
//  PillAR
//
//  Created by Avery Lamp on 9/10/17.
//  Copyright © 2017 Ryan Sullivan. All rights reserved.
//

import UIKit

class AllPillListTableViewCell: UITableViewCell {

    @IBOutlet weak var pillImageView: UIImageView!
    @IBOutlet weak var pillTitleLabel: UILabel!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var dailyDoseLabel: UILabel!
    @IBOutlet weak var takePillButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

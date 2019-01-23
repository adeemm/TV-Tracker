//
//  CalendarCell.swift
//  TV Tracker
//
//  Created by Adeem on 1/7/19.
//  Copyright © 2019 Adeem. All rights reserved.
//

import UIKit

class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateHighlight: UIView!
    @IBOutlet weak var eventDot: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

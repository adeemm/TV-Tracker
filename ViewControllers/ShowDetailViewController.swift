//
//  ShowDetailViewController.swift
//  TV Tracker
//
//  Created by Adeem on 11/2/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit

class ShowDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var premiereLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    
    var showInfo:Show?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let poster = showInfo?.tvdb?.poster {
            posterImageView.image = UIImage(data: poster)
        }
        else {
            posterImageView.image = UIImage(named: "poster-placeholder")
        }
        
        
        if let background = showInfo?.tvdb?.background {
            bgImageView.image = UIImage(data: background)
        }
        else {
            bgImageView.image = UIImage(named: "background-placeholder")
        }
        
        
        var hour = ""
        if let time = showInfo?.schedule?.time {
            if let convertedHour = convertTimeFormat(time: time) {
                hour = convertedHour + " "
            }
        }
        
        if let network = showInfo?.network?.name {
            if let days = showInfo?.schedule?.days?.joined(separator: ", ") {
                scheduleLabel.text = hour + days + "s on " + network
            }
            else {
                scheduleLabel.text = hour + " on " + network
            }
        }
        else if let network = showInfo?.web?.name {
            scheduleLabel.text = "Airs on " + network
        }
        
        
        if let summary = showInfo?.summary {
            descriptionTitleLabel.isHidden = false
            summaryTextView.text = stripHTML(input: summary)
            summaryTextView.contentOffset = .zero
        }
        
        
        if let status = showInfo?.status {
            statusLabel.text = "Status: " + status
        }
        
        
        if let premiere = showInfo?.premiere {
            premiereLabel.text = "Premiered: " + premiere
        }
        
        
        showLabel.text = showInfo?.title
    }
}

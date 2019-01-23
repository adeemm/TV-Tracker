//
//  CalendarViewController.swift
//  TV Tracker
//
//  Created by Adeem on 10/26/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showScheduleLabel: UILabel!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var eventStackView: UIStackView!
    @IBOutlet weak var gadBanner: GADBannerView!
    
    // Colors cached to improve performance
    let whiteColor = UIColor.white
    let iceColor = UIColor(red:0.81, green:0.87, blue:0.94, alpha:1.0)
    let accentColor = UIColor(red:1.00, green:0.20, blue:0.49, alpha:1.0)
    let lightColor = UIColor(red:0.43, green:0.50, blue:0.80, alpha:1.0)
    let darkBlueColor = UIColor(red:0.13, green:0.19, blue:0.47, alpha:1.0)
    let navyBlueColor = UIColor(red:0.06, green:0.10, blue:0.32, alpha:1.0)
    
    // Fonts also cached to improve performance
    let episodeHeaderFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    let episodeDescriptionFont = UIFont.systemFont(ofSize: 14)
    
    // Holds all episodes on the calendar
    var calendarEpisodes = [Episode]()
    
    // Dictionary used for its faster lookup time (generally has O(1) lookup time, while unsorted array takes O(n) time)
    var episodeDateDict: Dictionary = [Date:[Episode]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.bool(forKey: "removeAds")) {
            gadBanner.isHidden = true
        }
        else {
            gadBanner.adUnitID = "AD-ID"
            gadBanner.rootViewController = self
            gadBanner.adSize = kGADAdSizeSmartBannerPortrait
            gadBanner.load(GADRequest())
        }
        
        self.calendarView.calendarDataSource = self;
        self.calendarView.calendarDelegate = self;
        self.calendarView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCell")
        
        self.calendarView.minimumLineSpacing = 0
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.selectDates([Date()])
        updateCalendarHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadEpisodes()
        
        if (UserDefaults.standard.bool(forKey: "removeAds")) {
            gadBanner.isHidden = true
        }
        
        if let selectedDate = self.calendarView.selectedDates.first {
            episodeDateDict[selectedDate] = getEpisodesOnDate(episodes: calendarEpisodes, date: selectedDate)
            updateEventDisplay(date: selectedDate)
        }
        
        calendarView.reloadData()
    }
    
    func handleCellState(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {
            return
        }
        
        cell.dateLabel.text = cellState.text
        
        cell.dateHighlight.isHidden = cellState.isSelected ? false : true
        
        cell.dateLabel.textColor = (cellState.dateBelongsTo == .thisMonth || cellState.isSelected) ? whiteColor : lightColor
        
        if let episodes = episodeDateDict[cellState.date] {
            if episodes.count >= 3 {
                cell.eventDot.text = String(repeating: ".", count: 3)
            }
            else {
                cell.eventDot.text = String(repeating: ".", count: episodes.count)
            }
        }
        else {
            let episodes = getEpisodesOnDate(episodes: calendarEpisodes, date: cellState.date)
            if episodes.count != 0 {
                episodeDateDict[cellState.date] = episodes
            }
            
            if episodes.count >= 3 {
                cell.eventDot.text = String(repeating: ".", count: 3)
            }
            else {
                cell.eventDot.text = String(repeating: ".", count: episodes.count)
            }
        }
    }
    
    func updateCalendarHeader() {
        formatter.dateFormat = "MMMM  yyyy"
        let displayedDate = self.calendarView?.visibleDates().monthDates.first?.date
        titleLabel.text = formatter.string(from: displayedDate ?? Date()).uppercased()
    }
    
    func loadEpisodes() {
        let navController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        let homeVC = navController.viewControllers[0] as! HomeViewController
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        calendarEpisodes.removeAll()
        episodeDateDict.removeAll()
        
        for cell in homeVC.showCells {
            let validEpisodes = getEpisodesAfterDate(episodes: cell.showStrct.episodes ?? [Episode](), date: startDate)
            calendarEpisodes.append(contentsOf: validEpisodes)
        }
    }
    
    func updateEventDisplay(date: Date) {
        eventStackView.subviews.forEach({ $0.removeFromSuperview() })
        showScheduleLabel.isHidden = true
        
        if let episodes = episodeDateDict[date] {
            for episode in episodes {
                createEpisodeEventView(episode: episode)
            }
        }
    }
    
    func createEpisodeEventView(episode: Episode) {
        formatter.dateFormat = "MMMM d, yyyy"
        
        let dateLabel = UILabel()
        if let airtime = episode.airtime {
            dateLabel.text = formatter.string(from: episode.convertedAirdate!) + " - " + (convertTimeFormat(time: airtime) ?? "(online)")
        }
        else {
            dateLabel.text = formatter.string(from: episode.convertedAirdate!)
        }
        dateLabel.textColor = lightColor
        dateLabel.font = episodeDescriptionFont
        
        let eventTitleLabel = UILabel()
        if let parentShow = episode.parentShow, let season = episode.season, let number = episode.number {
            eventTitleLabel.text = parentShow + " " + String(season) + "x" + String(number) + " - " + episode.title
        }
        else {
            eventTitleLabel.text = episode.title
        }
        eventTitleLabel.textColor = whiteColor
        eventTitleLabel.font = episodeHeaderFont
        eventTitleLabel.sizeToFit()
        eventTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let eventDescLabel = UILabel()
        eventDescLabel.text = stripHTML(input: episode.summary ?? "")
        eventDescLabel.textColor = iceColor
        eventDescLabel.font = dateLabel.font.withSize(12)
        eventDescLabel.lineBreakMode = .byWordWrapping
        eventDescLabel.numberOfLines = 0
        eventDescLabel.sizeToFit()
        eventDescLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let episodeEventView = UIView()
        episodeEventView.backgroundColor = lightColor.withAlphaComponent(0.25)
        episodeEventView.layer.cornerRadius = 10
        episodeEventView.translatesAutoresizingMaskIntoConstraints = false
        episodeEventView.addSubview(eventTitleLabel)
        episodeEventView.addSubview(eventDescLabel)
        
        episodeEventView.addConstraint(NSLayoutConstraint(item: eventDescLabel, attribute: .leading, relatedBy: .equal, toItem: episodeEventView, attribute: .leading, multiplier: 1, constant: 8))
        episodeEventView.addConstraint(NSLayoutConstraint(item: episodeEventView, attribute: .trailing, relatedBy: .equal, toItem: eventDescLabel, attribute: .trailing, multiplier: 1, constant: 8))
        episodeEventView.addConstraint(NSLayoutConstraint(item: eventDescLabel, attribute: .top, relatedBy: .equal, toItem: eventTitleLabel, attribute: .bottom, multiplier: 1, constant: 2))
        episodeEventView.addConstraint(NSLayoutConstraint(item: episodeEventView, attribute: .bottom, relatedBy: .equal, toItem: eventDescLabel, attribute: .bottom, multiplier: 1, constant: 8))
        episodeEventView.addConstraint(NSLayoutConstraint(item: eventTitleLabel, attribute: .leading, relatedBy: .equal, toItem: eventDescLabel, attribute: .leading, multiplier: 1, constant: 0))
        episodeEventView.addConstraint(NSLayoutConstraint(item: eventTitleLabel, attribute: .top, relatedBy: .equal, toItem: episodeEventView, attribute: .top, multiplier: 1, constant: 8))
        
        eventStackView.addArrangedSubview(dateLabel)
        eventStackView.addArrangedSubview(episodeEventView)
        showScheduleLabel.isHidden = false
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendarView.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        handleCellState(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        handleCellState(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellState(cell: cell, cellState: cellState)
        updateEventDisplay(date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellState(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        updateCalendarHeader()
    }
    
    @IBAction func leftArrowClicked(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    
    
    @IBAction func rightArrowClicked(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
}

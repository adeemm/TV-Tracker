//
//  HomeViewController.swift
//  TV Tracker
//
//  Created by Adeem on 10/26/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableDelegate {
    
    @IBOutlet weak var showTableView: UITableView!
    @IBOutlet weak var gadBanner: GADBannerView!
    
    
    let refreshControl = UIRefreshControl()
    
    var showCells = [CellData]()
    var selectedShow: Show?
    
    
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
        
        self.showTableView.delegate = self
        self.showTableView.dataSource = self
        self.showTableView.register(UINib(nibName: "ShowCell", bundle: nil), forCellReuseIdentifier: "ShowCell")

        if let shows = decodeShows(fileName: "shows.json") {
            for show in shows {
                // Value should always exist, but unwrapped safely just in case to prevent a crash
                if let banner = show.tvdb?.banner {
                    showCells.append(CellData.init(bannerImage: UIImage(data: banner), showStrct: show))
                }
            }
        }
        
        if #available(iOS 10.0, *) {
            showTableView.refreshControl = refreshControl
        }
        else {
            showTableView.addSubview(refreshControl)
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Shows...")
        refreshControl.addTarget(self, action: #selector(self.refreshShows), for: .valueChanged)
        refreshShows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "removeAds")) {
            gadBanner.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.showTableView.reloadData()
        }
    }
    
    func addShowToTable(banner: Data, show: Show) {
            showCells.append(CellData.init(bannerImage: UIImage(data: banner), showStrct: show))

            showTableView.beginUpdates()
            showTableView.insertRows(at: [IndexPath(row: showCells.count-1, section: 0)], with: .automatic)
            showTableView.endUpdates()
    }
    
    @objc func refreshShows() {
        DispatchQueue.global(qos:.userInteractive).async {
            var updatedCells = [CellData]()
            
            for cell in self.showCells {
                let images = cell.showStrct.tvdb
                
                if var updatedShow = getShow(id: cell.showStrct.id) {
                    let updatedEpisodes = getEpisodes(show: updatedShow)
                    updatedShow.episodes = updatedEpisodes
                    updatedShow.tvdb = images
                    
                    // Value should always exist, but unwrapped safely just in case to prevent a crash
                    if let banner = images?.banner {
                        updatedCells.append(CellData.init(bannerImage: UIImage(data: banner), showStrct: updatedShow))
                    }
                }
            }

            self.showCells = updatedCells
            
            DispatchQueue.main.async {
                self.showTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Back"
        navigationItem.backBarButtonItem = backButtonItem
        
        if segue.identifier == "searchSegue" {
            let searchVC = segue.destination as! ShowSearchViewController
            searchVC.delegate = self
        }
        else if segue.identifier == "detailSegue" {
            let detailVC = segue.destination as! ShowDetailViewController
            detailVC.showInfo = selectedShow
            detailVC.title = selectedShow?.title
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedShow = showCells[indexPath.row].showStrct
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.showTableView.dequeueReusableCell(withIdentifier: "ShowCell") as! ShowCell
        cell.setBanner(image: showCells[indexPath.row].bannerImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 0.185
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            showCells.remove(at: indexPath.row)
            
            showTableView.beginUpdates()
            showTableView.deleteRows(at: [indexPath], with: .automatic)
            showTableView.endUpdates()
        }
    }
}

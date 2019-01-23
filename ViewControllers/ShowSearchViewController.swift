//
//  ShowSearchViewController.swift
//  TV Tracker
//
//  Created by Adeem on 10/30/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit

class ShowSearchViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var showSearchBar: UISearchBar!
    @IBOutlet var searchResultsTable: UITableView!
    
    var showName = ""
    var delegate: TableDelegate?
    var searchCells = [SearchCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSearchBar.delegate = self
        self.searchResultsTable.delegate = self
        self.searchResultsTable.dataSource = self
        
        self.searchResultsTable.register(UITableViewCell.self, forCellReuseIdentifier: "searchCellID")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellID")!
        cell.textLabel?.text = searchCells[indexPath.row].show.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indicator = showActivityIndicatory(uiView: self.view)
        
        DispatchQueue.global(qos:.userInteractive).async {
            var currentShow = self.searchCells[indexPath.row].show
            currentShow.episodes = getEpisodes(show: currentShow)
            
            if let showID = currentShow.extern?.thetvdb {
                if let images = getImages(id: showID) {
                    addShowImages(show: &currentShow, images: images)
                    self.searchCells[indexPath.row].show = currentShow
                }
            }
            
            DispatchQueue.main.async {
                if let banner = currentShow.tvdb?.banner {
                    self.delegate?.addShowToTable(banner: banner, show: currentShow)
                }
                else {
                    if let imageData = checkImages(show: currentShow) {
                        // Use cropped poster image for the banner
                        if let image = UIImage(data: imageData) {
                            let imageWidth = Int(image.size.width)
                            let imageHeight = Int(image.size.height)
                            let croppedWidth = 758
                            let croppedHeight = 140
                            let origin = CGPoint(x: (imageWidth - croppedWidth)/2, y: (imageHeight - croppedHeight)/4)
                            let size = CGSize(width: croppedWidth, height: croppedHeight)
                            var rect = CGRect(origin: origin, size: size)
                            
                            if let croppedImage = cropImage(image: image, rect: &rect) {
                                // Set TVDB struct so detail view displays properly
                                var tvdbStruct = TVDB()
                                tvdbStruct.banner = croppedImage
                                tvdbStruct.poster = imageData
                                currentShow.tvdb = tvdbStruct
                                
                                self.delegate?.addShowToTable(banner: croppedImage, show: currentShow)
                            }
                        }
                        // Use placeholder banner image
                        else {
                            if let bannerImageData = UIImage(named: "placeholder-banner")?.pngData() {
                                self.delegate?.addShowToTable(banner: bannerImageData, show: currentShow)
                            }
                        }
                    }
                }
                
                indicator.stopAnimating()
                indicator.superview?.removeFromSuperview()
                
                self.searchResultsTable.deselectRow(at: indexPath, animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        showName = searchText
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchShow), object: nil)
        self.perform(#selector(self.searchShow), with: nil, afterDelay: 0.5)
    }
    
    @objc func searchShow() {
        getSearchResults(query: showName) { (results) in
            self.searchCells.removeAll()
            
            for result in results {
                self.searchCells.append(SearchCellData.init(show: result.show))
            }
            
            DispatchQueue.main.async {
                self.searchResultsTable.reloadData()
            }
        }
    }
    
    func showActivityIndicatory(uiView: UIView) -> UIActivityIndicatorView {
        uiView.endEditing(true)
        
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 80, height: 80))
        loadingView.center = CGPoint(x: uiView.center.x, y: uiView.center.y / 1.5)
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 40, height: 40))
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
}

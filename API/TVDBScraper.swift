//
//  TVDBScraper.swift
//  TV Tracker
//
//  Created by Adeem on 10/29/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import Foundation

// Scrapes TVDB page for different show images
func getImages(id: Int) -> [String:Data]? {
    
    //let urlString = "https://www.thetvdb.com/?tab=series&id=" + String(id)
    let urlString = "https://www.thetvdb.com/dereferrer/series/" + String(id)
    
    guard let myURL = URL(string: urlString) else {
        print("Error: invalid series URL")
        return nil
    }
    
    do {
        let htmlString = try String(contentsOf: myURL, encoding: .ascii)
        var images: Dictionary = [String:Data]()
        let titles = ["Backgrounds", "Banners", "Posters"]
        
        for title in titles {
            var source = htmlString
            
            if let occurence = source.range(of: title) {
                source.removeSubrange(source.startIndex...occurence.lowerBound)
                
                let pattern = #"<img\s.*?src=(?:'|")([^'">]+)(?:'|")"#
                let group = regexCapture(pattern: pattern, text: source, group: 1)
                
                if let first = group.first {
                    if let imageURL = URL(string: first) {
                        if let image = downloadImage(url: imageURL) {
                            images[title] = image
                        }
                    }
                }
            }
        }
        return images
    }
    catch let error {
        print("Error: \(error)")
        return nil
    }
}

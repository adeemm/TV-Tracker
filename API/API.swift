//
//  API.swift
//  TV Tracker
//
//  Created by Adeem on 11/9/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import Foundation
import UIKit

let formatter = DateFormatter()

// Remove unrecognized characters before performing API request
func cleanURL(input: String) -> String {
    return input.replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "\'", with: "")
}

// Change URL protocol to HTTPS
func changeScheme(input: URL) -> URL? {
    var components = URLComponents(url: input, resolvingAgainstBaseURL: false)!
    components.scheme = "https"
    return components.url
}

// Remove HTML from show descriptions
func stripHTML(input: String) -> String {
    return input.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
}

// Download image data from a given URL
func downloadImage(url: URL) -> Data? {
    let bannerData = try? Data(contentsOf: changeScheme(input: url)!)
    return bannerData
}

// Add image dict to show struct
func addShowImages(show: inout Show, images: [String:Data]) {
    var tvdbStruct = TVDB()
    
    if let background = images["Backgrounds"] {
        tvdbStruct.background = background
    }
    if let banner = images["Banners"] {
        tvdbStruct.banner = banner
    }
    if let poster = images["Posters"] {
        tvdbStruct.poster = poster
    }
    
    show.tvdb = tvdbStruct
}

// Check images to determine the backup banner image
func checkImages(show: Show) -> Data? {
    if let poster = show.tvdb?.poster {
        return poster
    }
    if let tvmazeOriginal = show.images?.original {
        return downloadImage(url: tvmazeOriginal)
    }
    if let tvmazeMedium = show.images?.medium {
        return downloadImage(url: tvmazeMedium)
    }
    return nil
}

// Used to crop a larger poster image if no banner is found
func cropImage(image: UIImage, rect: inout CGRect) -> Data? {
    rect.origin.x *= image.scale
    rect.origin.y *= image.scale
    rect.size.width *= image.scale
    rect.size.height *= image.scale
    
    if let cropped = image.cgImage?.cropping(to: rect) {
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation).pngData()
    }
    
    return nil
}

// Convert 24 hr time to 12 hr format
func convertTimeFormat(time: String) -> String? {
    formatter.dateFormat = "HH:mm"
    
    if let convertedDate = formatter.date(from: time) {
        formatter.dateFormat = "h:mma"
        return formatter.string(from: convertedDate)
    }
    return nil
}

// Return show's epsiodes airing after date
func getEpisodesAfterDate(episodes: [Episode], date: Date) -> [Episode] {
    var outArray = [Episode]()
    
    for episode in episodes {
        if let convertedAirdate = episode.convertedAirdate {
            if convertedAirdate > date {
                outArray.append(episode)
            }
        }
    }
    
    return outArray
}

// Return show's episodes airing on date
func getEpisodesOnDate(episodes: [Episode], date: Date) -> [Episode] {
    var outArray = [Episode]()
    
    for episode in episodes {
        if let convertedAirdate = episode.convertedAirdate {
            if convertedAirdate == date {
                outArray.append(episode)
            }
        }
    }
    
    return outArray
}

// Return app's document directory
func getDocumentDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

// Save shows into JSON file
func encodeShows(shows: [Show], fileName: String) {
    let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
    
    let encoder = JSONEncoder()
    do {
        if let data = try? encoder.encode(shows) {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        }
    }
    catch {
        print(error)
    }
}

// Load shows from JSON file
func decodeShows(fileName: String) -> [Show]? {
    let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
    
    if !FileManager.default.fileExists(atPath: url.path) {
        print("File at \(url.path) does not exist")
        return nil
    }
    
    if let data = FileManager.default.contents(atPath: url.path) {
        let decoder = JSONDecoder()
        if let shows = try? decoder.decode([Show].self, from: data) {
            return shows
        }
    }
    else {
        print("No data at \(url.path)")
    }
    return nil
}

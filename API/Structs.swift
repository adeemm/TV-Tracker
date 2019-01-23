//
//  Structs.swift
//  TV Tracker
//
//  Created by Adeem on 1/14/19.
//  Copyright © 2019 Adeem. All rights reserved.
//

import Foundation
import UIKit

// CellData struct to hold cells in home tableview
struct CellData {
    let bannerImage: UIImage?
    let showStrct: Show
}

// Struct to hold search results from API
struct SearchCellData {
    var show: Show
}

// Base struct for API response format
struct Base: Codable {
    var show: Show
}

struct Show: Codable {
    let id: Int
    let title: String
    let images: Images?
    let summary: String?
    let status: String
    let premiere: String?
    let schedule: Schedule?
    let network: Network?
    let web: WebChannel?
    let extern: Externals?
    var episodes: [Episode]?
    var tvdb: TVDB?
    
    enum CodingKeys : String, CodingKey {
        case id
        case title = "name"
        case images = "image"
        case summary
        case status
        case premiere = "premiered"
        case schedule
        case network
        case web = "webChannel"
        case extern = "externals"
        case episodes
        case tvdb
    }
}

struct Images: Codable {
    let medium: URL?
    let original: URL?
}

struct Schedule: Codable {
    let time: String?
    let days: [String]?
}

struct Network: Codable {
    let name: String?
}

struct WebChannel: Codable {
    let name: String?
}

struct Externals: Codable {
    let thetvdb: Int?
}


// Response from API episode endpoint
struct Episode: Codable {
    let id: Int
    let title: String
    let season: Int?
    let number: Int?
    let summary: String?
    let airdate: String
    let airtime: String?
    var parentShow: String?
    var convertedAirdate: Date?
    
    enum CodingKeys : String, CodingKey {
        case id
        case title = "name"
        case season
        case number
        case summary
        case airdate
        case airtime
        case convertedAirdate
        case parentShow
    }
}


// Custom struct to hold images retrieved from other API
struct TVDB: Codable {
    var poster: Data?
    var banner: Data?
    var background: Data?
}

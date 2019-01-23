//
//  TVMazeAPI.swift
//  TV Tracker
//
//  Created by Adeem on 11/2/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import Foundation


func getSearchResults(query: String, completionBlock: @escaping ([Base]) -> Void) {
    guard let url = URL(string: "https://api.tvmaze.com/search/shows?q=" + cleanURL(input: query)) else {
        print("Error: error parsing URL")
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else{
            print("Data error")
            return
        }
        do {
            let decoder = JSONDecoder()
            let base = try decoder.decode([Base].self, from: data)
            completionBlock(base);
        }
        catch let err {
            print("Error: ", err)
        }
    }.resume()
}


func getShow(id: Int) -> Show? {
    guard let url = URL(string: "https://api.tvmaze.com/shows/" + String(id)) else {
        print("Error parsing URL")
        return nil
    }
    
    do {
        let response = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let show = try decoder.decode(Show.self, from: response)
        return show
    }
    catch let error {
        print("Error: ", error)
        return nil
    }
}


func getEpisodes(show: Show) -> [Episode]? {
    guard let url = URL(string: "https://api.tvmaze.com/shows/" + String(show.id) + "/episodes") else {
        print("Error parsing URL")
        return nil
    }
    
    do {
        let response = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        var episodes = try decoder.decode([Episode].self, from: response)
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        // convert airdate string into Swift date, and store helpful data in struct
        for index in episodes.indices {
            if let airdate = formatter.date(from: episodes[index].airdate) {
                episodes[index].convertedAirdate = airdate
            }
            episodes[index].parentShow = show.title
        }
        
        return episodes
    }
    catch let error {
        print("Error: ", error)
        return nil
    }
}

//
//  SearchManager.swift
//  StoreSearch
//
//  Created by Diego Caroli on 05/07/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class SearchManager {
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  
  private var dataTask: URLSessionDataTask? = nil
  
    static let sharedInstance = SearchManager()
  
  func performSearch(for text: String, category: Int, completion: @escaping SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      
      isLoading = true
      hasSearched = true
      searchResults = []
      
      let url = iTunesURL(searchText: text, category: category)
      
      let session = URLSession.shared
      dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
        
        var success = false
        
        if let error = error as NSError?, error.code == -999 {
          return
        }
        
        if let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200,
          let jsonData = data,
          let jsonDictionary = self.parse(json: jsonData) {
          self.searchResults = self.parse(dictionary: jsonDictionary)
          self.searchResults.sort(by: <)
          
          self.isLoading = false
          success = true
        }
        
        if !success {
          self.hasSearched = false
          self.isLoading = false
        }
        
        DispatchQueue.main.async {
          completion(success)
        }
      })
      dataTask?.resume()
    }
  }
  
  func iTunesURL(searchText: String, category: Int) -> URL {
    let entityName: String
    switch category {
    case 1: entityName = "musicTrack"
    case 2: entityName = "software"
    case 3: entityName = "ebook"
    default: entityName = ""
    }
    
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
    
    let url = URL(string: urlString)
    return url!
  }
  
  func parse(json data: Data) -> [String: Any]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
  
  func parse(dictionary: [String: Any]) -> [SearchResult] {
    
    guard let array = dictionary["results"] as? [Any] else {
      print("Expected 'results' array")
      return []
    }
    
    var searchResults = [SearchResult]()
    
    for resultDict in array {
      if let resultDict = resultDict as? [String: Any] {
        var searchResult: SearchResult?
        
        if let wrapperType = resultDict["wrapperType"] as? String {
          switch wrapperType {
          case "track":
            searchResult = parse(track: resultDict)
          case "audiobook":
            searchResult = parse(audiobook: resultDict)
          case "software":
            searchResult = parse(software: resultDict)
          default:
            break
          }
        } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
          searchResult = parse(ebook: resultDict)
        }
        
        if let result = searchResult {
          searchResults.append(result)
        }
      }
    }
    
    return searchResults
  }
  
  func parse(track dictionary: [String: Any]) -> SearchResult {
    let name = dictionary["trackName"] as! String
    let artistName = dictionary["artistName"] as! String
    let artworkSmallURL = dictionary["artworkUrl60"] as! String
    let artworkLargeUrl = dictionary["artworkUrl100"] as! String
    let storeURL = dictionary["trackViewUrl"] as! String
    let kind = dictionary["kind"] as! String
    let currency = dictionary["currency"] as! String
    let price = dictionary["trackPrice"] as? Double ?? 0.0
    let genre = dictionary["primaryGenreName"] as? String ?? ""
    
    return SearchResult(name: name, artistName: artistName, artworkSmallURL: artworkSmallURL, artworkLargeURL: artworkLargeUrl, storeURL: storeURL, kind: kind, currency: currency, price: price, genre: genre)
  }
  
  func parse(audiobook dictionary: [String: Any]) -> SearchResult {
    let name = dictionary["collectionName"] as! String
    let artistName = dictionary["artistName"] as! String
    let artworkSmallURL = dictionary["artworkUrl60"] as! String
    let artworkLargeUrl = dictionary["artworkUrl100"] as! String
    let storeURL = dictionary["collectionViewUrl"] as! String
    let kind = "audiobook"
    let currency = dictionary["currency"] as! String
    let price = dictionary["collectionPrice"] as? Double ?? 0.0
    let genre = dictionary["primaryGenreName"] as? String ?? ""
    
    return SearchResult(name: name, artistName: artistName, artworkSmallURL: artworkSmallURL, artworkLargeURL: artworkLargeUrl, storeURL: storeURL, kind: kind, currency: currency, price: price, genre: genre)
  }
  
  func parse(software dictionary: [String: Any]) -> SearchResult {
    let name = dictionary["trackName"] as! String
    let artistName = dictionary["artistName"] as! String
    let artworkSmallURL = dictionary["artworkUrl60"] as! String
    let artworkLargeUrl = dictionary["artworkUrl100"] as! String
    let storeURL = dictionary["trackViewUrl"] as! String
    let kind = dictionary["kind"] as! String
    let currency = dictionary["currency"] as! String
    let price = dictionary["trackPrice"] as? Double ?? 0.0
    let genre = dictionary["primaryGenreName"] as? String ?? ""
    
    return SearchResult(name: name, artistName: artistName, artworkSmallURL: artworkSmallURL, artworkLargeURL: artworkLargeUrl, storeURL: storeURL, kind: kind, currency: currency, price: price, genre: genre)
  }
  
  func parse(ebook dictionary: [String: Any]) -> SearchResult {
    let name = dictionary["trackName"] as! String
    let artistName = dictionary["artistName"] as! String
    let artworkSmallURL = dictionary["artworkUrl60"] as! String
    let artworkLargeUrl = dictionary["artworkUrl100"] as! String
    let storeURL = dictionary["trackViewUrl"] as! String
    let kind = dictionary["kind"] as! String
    let currency = dictionary["currency"] as! String
    let price = dictionary["price"] as? Double ?? 0.0
    let genre = (dictionary["genres"] as? [String] ?? [""]).joined(separator: ", ")
    
    return SearchResult(name: name, artistName: artistName, artworkSmallURL: artworkSmallURL, artworkLargeURL: artworkLargeUrl, storeURL: storeURL, kind: kind, currency: currency, price: price, genre: genre)
  }
  
}

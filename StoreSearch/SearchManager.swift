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
  
  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
  }
  
  private(set) var state: State = .notSearchedYet
  
  private var dataTask: URLSessionDataTask? = nil
  
  static let sharedInstance = SearchManager()
  
  enum Category: Int {
    case all = 0, music, software, ebook
    
    var entityName: String {
      switch self {
      case .all: return ""
      case .music: return "musicTrack"
      case .software: return "software"
      case .ebook: return "ebook"
      }
    }
  }
  
  func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      
      state = .loading
      
      let url = iTunesURL(searchText: text, category: category)
      
      let session = URLSession.shared
      dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
        
        var newState: State = .notSearchedYet
        var success = false
        
        if let error = error as NSError?, error.code == -999 {
          DispatchQueue.main.sync {
            self.state = .notSearchedYet
          }
          return   // Search was cancelled
        }
        
        if let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200,
          let jsonData = data,
          let jsonDictionary = self.parse(json: jsonData) {
          
          var searchResults = self.parse(dictionary: jsonDictionary)
          if searchResults.isEmpty {
            newState = .noResults
          } else {
            searchResults.sort(by: <)
            newState = .results(searchResults)
          }
          success = true
        }
        DispatchQueue.main.async {
          self.state = newState
          completion(success)
        }
      })
      dataTask?.resume()
    }
  }
  
  func iTunesURL(searchText: String, category: Category) -> URL {
    let entityName = category.entityName
    
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

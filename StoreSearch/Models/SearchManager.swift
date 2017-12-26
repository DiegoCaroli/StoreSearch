//
//  SearchManager.swift
//  StoreSearch
//
//  Created by Diego Caroli on 05/07/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class SearchManager {
  static let shared = SearchManager()
  
  private struct Response: Decodable {
    let results: [SearchResult]
  }
  
  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
  }
  
  private(set) var state: State = .notSearchedYet
  
  private var dataTask: URLSessionDataTask? = nil
  
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
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      state = .loading
      
      let url = iTunesURL(searchText: text, category: category)
      
      let session = URLSession.shared
      dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
        var newState = State.notSearchedYet
        var success = false
        // Was the search cancelled?
        if let error = error as NSError?, error.code == -999 {
          return
        }
        
        if let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200, let data = data {
          var searchResults = self.parse(data: data)
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
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          completion(success)
        }
      })
      dataTask?.resume()
    }
  }
  
  // MARK: Private
  private func iTunesURL(searchText: String, category: Category) -> URL {
    let entityName = category.entityName
    
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
    
    let url = URL(string: urlString)
    return url!
  }
  
  private func parse(data: Data) -> [SearchResult] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(Response.self, from: data)
      return result.results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }
  
}


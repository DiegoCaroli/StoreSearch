//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Diego Caroli on 22/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import Foundation


struct SearchResult: Equatable, Comparable {
  
  var name: String
  var artistName: String
  var artworkSmallURL: String
  var artworkLargeURL: String
  var storeURL: String
  var kind: String
  var currency: String
  var price: Double
  var genre: String
  
  func kindForDisplay() -> String {
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Epidose"
    default: return kind
    }
  }
  
  static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name == rhs.name && lhs.artistName == rhs.artistName
  }
  
  static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
  }
  
}



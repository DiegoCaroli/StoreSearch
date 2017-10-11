//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Diego Caroli on 22/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import Foundation

struct Response: Decodable {
  
 var results = [SearchResult]()
  
}

struct SearchResult: Decodable, CustomStringConvertible {
  
  var kind: String?
  var artistName: String
  var trackName: String?
  var trackPrice: Double?
  var trackViewUrl: String?
  var collectionName: String?
  var collectionViewUrl: String?
  var collectionPrice: Double?
  var itemPrice: Double?
  var itemGenre: String?
  var bookGenre: [String]?
  var currency: String
  var artworkSmallURL: String
  var artworkLargeURL: String
  
  enum CodingKeys: String, CodingKey {
    case artworkSmallURL = "artworkUrl60"
    case artworkLargeURL = "artworkUrl100"
    case itemGenre = "primaryGenreName"
    case bookGenre = "genres"
    case itemPrice = "price"
    case kind, artistName, currency
    case trackName, trackPrice, trackViewUrl
    case collectionName, collectionViewUrl, collectionPrice
  }
  
  var name:String {
    return trackName ?? collectionName ?? ""
  }
  
  var storeURL:String {
    return trackViewUrl ?? collectionViewUrl ?? ""
  }
  
  var price:Double {
    return trackPrice ?? collectionPrice ?? 0.0
  }
  
  var genre:String {
    if let genre = itemGenre {
      return genre
    } else if let genres = bookGenre {
      return genres.joined(separator: ", ")
    }
    return ""
  }
  
  var type:String {
    let kind = self.kind ?? "audiobook"
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episode"
    default: break
    }
    return "Unknown"
  }
  
  var description:String {
    return "Kind: \(kind ?? ""), Name: \(name), Artist Name: \(artistName)\n"
  }
  
}

extension SearchResult: Equatable {
  
  static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name == rhs.name && lhs.artistName == rhs.artistName
  }
  
}

extension SearchResult: Comparable {
  
  static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
  }
  
}



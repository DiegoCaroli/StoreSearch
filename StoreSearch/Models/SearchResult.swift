//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Diego Caroli on 22/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import Foundation

struct SearchResult: Decodable, CustomStringConvertible {
  let artistName: String
  
  let trackName: String?
  let trackPrice: Double?
  let trackURL: String?
  
  let collectionName: String?
  let collectionPrice: Double?
  let collectionURL: String?
  
  let itemPrice: Double?
  let itemGenre: String?
  let bookGenre: [String]?
  
  let currency: String
  let artworkSmallURL: String
  let artworkLargeURL: String
  let kind: String?

  enum CodingKeys: String, CodingKey {
    case artworkSmallURL = "artworkUrl60"
    case artworkLargeURL = "artworkUrl100"
    case itemGenre = "primaryGenreName"
    case bookGenre = "genres"
    case itemPrice = "price"
    case trackURL = "trackViewUrl"
    case collectionURL = "collectionViewUrl"
    case kind, artistName, currency
    case trackName, trackPrice
    case collectionName, collectionPrice
  }
  
  var name: String {
    return trackName ?? collectionName ?? ""
  }
  
  var storeURL: String {
    return trackURL ?? collectionURL ?? ""
  }
  
  var price: Double {
    return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
  }
  
  var genre: String {
    if let genre = itemGenre {
      return genre
    } else if let genres = bookGenre {
      return genres.joined(separator: ", ")
    }
    return ""
  }

  var description: String {
    return "Kind: \(kind ?? "")Name: \(name), Artist Name: \(artistName)"
  }
  
  var type: String {
    let kind = self.kind ?? "audiobook"
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
    default: break
    }
    return "Unknown"
  }

}

extension SearchResult: Equatable {
  static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name == rhs.name
  }
}

extension SearchResult: Comparable {
  static func <(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
  }
}


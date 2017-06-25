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
  
  static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name == rhs.name && lhs.artistName == rhs.artistName
  }
  
  static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
  }
  
}



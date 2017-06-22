//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Diego Caroli on 22/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
  }
  
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchResults = []
    
    if searchBar.text! != "justin bieber" {
      for i in 0...2 {
        let searchResult = SearchResult(name: String(format: "Fake Result %d for", i), artistName: searchBar.text!)
        searchResults.append(searchResult)
      }
    }
    hasSearched = true
    tableView.reloadData()
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "StoreSearchCell")
    
    if cell == nil {
      cell = UITableViewCell(style: .subtitle, reuseIdentifier: "StoreSearchCell")
    }
    
    if searchResults.count == 0 {
      cell?.textLabel?.text = "(Nothing Found)"
      cell?.detailTextLabel?.text = ""
    } else {
      let searchResult = searchResults[indexPath.row]
      cell?.textLabel?.text = searchResult.name
      cell?.detailTextLabel?.text = searchResult.artistName
    }
    
    //let cell = tableView.dequeueReusableCell(withIdentifier: <#reuseIdentifier#>, for: indexPath)
    
    // Configure the cell...
    
    return cell!
  }
  
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
  
}



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
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var dataTask: URLSessionDataTask?
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.becomeFirstResponder()
    
    tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
  }
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
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
  
  func performSearch() {
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      
      dataTask?.cancel()
      
      isLoading = true
      tableView.reloadData()
      
      hasSearched = true
      searchResults = []
      
      let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
      
      let session = URLSession.shared
      
      dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
        
        if let error = error as NSError?, error.code == -999 {
          return
        } else if let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 {
          if let data = data, let jsonDictionary = self.parse(json: data) {
            self.searchResults = self.parse(dictionary: jsonDictionary)
            self.searchResults.sort(by: <)
            
            DispatchQueue.main.async {
              self.isLoading = false
              self.tableView.reloadData()
            }
            return
          }
        } else {
          print("Failure! \(response)")
        }
        
        DispatchQueue.main.async {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      })
      dataTask?.resume()
    }
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
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Whoops...",
      message: "There was an error from the iTunes Store. Please try again.",
      preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alert.addAction(okAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      let detailViewController = segue.destination as! DetailViewController
      let searchResult = sender as! SearchResult
      detailViewController.searchResult = searchResult
    }
  }
  
  
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
    } else {
       let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      
      let searchResult = searchResults[indexPath.row]
      cell.configure(for: searchResult)
      
      return cell
    }
  }
  
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let searchResult = searchResults[indexPath.row]
    performSegue(withIdentifier: "ShowDetail", sender: searchResult)
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
  
}



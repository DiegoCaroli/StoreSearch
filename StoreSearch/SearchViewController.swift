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
  
  lazy var searchManager: SearchManager = {
    return SearchManager.sharedInstance
  }()
  
  var landscapeViewController: LandscapeViewController?
  
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
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    
    switch newCollection.verticalSizeClass {
    case .compact:
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    }
  }
  
  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    guard landscapeViewController == nil else { return }
    
    landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeViewController {
      controller.searchResults = SearchManager.sharedInstance.searchResults
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      
      view.addSubview(controller.view)
      addChildViewController(controller)
      
      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()
        if self.presentedViewController != nil {
          self.dismiss(animated: true, completion: nil)
        }
      }, completion: { _ in
        controller.didMove(toParentViewController: self)
      })
    }
  }
  
  func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    if let controller = landscapeViewController {
      controller.willMove(toParentViewController: nil)
      
      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 0
      }, completion: { _ in
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        self.landscapeViewController = nil
      })
    }
  }
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }
  
  func performSearch() {
    SearchManager.sharedInstance.performSearch(for: searchBar.text!,
                                               category: segmentedControl.selectedSegmentIndex, completion: { success in
                                                if !success {
                                                  self.showNetworkError()
                                                }
                                                self.tableView.reloadData()
    })
    
    tableView.reloadData()
    searchBar.resignFirstResponder()
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
    if searchManager.isLoading {
      return 1
    } else if !searchManager.hasSearched {
      return 0
    } else if searchManager.searchResults.count == 0 {
      return 1
    } else {
      return searchManager.searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if searchManager.isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if searchManager.searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
    } else {
       let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      
      let searchResult = searchManager.searchResults[indexPath.row]
      cell.configure(for: searchResult)
      
      return cell
    }
  }
  
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let searchResult = searchManager.searchResults[indexPath.row]
    performSegue(withIdentifier: "ShowDetail", sender: searchResult)
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if searchManager.searchResults.count == 0 || searchManager.isLoading {
      return nil
    } else {
      return indexPath
    }
  }
  
}



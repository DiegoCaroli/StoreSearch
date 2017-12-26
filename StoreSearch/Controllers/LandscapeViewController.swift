//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Diego Caroli on 03/07/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
//  var searchResults = [SearchResult]()
  
  lazy var searchManager: SearchManager = {
    return SearchManager.sharedInstance
  }()
  
  var firstTime = true
  private var downloadTasks = [URLSessionDownloadTask]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true
    
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true
    
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    
    scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    pageControl.numberOfPages = 0
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    scrollView.frame = view.bounds
    
    pageControl.frame = CGRect(x: 0,
                               y: view.frame.size.height - pageControl.frame.size.height,
                               width: view.frame.size.width,
                               height: pageControl.frame.size.height)
    
    if firstTime {
      firstTime = false
      
      switch searchManager.state {
      case .notSearchedYet:
        break
      case .noResults:
        showNothingFoundLabel()
      case .loading:
        showActivityIndicator()
      case .results(let list):
        titleButtons(list)
      }
    }
  }
  
  deinit {
    print("deinit \(self)")
    for task in downloadTasks {
      task.cancel()
    }
  }
  
  func searchResultsReceived() {
    hideActivityIndicatorView()
    
    switch searchManager.state {
    case .notSearchedYet, .loading:
      break
    case .noResults:
      showNothingFoundLabel()
    case .results(let list):
      titleButtons(list)
    }
  }
  
  private func titleButtons(_ searchResults: [SearchResult]) {
    var columnsPerPage = 5
    var rowsPerPage = 3
    var itemWidth: CGFloat = 96
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 0
    var marginY: CGFloat = 20
    
    let scrollViewWidth = scrollView.bounds.size.width
    
    switch scrollViewWidth {
    case 568:
      columnsPerPage = 6
      itemWidth = 94
      marginX = 2
      
    case 667:
      columnsPerPage = 7
      itemWidth = 95
      itemHeight = 98
      marginX = 1
      marginY = 29
      
    case 736:
      columnsPerPage = 8
      rowsPerPage = 4
      itemWidth = 92
      
    default:
      break
    }
    
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth)/2
    let paddingVert = (itemHeight - buttonHeight)/2
    
    var row = 0
    var column = 0
    var x = marginX
    for (index, searchResult) in searchResults.enumerated() {
      let button = UIButton(type: .custom)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      button.frame = CGRect(x: x + paddingHorz,
                            y: marginY + CGFloat(row)*itemHeight + paddingVert,
                            width: buttonWidth, height: buttonHeight)
      button.tag = 2000 + index
      button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
      
      scrollView.addSubview(button)
      
      downloadImage(for: searchResult, andPlaceOn: button)
      
      row += 1
      
      if row == rowsPerPage {
        row = 0; x += itemWidth; column += 1
        
        if column == columnsPerPage {
          column = 0; x += marginX * 2
        }
      }
    }
    
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPage = 1 + (searchResults.count - 1) / buttonsPerPage
    scrollView.contentSize = CGSize(width: CGFloat(numPage)*scrollViewWidth,
                                    height: scrollView.bounds.size.height)
    
    pageControl.numberOfPages = numPage
    pageControl.currentPage = 0
  }
  
  @objc func buttonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetail", sender: sender)
  }
  
  private func showNothingFoundLabel() {
    let label = UILabel(frame: CGRect.zero)
    label.text = "Nothing Found"
    label.textColor = UIColor.white
    label.backgroundColor = UIColor.clear
    
    label.sizeToFit()
    
    var rect = label.frame
    rect.size.width = ceil(rect.size.width/2) * 2
    rect.size.height = ceil(rect.size.height/2) * 2
    label.frame = rect
    
    label.center = CGPoint(x: scrollView.bounds.midX,
                           y: scrollView.bounds.midY)
    view.addSubview(label)
  }
  
  private func showActivityIndicator() {
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    activityIndicatorView.center = CGPoint(x: scrollView.bounds.midX + 0.5,
                                           y: scrollView.bounds.midY + 0.5)
    activityIndicatorView.tag = 1000
    view.addSubview(activityIndicatorView)
    activityIndicatorView.startAnimating()
  }
  
  private func hideActivityIndicatorView() {
    view.viewWithTag(1000)?.removeFromSuperview()
  }
  
  private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
    if let url = URL(string: searchResult.artworkSmallURL) {
      let downloadTask = URLSession.shared.downloadTask(with: url) { [weak button] url, response, error in
        if error == nil, let url = url,
          let data = try? Data(contentsOf: url),
          let image = UIImage(data: data) {
          DispatchQueue.main.async {
            if let button = button {
              button.setImage(image.resized(withBounds: CGSize(width: 60, height: 60)), for: .normal)
            }
          }
        }
      }
      downloadTask.resume()
      downloadTasks.append(downloadTask)
    }
  }
    
  @IBAction func pageChanged(_ sender: UIPageControl) {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      self.scrollView.contentOffset = CGPoint(
        x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
        y: 0)
      
    },
                   completion: nil)
    
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = searchManager.state {
        let detailVC = segue.destination as! DetailViewController
        let index = (sender as! UIButton).tag - 2000
        detailVC.searchResult = list[index]
      }
    }
  }
  
}

extension LandscapeViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
    pageControl.currentPage = currentPage
  }
  
}

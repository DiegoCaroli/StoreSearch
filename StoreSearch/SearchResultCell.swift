//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Diego Caroli on 22/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  var downloadTask: URLSessionDownloadTask?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    downloadTask?.cancel()
    artworkImageView.image = nil
  }
  
  func configure(for searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    
    if searchResult.artistName.isEmpty {
      artistNameLabel.text = "Unknown"
    } else {
      artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
    }
    
    artworkImageView.image = UIImage(named: "Placeholder")
    if let smallURL = URL(string: searchResult.artworkSmallURL) {
      downloadTask = artworkImageView.loadImage(url: smallURL)
    }
  }
  
  func kindForDisplay(_ kind: String) -> String {
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

}

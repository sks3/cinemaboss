//
//  DetailViewController.swift
//  cinemaboss
//
//  Created by somi on 2/13/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import UIKit
import AlamofireImage

// declare possible labels from json
enum MovieKeys {
  static let title = "title"
  static let release_date = "release_date"
  static let overview = "overview"
  static let poster_path = "poster_path"
  static let backdrop_path = "backdrop_path"
}


class DetailViewController: UIViewController {
  
  @IBOutlet weak var backDropImageView: UIImageView!
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  
  var movie: [String: Any]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGesture:)))
    posterImageView.isUserInteractionEnabled = true
    posterImageView.addGestureRecognizer(tapGesture)
    
    if let movie = movie {
      movieTitleLabel.text = movie[MovieKeys.title] as? String
      releaseDateLabel.text = movie[MovieKeys.release_date] as? String
      overviewLabel.text = movie[MovieKeys.overview] as? String
      let backdropPathString = movie[MovieKeys.backdrop_path] as! String
      let posterPathString = movie[MovieKeys.poster_path] as! String
      let baseURLString = "https://image.tmdb.org/t/p/w500/"
      let backdropPathURL = URL(string: baseURLString + backdropPathString)!
      let posterPathURL = URL(string: baseURLString + posterPathString)!
      
      backDropImageView.af_setImage(withURL: backdropPathURL)
      posterImageView.af_setImage(withURL: posterPathURL)
      
    }
  }
  

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationNavigationController = segue.destination as! UINavigationController
    let movieTrailerController = destinationNavigationController.topViewController as! MovieTrailerViewController
    movieTrailerController.movie = movie
  }
  
  @objc func imageTapped(tapGesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: "showTrailer", sender: nil)
  }
  
  
}

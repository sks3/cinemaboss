/// Copyright (c) 2018 Somi Singh
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import AlamofireImage

// declare possible labels from json
//enum MovieKeys {
//  static let title = "title"
  //static let release_date = "release_date"
 // static let overview = "overview"
 // static let poster_path = "poster_path"
 // static let backdrop_path = "backdrop_path"
//}

class DetailViewController: UIViewController {
  
  @IBOutlet weak var backDropImageView: UIImageView!
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  
  // global variable for movie data
  var movie: Movie?
  //var movie: [String: Any]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // detect tap on poster image
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGesture:)))
    posterImageView.isUserInteractionEnabled = true
    posterImageView.addGestureRecognizer(tapGesture)
    
    // load data passed from segue into views
    if let movie = movie {
      
      movieTitleLabel.text = movie.title
      releaseDateLabel.text = movie.releaseDate
      overviewLabel.text = movie.overview
      
      //movieTitleLabel.text = movie[MovieKeys.title] as? String
      //releaseDateLabel.text = movie[MovieKeys.release_date] as? String
      //overviewLabel.text = movie[MovieKeys.overview] as? String
      //let backdropPathString = movie[MovieKeys.backdrop_path] as! String
      //let posterPathString = movie[MovieKeys.poster_path] as! String
      //let baseURLString = "https://image.tmdb.org/t/p/w500/"
      //let backdropPathURL = URL(string: baseURLString + backdropPathString)!
      //let posterPathURL = URL(string: baseURLString + posterPathString)!
      backDropImageView.af_setImage(withURL: movie.backdropURL!)
      posterImageView.af_setImage(withURL: movie.posterURL!)
    }
  }
  
  // pass movie to movie trailer view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationNavigationController = segue.destination as! UINavigationController
    let movieTrailerController = destinationNavigationController.topViewController as! MovieTrailerViewController
    movieTrailerController.movie = movie
  }
  
  @objc func imageTapped(tapGesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: "showTrailer", sender: nil)
  }
}

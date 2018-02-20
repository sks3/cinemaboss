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
import iProgressHUD

class SuperheroController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
  
  @IBOutlet weak var superheroCollectionView: UICollectionView!
  @IBOutlet weak var scrollView: UIScrollView!
  
  var movies: [[String: Any]] = []
  var movies1: [[String: Any]] = []
  var isMoreDataLoading = false
  var pageNum = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    superheroCollectionView.delegate = self
    scrollView.delegate = self
    superheroCollectionView.dataSource = self
    superheroCollectionView.backgroundColor = UIColor.black
    
    let layout = superheroCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = 3
    layout.minimumLineSpacing = layout.minimumInteritemSpacing
    let cellsPerLine: CGFloat = 2
    let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
    let width = superheroCollectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
    layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    
    if (movies.count == 0) {
      fetchSuperHeroMovies()
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = superheroCollectionView.contentSize.height
      let scrollViewOffsetThreshold = scrollViewContentHeight - superheroCollectionView.bounds.size.height
      if (scrollView.contentOffset.y > scrollViewOffsetThreshold && superheroCollectionView.isDragging) {
        isMoreDataLoading = true
        fetchSuperHeroMovies()
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Configure HUD and attach to view
    let iprogress: iProgressHUD = iProgressHUD()
    iprogress.isShowModal = true
    iprogress.isBlurModal = true
    iprogress.isShowCaption = true
    iprogress.isTouchDismiss = true
    iprogress.indicatorStyle = .ballGridPulse
    iprogress.indicatorSize = 65
    iprogress.boxSize = 40
    iprogress.captionSize = 20
    iprogress.attachProgress(toView: view)
    if (movies.count == 0) {
      fetchSuperHeroMovies()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
    let movie = movies[indexPath.item]
    
    if let posterPathString = movie["poster_path"] as? String {
      let baseURLstring = "https://image.tmdb.org/t/p/w500/"
      let posterURL = URL(string: baseURLstring + posterPathString)!
      cell.posterImageView.af_setImage(withURL: posterURL)
    }
    return cell
  }
  
  func fetchSuperHeroMovies() {
    view.showProgress()
    if (isMoreDataLoading) {
      pageNum += 1
    }
    let bulkRequest = "https://api.themoviedb.org/3/movie/284054/similar?api_key=4e92dd6c397483b130eb698d2e0bb14e"
    let pageRequest = "&page=" + String(pageNum)
    let url = URL(string: bulkRequest + pageRequest)!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: request) { (data, response, error) in
      // This will run when the network request returns
      if let error = error {
        print(error.localizedDescription)
      }
      else if let data = data {
        let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        if (self.isMoreDataLoading) {
          self.movies1 = dataDictionary["results"] as! [[String: Any]]
          self.movies.append(contentsOf: self.movies1)
          self.isMoreDataLoading = false
          print("fetchNowPlayingMovies2: movies size = " + String(self.movies.count))
        }
        else {
          self.movies = dataDictionary["results"] as! [[String: Any]]
        }
        self.view.dismissProgress()
        self.superheroCollectionView.reloadData()
        self.view.dismissProgress()
        print("fetchNowPlayingMovies4: movies size = " + String(self.movies.count))
      }
    }
    task.resume()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UICollectionViewCell
    if let indexPath = superheroCollectionView.indexPath(for: cell) {
      let movie = movies[indexPath.row]
      let detailViewController = segue.destination as! DetailViewController
      detailViewController.movie = movie
    }
  }
}

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

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var scrollView: UIScrollView!
  
  // global variables for movies data
  
  var movies: [Movie] = []
  var movies1: [Movie] = []
  
  // global variables for refresh and alert controllers
  var refreshControl: UIRefreshControl!
  var alertController: UIAlertController!
  
  // global variables for infinite scrolling
  var isMoreDataLoading = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 190
    tableView.backgroundColor = UIColor.black
    
    // setup pullToRefresh control
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector
      (NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    
    // alert user if no network connection is found
    alertController = UIAlertController(title: "Cannot Retrieve Movies", message: "The Internet Connection is Offline", preferredStyle: .alert)
    let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) {(action) in self.fetchNowPlayingMovies()}
    alertController.addAction(tryAgainAction)
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
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
    
    iprogress.attachProgress(toView: tableView)
    if (movies.count == 0) {
      fetchNowPlayingMovies()
    }
  }
  
  
  // call function to load more movies if scrolled past threshold
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollViewOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      if (scrollView.contentOffset.y > scrollViewOffsetThreshold && tableView.isDragging) {
        tableView.showProgress()
        isMoreDataLoading = true
        fetchNowPlayingMovies()
      }
    }
  }
  
  
  // reload movies if pulled to refresh
  @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
    // Set caption for HUD
    tableView.updateCaption(text: "refreshing...")
    tableView.showProgress()
    MovieApiManager.nowPlayingPageNum = 1
    fetchNowPlayingMovies()
  }
  
  // Retrieve NowPlaying listings from moviedb API
  func fetchNowPlayingMovies() {
    tableView.showProgress()
    if (isMoreDataLoading) {
      MovieApiManager.nowPlayingPageNum += 1
    }
    
    // append movies to dictionary if infinite scrolling
    if (isMoreDataLoading) {
      MovieApiManager().nowPlayingMovies { (movies1: [Movie]?, error: Error?) in
        if let movies1 = movies1 {
          self.movies1 = movies1
        }
      }
      self.movies.append(contentsOf: self.movies1)
      self.isMoreDataLoading = false
      self.tableView.dismissProgress()
      self.refreshControl.endRefreshing()
      self.tableView.reloadData()
    }
    else {
      MovieApiManager().nowPlayingMovies { (movies: [Movie]?, error: Error?) in
        if let movies = movies {
          self.movies = movies
          self.tableView.dismissProgress()
          self.refreshControl.endRefreshing()
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    //set cell selection effect
    cell.selectionStyle = .none
    cell.movie = movies[indexPath.row]
    return cell
  }
  
  // pass movie cell to detail view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UITableViewCell
    if let indexPath = tableView.indexPath(for: cell) {
      let movie = movies[indexPath.row]
      let detailViewController = segue.destination as! DetailViewController
      detailViewController.movie = movie
    }
  }
}

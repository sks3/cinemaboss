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
  
  
  var movies: [[String: Any]] = []
  var movies1: [[String: Any]] = []
  var refreshControl: UIRefreshControl!
  var alertController: UIAlertController!
  var isMoreDataLoading = false
  var pageNum = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad: movies size = " + String(movies.count))
    
    scrollView.delegate = self
    tableView.delegate = self
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector
      (NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
    // define datasource for tableview
    tableView.insertSubview(refreshControl, at: 0)
    
    tableView.dataSource = self
    tableView.rowHeight = 190
    tableView.backgroundColor = UIColor.black
    
    // alert user if no network connection is found
    alertController = UIAlertController(title: "Cannot Retrieve Movies", message: "The Internet Connection is Offline", preferredStyle: .alert)
    let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) {(action) in self.fetchNowPlayingMovies()}
    alertController.addAction(tryAgainAction)
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("scrollViewDidScroll: movies size = " + String(movies.count))
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollViewOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if (scrollView.contentOffset.y > scrollViewOffsetThreshold && tableView.isDragging) {
        isMoreDataLoading = true
        fetchNowPlayingMovies()
      }
    }
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    
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
      fetchNowPlayingMovies()
    }
  }
  
  
  
  @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
    print("didPullToRefresh: movies size = " + String(movies.count))
    // Set caption for HUD
    view.updateCaption(text: "refreshing...")
    view.showProgress()
    //movies = []
    //movies1 = []
    pageNum = 1
    fetchNowPlayingMovies()
  }
  
  // Retrieve NowPlaying listings from moviedb API
  func fetchNowPlayingMovies() {
    print("fetchNowPlayingMovies1: movies size = " + String(movies.count))
    print("fetch1: isMoreDataLoading = " + String(isMoreDataLoading))
    view.showProgress()
    if (isMoreDataLoading) {
      pageNum += 1
    }
    let bulkRequest = "https://api.themoviedb.org/3/movie/now_playing?api_key=4e92dd6c397483b130eb698d2e0bb14e"
    let pageRequest = "&page=" + String(pageNum)
    
    let url = URL(string: bulkRequest + pageRequest)!
    //let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=4e92dd6c397483b130eb698d2e0bb14e")!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: request) { (data, response, error) in
      // This will run when the network request returns
      if let error = error {
        // display alert for user to retry connecting
        self.present(self.alertController, animated: true)
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
          print("fetchNowPlayingMovies3: movies size = " + String(self.movies.count))
        }
        self.view.dismissProgress()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        print("fetchNowPlayingMovies4: movies size = " + String(self.movies.count))
      }
      
    }
    task.resume()
    
  }
  
  // default tableView functions
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
    
    // define placeholder image for display until posters load
    let placeholderImage = UIImage(named: "placeholder")
    
    // specify animation technique for image transition
    let filter = AspectScaledToFillSizeFilter(size: cell.posterImageView.frame.size)
    
    //set cell selection effect
    cell.selectionStyle = .none
    
    // load movie attributes into MovieCell
    let movie = movies[indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String    
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    let posterPathString = movie["poster_path"] as! String
    let baseURLString = "https://image.tmdb.org/t/p/w500/"
    let posterURL = URL(string: baseURLString + posterPathString)!
    cell.posterImageView.af_setImage(withURL: posterURL, placeholderImage: placeholderImage, filter: filter, imageTransition: .crossDissolve(0.1))
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UITableViewCell
    if let indexPath = tableView.indexPath(for: cell) {
      let movie = movies[indexPath.row]
      let detailViewController = segue.destination as! DetailViewController
      detailViewController.movie = movie
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }    
}


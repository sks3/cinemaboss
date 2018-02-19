//
//  SuperheroController.swift
//  cinemaboss
//
//  Created by somi on 2/18/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

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
    
    // Do any additional setup after loading the view.
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
    
    //let url = URL(string: "https://api.themoviedb.org/3/movie/284054/similar?api_key=4e92dd6c397483b130eb698d2e0bb14e")!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: request) { (data, response, error) in
      // This will run when the network request returns
      if let error = error {
        // display alert for user to retry connecting
        //self.present(self.alertController, animated: true)
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
        //self.refreshControl.endRefreshing()
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

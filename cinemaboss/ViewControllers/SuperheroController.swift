//
//  SuperheroController.swift
//  cinemaboss
//
//  Created by somi on 2/18/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import UIKit
import AlamofireImage

class SuperheroController: UIViewController, UICollectionViewDataSource {
  
  @IBOutlet weak var superheroCollectionView: UICollectionView!
  
  var movies: [[String: Any]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    superheroCollectionView.dataSource = self
    
    let layout = superheroCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = 3
    layout.minimumLineSpacing = layout.minimumInteritemSpacing
    let cellsPerLine: CGFloat = 3
    let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
    let width = superheroCollectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
    layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    
    fetchSuperHeroMovies()
    
    // Do any additional setup after loading the view.
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
    let url = URL(string: "https://api.themoviedb.org/3/movie/284054/similar?api_key=4e92dd6c397483b130eb698d2e0bb14e")!
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
        let movies = dataDictionary["results"] as! [[String: Any]]
        self.movies = movies
        self.superheroCollectionView.reloadData()
        //self.refreshControl.endRefreshing()
        //self.view.dismissProgress()
      }
    }
    task.resume()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

//
//  MovieTrailerViewController.swift
//  cinemaboss
//
//  Created by somi on 2/18/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import UIKit
import WebKit
import iProgressHUD

class MovieTrailerViewController: UIViewController, WKUIDelegate {
  
  var movie: [String: Any]?
  var videos: [[String: Any]]?
  
  @IBAction func doneWatching(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  var webView: WKWebView!
  
  override func loadView() {
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    view.showProgress()
    requestVideos()
    
  }
  
  func requestVideos() {
    if let movie = movie {
      
      let baseUrl = "https://api.themoviedb.org/3/movie/"
      let id = movie["id"] as! Int
      let key = "/videos?api_key=4e92dd6c397483b130eb698d2e0bb14e"
      let url = URL(string: baseUrl + String(id) + key)
      
      let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
      let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
      let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
          // display alert for user to retry connecting
          print(error.localizedDescription)
        }
        else if let data = data {
          let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
          self.videos = dataDictionary["results"] as? [[String: Any]]
          
          let youtubeBaseUrl = "https://www.youtube.com/watch?v="
          let youtubeKey = self.videos![0]["key"]! as! String
          let youtubeRequestUrl = URL(string: youtubeBaseUrl + youtubeKey)
          let youtubeRequest = URLRequest(url: youtubeRequestUrl!)
          self.webView.load(youtubeRequest)
          self.view.dismissProgress()
        }
        
      }
      task.resume()
    }
  }
  
}



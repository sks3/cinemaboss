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
import WebKit
import iProgressHUD

class MovieTrailerViewController: UIViewController, WKUIDelegate {
  
  // global variables to hold movie, video urls
  //var movie: [String: Any]?
  var movie: Movie?
  var videos: [[String: Any]]?
  var webView: WKWebView!
  
  // return to previous view controller when done
  @IBAction func doneWatching(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  // load url in WKWebView and attach to view
  override func loadView() {
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    view = webView
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
  
  // call API and retrieve movie trailer url
  func requestVideos() {
    if let movie = movie {
      //let baseUrl = "https://api.themoviedb.org/3/movie/"
      //let id = movie["id"] as! Int
      //let key = "/videos?api_key=4e92dd6c397483b130eb698d2e0bb14e"
      //let url = URL(string: baseUrl + String(id) + key)
      
      let request = URLRequest(url: movie.movieURL!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
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
    else {
      print("movie not found")
      dismiss(animated: true, completion: nil)
    }
  }
}

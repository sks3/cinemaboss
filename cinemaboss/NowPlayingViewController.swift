//
//  NowPlayingViewController.swift
//  cinemaboss
//
//  Created by somi on 2/4/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
      let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=4e92dd6c397483b130eb698d2e0bb14e")!
      
      let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
      
      let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
      
      let task = session.dataTask(with: request) { (data, response, error) in
        // This will run when the network request returns
        if let error = error {
          print(error.localizedDescription)
        }
        else if let data = data {
          let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
          print(dataDictionary)
        }
      }
      task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}


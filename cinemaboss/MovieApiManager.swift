//
//  MovieApiManager.swift
//  cinemaboss
//
//  Created by somi on 3/14/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import Foundation

class MovieApiManager {
  static let baseURL = "https://api.themoviedb.org/3/movie/"
  static let apiKey = "4e92dd6c397483b130eb698d2e0bb14e"
  static let pageRequest = "&page="
  static var nowPlayingPageNum = 1
  static var popularPageNum = 1
  var session: URLSession
  
  init() {
    session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
  }
  
  func nowPlayingMovies(completion: @escaping ([Movie]?, Error?) -> ()) {
    let url = URL(string: MovieApiManager.baseURL + "now_playing?api_key=\(MovieApiManager.apiKey)" + "&page=" + String(MovieApiManager.nowPlayingPageNum))!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let task = session.dataTask(with: request) { (data, response, error) in
      if let data = data {
        let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let movieDictionaries = dataDictionary["results"] as! [[String: Any]]
        
        let movies = Movie.movies(dictionaries: movieDictionaries)
        completion(movies, nil)
      } else {
        completion(nil, error)
      }
    }
    task.resume()
  }
  
  func popularMovies(completion: @escaping ([Movie]?, Error?) -> ()) {
    let url = URL(string: MovieApiManager.baseURL + "popular?api_key=\(MovieApiManager.apiKey)" + "&page=" + String(MovieApiManager.nowPlayingPageNum))!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let task = session.dataTask(with: request) { (data, response, error) in
      if let data = data {
        let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let movieDictionaries = dataDictionary["results"] as! [[String: Any]]
        
        let movies = Movie.movies(dictionaries: movieDictionaries)
        completion(movies, nil)
      } else {
        completion(nil, error)
      }
    }
    task.resume()
  }
}

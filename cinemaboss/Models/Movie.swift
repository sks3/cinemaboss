//
//  Movie.swift
//  cinemaboss
//
//  Created by somi on 3/13/18.
//  Copyright © 2018 Somi Singh. All rights reserved.
//

import Foundation

class Movie {
  
  let baseURLString = "https://image.tmdb.org/t/p/w500/"
  let movieBaseURLString = "https://api.themoviedb.org/3/movie/"
  let movieKey = "/videos?api_key=4e92dd6c397483b130eb698d2e0bb14e"
  
  var title: String
  var posterUrl: URL?
  var overview: String
  var releaseDate: String
  var posterPathString: String
  var id: Int
  var movieURL: URL?
  var posterURL: URL?
  var backdropPathString: String
  var backdropURL: URL?
  
  init(dictionary: [String: Any]) {
    title = dictionary["title"] as? String ?? "No Title"
    overview = dictionary["overview"] as? String ?? "No Overview"
    releaseDate = dictionary["release_date"] as? String ?? "No Release Date"
    posterPathString = dictionary["poster_path"] as? String ?? "nothing_here"
    posterURL = URL(string: baseURLString + posterPathString)!
    backdropPathString = dictionary["backdrop_path"] as? String ?? "nothing_here"
    backdropURL = URL(string: baseURLString + backdropPathString)
    id = dictionary["id"] as? Int ?? 0
    movieURL = URL(string: movieBaseURLString + String(id) + movieKey)
  }
  
  class func movies(dictionaries: [[String: Any]]) -> [Movie] {
    var movies: [Movie] = []
    for dictionary in dictionaries {
      let movie = Movie(dictionary: dictionary)
      movies.append(movie)
    }
    return movies
  }
  
}

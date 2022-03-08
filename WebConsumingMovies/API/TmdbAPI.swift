//
//  tmdbAPI.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 01/07/21.
//

import UIKit
import Foundation

class TmdbAPI {
    static let shared: TmdbAPI = TmdbAPI()
    
    private init(){}
    
    func requestMoviesPopular(page: Int = 1, completionHandler: @escaping ([MoviesResponse.Movies]) -> Void) {
        if page < 1 { fatalError("Page should not be lower than 0") }
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=e0cf1eca9ad1b5f6b8ebb2e3704382ca&language=en-US&page=\(page)"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            typealias RequestMovie = [String: Any]
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let movies = dictionary["results"] as? [RequestMovie]
            else {
                completionHandler([])
                return
            }
            var localMoviesPopular: [MoviesResponse.Movies] = []
            
            for movieDictionary in movies {
                guard let id = movieDictionary["id"] as? Int,
                      let title = movieDictionary["original_title"] as? String,
                      let overview = movieDictionary["overview"] as? String,
                      let rating = movieDictionary["vote_average"] as? Double,
                      let image = movieDictionary["poster_path"] as? String,
                      let genre_ids = movieDictionary["genre_ids"] as? [Int]
                else { continue }
                let imageUrl = "https://image.tmdb.org/t/p/w500\(image)"
                let movie = MoviesResponse.Movies(id: id, title: title, image: imageUrl, overview: overview, rating: rating, genre_ids: genre_ids)
                localMoviesPopular.append(movie)
            }
            completionHandler(localMoviesPopular)
        }
        .resume()
    }
    
    func requestMoviesNowPlaying(page: Int = 1, completionHandler: @escaping ([MoviesResponse.Movies]) -> Void) {
        if page < 1 { fatalError("Page should not be lower than 0") }
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=e0cf1eca9ad1b5f6b8ebb2e3704382ca&language=en-US&page=\(page)"
        let url = URL(string: urlString)!
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var localMoviesNowPlaying: [MoviesResponse.Movies] = []
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            typealias RequestMovie = [String: Any]
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let movies = dictionary["results"] as? [RequestMovie]
            else {
                completionHandler([])
                dispatchSemaphore.signal()
                return
            }
            
            for movieDictionary in movies {
                guard let id = movieDictionary["id"] as? Int,
                      let title = movieDictionary["original_title"] as? String,
                      let overview = movieDictionary["overview"] as? String,
                      let rating = movieDictionary["vote_average"] as? Double,
                      let image = movieDictionary["poster_path"] as? String,
                      let genre_ids = movieDictionary["genre_ids"] as? [Int]
                else { continue }
                let imageUrl = "https://image.tmdb.org/t/p/w500\(image)"
                let movie = MoviesResponse.Movies(id: id, title: title, image: imageUrl, overview: overview, rating: rating, genre_ids: genre_ids)
                localMoviesNowPlaying.append(movie)
            }
            completionHandler(localMoviesNowPlaying)
            dispatchSemaphore.signal()
        }
        .resume()
        dispatchSemaphore.wait()
        
//        for movie in localMoviesNowPlaying {
//            getGenresByIDFromAPI(genre_ids: movie.genre_ids) { genres in
//                var a = movie.genres
//                a = genres
//            }
//        }
//
        for i in 0..<localMoviesNowPlaying.count {
            getGenresByIDFromAPI(genre_ids: localMoviesNowPlaying[i].genre_ids) { genres in
                localMoviesNowPlaying[i].genres = genres
            }
        }
    }
    
    func getGenresByIDFromAPI(genre_ids: [Int], completionHandler: @escaping ([String]) -> Void) {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=e0cf1eca9ad1b5f6b8ebb2e3704382ca&language=en-US"
        let url = URL(string: urlString)!
        
        var genreNames: [String] = []
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            typealias RequestGenre = [String: Any]
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
                  let dictionary = json as? [String: Any],
                  let genres = dictionary["genres"] as? [RequestGenre]
            else {
                completionHandler([])
                return
            }
            
            for genre in genres {
                for g in genre_ids {
                    if g == genre["id"] as? Int {
                        guard let name = genre["name"] as? String
                        else { continue }
                        genreNames.append(name)
                    }
                }
            }
            completionHandler(genreNames)
        }
        .resume()
    }
    
    func getImageFromAPI(urlString: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global(qos: .background).async {
            guard let image = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                completionHandler(UIImage(data: image)!)
            }
        }
    }
}

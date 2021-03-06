//
//  MoviePresenter.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 03/03/22.
//

import Foundation
import UIKit

protocol MoviePresenterDelegate: AnyObject {
    func fetchNowPlaying(playingMovies: [MoviesResponse.Movies])
    func fetchPopular(popularMovies: [MoviesResponse.Movies])
    func fetchImage()
}

extension MoviePresenterDelegate {
    func fetchNowPlaying(playingMovies: [MoviesResponse.Movies]) {}
    func fetchPopular(popularMovies: [MoviesResponse.Movies]) {}
    func fetchImage() {}
}

class MoviePresenter {
    weak var view: (MoviePresenterDelegate & UIViewController)?
    
    init() {}
    
    func fetchNowPlaying() {
        TmdbAPI.shared.requestMoviesNowPlaying(completionHandler: { result in
            self.view?.fetchNowPlaying(playingMovies: result)
        })
    }
    
    func fetchPopular() {
        TmdbAPI.shared.requestMoviesPopular(completionHandler: { result in
            self.view?.fetchPopular(popularMovies: result)
        })
    }
    
    func fetchImage() {
    }
}

//
//  Movie.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 01/07/21.
//

import UIKit

struct Movie: CustomStringConvertible {
    
    let id: Int
    let title: String
    let image: String
    let overview: String
    let rating: Double
    let genre_ids: [Int]
    var genres: [String] = []
    
    var description: String {
        return "\(title) is a(n) Movie with \(id) ID"
    }
}


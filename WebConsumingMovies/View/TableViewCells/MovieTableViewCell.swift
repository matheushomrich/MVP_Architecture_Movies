//
//  MovieTableViewCell.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 01/07/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var overview: UILabel!
    
    @IBOutlet weak var rating: UILabel!
}

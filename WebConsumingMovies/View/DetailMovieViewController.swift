//
//  DetailMovieViewController.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 02/07/21.
//

import UIKit

class DetailMovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var movie: MoviesResponse.Movies?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detail-cell", for: indexPath) as? MovieDetailTableViewCell else {
                print("could not convert from cell to MovieDetailTableViewCell")
                return UITableViewCell()
            }
            cell.poster.layer.cornerRadius = 16
            
            TmdbAPI.shared.getImageFromAPI(urlString:movie!.image, completionHandler: { image in
                cell.poster.image = image
            })
            cell.title.text = movie?.title
            
            TmdbAPI.shared.getGenresByIDFromAPI(genre_ids: movie!.genre_ids) { [self] mov in
                movie?.genres = mov
                var genreString = movie?.genres[0]
                movie?.genres.remove(at: 0)
                
                for genre in movie!.genres {
                    genreString!.append(", \(genre)")
                }
                
                DispatchQueue.main.async {
                    cell.genres.text = genreString
                }
            }
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "star")
            imageAttachment.image = imageAttachment.image?.withTintColor(.lightGray)
            let fullString = NSMutableAttributedString(string: "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " \(movie!.rating)"))
            cell.rating.attributedText = fullString
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "overview-cell", for: indexPath) as? OverviewDetailTableViewCell else {
                print("could not convert from cell to MovieDetailTableViewCell")
                return UITableViewCell()
            }
            cell.overview.text = "Overview"
            cell.overviewText.text = movie?.overview
            
            return cell
        }
    }
}

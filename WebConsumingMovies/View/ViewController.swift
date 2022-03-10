//
//  ViewController.swift
//  WebConsumingMovies
//
//  Created by Matheus Homrich on 01/07/21.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let moviePresenter: MoviePresenter = MoviePresenter()
    var moviesNowPlaying: [MoviesResponse.Movies] = []
    var moviesPopular: [MoviesResponse.Movies] = []
    var searchBar: UISearchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.moviePresenter.view = self
        self.configureRefresh()
        self.navigationItem.searchController = searchBar
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.moviePresenter.fetchNowPlaying()
        self.moviePresenter.fetchPopular()
    }
    
    private func configureRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc func handleRefresh() {
        moviePresenter.fetchPopular()
        moviePresenter.fetchNowPlaying()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        } else {
            return "Popular"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return moviesNowPlaying.count
        } else {
            return moviesPopular.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let movie = moviesNowPlaying[indexPath.row]
            self.performSegue(withIdentifier: "detail-segue", sender: movie)
        } else {
            let movie = moviesPopular[indexPath.row]
            self.performSegue(withIdentifier: "detail-segue", sender: movie)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail-segue" {
            let movie = sender as? MoviesResponse.Movies
            let vc = segue.destination as? DetailMovieViewController
            vc!.movie = movie
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell", for: indexPath) as? MovieTableViewCell else {
                print("could not convert from cell to MovieTableViewCell")
                return UITableViewCell()
            }
            
            let movie = moviesNowPlaying[indexPath.row]
            
            cell.poster.layer.cornerRadius = 16
            
            cell.poster.kf.setImage(with: URL(string: movie.image))
            cell.title.text = movie.title
            cell.overview.text = movie.overview
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "star")
            imageAttachment.image = imageAttachment.image?.withTintColor(.lightGray)
            let fullString = NSMutableAttributedString(string: "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " \(movie.rating)"))
            cell.rating.attributedText = fullString
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell", for: indexPath) as? MovieTableViewCell else {
                print("could not convert from cell to MovieTableViewCell")
                return UITableViewCell()
            }
            
            let movie = moviesPopular[indexPath.row]
            
            cell.poster.layer.cornerRadius = 16
            
            cell.poster.kf.setImage(with: URL(string: movie.image))
            cell.title.text = movie.title
            cell.overview.text = movie.overview
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "star")
            imageAttachment.image = imageAttachment.image?.withTintColor(.lightGray)
            let fullString = NSMutableAttributedString(string: "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " \(movie.rating)"))
            cell.rating.attributedText = fullString
            return cell
        }
    }
}

extension ViewController: MoviePresenterDelegate {
    func fetchPopular(popularMovies: [MoviesResponse.Movies]) {
        self.moviesPopular = popularMovies
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchNowPlaying(playingMovies: [MoviesResponse.Movies]) {
        self.moviesNowPlaying = playingMovies
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

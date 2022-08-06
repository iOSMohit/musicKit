//
//  ViewController.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 15/02/22.
//

import MusicKit
import UIKit
import MBProgressHUD
import AVFoundation

struct UserData {
    var isAuthorized: Bool {
        if let isValid = UserDefaults.standard.value(forKey: "isValid") as? Bool {
            return isValid
        }
        
        return false
    }
}

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tblView: UITableView!

    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var albums: MusicItemCollection<Album> = []
    private var searchTerm = "" {
        didSet {
            self.requestUpdatedSearchResults(for: searchTerm)
        }
    }
    
    private var isSearching = true
    private let userData = UserData()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, options: .mixWithOthers)
        } catch {
            print("AVAudioSession cannot be set: \(error)")
        }
        configureTblView()
        configureSearchController()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let isUserLoggedIn = UserDefaults.standard.value(forKey: "isValid") as? Bool, isUserLoggedIn {
            self.searchTerm = "Hip Hop"
        } else {
            self.performSegue(withIdentifier: "toAuth", sender: nil)
        }
    }
    private func configureTblView() {
        tblView.dataSource = self
        tblView.delegate = self
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tblView.register(AlbumCell.getNib(), forCellReuseIdentifier: AlbumCell.reusableIdentifier)
    }
    private func configureSearchController(){
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Albums"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    // MARK: - Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail",
           let album = sender as? Album,
           let detailVC = segue.destination as? AlbumDetailController{
            detailVC.album = album
        } else if segue.identifier == "toAuth", let authVC = segue.destination as? AuthorizationController {
            authVC.onSuccess = { isAuthorized in
                if isAuthorized {
                    UserDefaults.standard.setValue(true, forKey: "isValid")
                    UserDefaults.standard.synchronize()
                    
                    self.searchTerm = "Hip Hop"
                } else {
                    self.showToast(msg: "Please authorize this app to access apple music info to continue")
                    print("User is not authorize to view content")
                }
            }
        }
    }
    
    // MARK: - MusicKit methods
    private func checkAuthorization() async throws {
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized :
            print("User is authorize...")
            
            searchTerm = "Hip Hop"
        default:
            print("User is not authorized...")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.reusableIdentifier, for: indexPath) as! AlbumCell
        
        let album = albums[indexPath.row]
        cell.album = album
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.albums.count - 1 {
            print("Navigate to next page...")
            Task {
                do {
                    self.showLoader()
                    guard let nextAlbums = try await albums.nextBatch(limit: 25) else { return }
                    self.albums += nextAlbums
                    
                    self.hideLoader()
                    self.tblView.reload()
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = self.albums[indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: album)
    }
}

extension ViewController {
    /// Makes a new search request to MusicKit when the current search term changes.
    private func requestUpdatedSearchResults(for searchTerm: String) {
        Task {
            if searchTerm.isEmpty {
                self.reset()
            } else {
                do {
                    // Issue a catalog search request for albums matching the search term.
                    
                    self.showLoader()
                    var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
                    searchRequest.limit = 25
                    let searchResponse = try await searchRequest.response()
                    
                    // Update the user interface with the search response.
                    self.apply(searchResponse, for: searchTerm)
                } catch {
                    print("Search request failed with error: \(error).")
                    self.reset()
                }
            }
        }
    }
    
    /// Safely updates the `albums` property on the main thread.
    @MainActor
    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            let albums = searchResponse.albums
            self.albums = albums
            print(albums.hasNextBatch)
            print("There are total \(albums.count) Albums")
            
            self.tblView.reloadData()
        }
        
        self.hideLoader()
    }
    
    /// Safely resets the `albums` property on the main thread.
    @MainActor
    private func reset() {
        self.albums = []
        self.hideLoader()
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard userData.isAuthorized else {
            self.showToast(msg: "Please authorize this app to access apple music info to continue")
            return
        }
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            self.searchTerm = searchText
            
            // To avoid pagination automatically
            self.tblView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

extension UIViewController {
    func showLoader() {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.isUserInteractionEnabled = true
            hud.label.text = "Please wait..."
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    func showToast(msg: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.isUserInteractionEnabled = true
        hud.mode = .text
        hud.label.text = msg
        hud.label.numberOfLines = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            hud.hide(animated: true)
        }
    }
}

extension UITableView {
    func reload() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    func makeHeaderAutoResizable(){
        self.sectionHeaderHeight = UITableView.automaticDimension
        self.estimatedSectionHeaderHeight = 1000
    }
}

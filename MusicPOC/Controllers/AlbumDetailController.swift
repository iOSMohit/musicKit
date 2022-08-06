//
//  AlbumDetailController.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 18/02/22.
//

import MusicKit
import UIKit

class AlbumDetailController: UIViewController {
    
    @IBOutlet private weak var tblView: UITableView!
    
    var album: Album!
    private var tracks: MusicItemCollection<Track>?
    private var player = ApplicationMusicPlayer.shared
    private var playerState = ApplicationMusicPlayer.shared.state
    
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            self.showLoader()
            await fetchTracks(for: self.album)
        }
        
        setupTblView()
        setupNavBar()
        setupData()
    }
    private func setupData() {
        self.isPlaying = playerState.playbackStatus == .playing
    }
    private func setupNavBar() {
        self.title = album.title
    }
    private func setupTblView() {
        self.tblView.register(TrackCell.getNib, forCellReuseIdentifier: TrackCell.reusableIdentifier)
        self.tblView.register(AlbumDetailSectionHeader.getNib, forHeaderFooterViewReuseIdentifier: AlbumDetailSectionHeader.identifier)
        
        self.tblView.dataSource = self
        self.tblView.delegate = self
        self.tblView.makeHeaderAutoResizable()
    }
    private func fetchTracks(for album: Album) async {
        let detailedAlbum = try? await album.with([.tracks, .artists])

        if let detailedAlbum = detailedAlbum, let tracks = detailedAlbum.tracks {
            self.tracks = tracks
            self.tblView.reload()
        }
        self.hideLoader()
    }
    @objc private func playBtnPressed(_ sender: UIButton) {
        self.startPlayer(with: 0)
    }
}

extension AlbumDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks?.count ?? 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AlbumDetailSectionHeader.identifier) as! AlbumDetailSectionHeader
        headerView.album = self.album
        headerView.playBtn.addTarget(self, action: #selector(playBtnPressed(_:)), for: .touchUpInside)
        headerView.isPlaying = self.isPlaying
        
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reusableIdentifier, for: indexPath) as! TrackCell
        
        if let tracks = self.tracks {
            let track = tracks[indexPath.row]
            cell.track = track
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.startPlayer(with: indexPath.row)
    }
    private func startPlayer(with position: Int) {
        if let tracks = self.tracks {
            let track = tracks[position]
            player.queue = ApplicationMusicPlayer.Queue(for: tracks, startingAt: track)
            beginPlaying()
        }
    }
    private func beginPlaying() {
        Task {
            do {
                try await player.play()
                self.isPlaying = true
                self.tblView.reload()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
}

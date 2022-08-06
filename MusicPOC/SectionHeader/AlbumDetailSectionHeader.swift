//
//  AlbumDetailSectionHeader.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 19/02/22.
//

import MusicKit
import UIKit

class AlbumDetailSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var albumArt: UIImageView!
    @IBOutlet private weak var albumName: UILabel!
    
    @IBOutlet private weak var playContainer: UIView!
    @IBOutlet private weak var playIcon: UIImageView!
    @IBOutlet private weak var playTitle: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    
    var album: Album! {
        didSet {
            setupData()
        }
    }
    
    var isPlaying = false {
        didSet {
            if isPlaying {
                playIcon.image = UIImage(systemName: "pause.fill")
                playTitle.text = pauseButtonTitle
            } else {
                playIcon.image = UIImage(systemName: "play.fill")
                playTitle.text = playButtonTitle
            }
        }
    }
    private let playButtonTitle = "Play"
    private let pauseButtonTitle = "Pause"
    
    static var identifier = "AlbumDetailSectionHeaderID"
    static var getNib: UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }
    private func setupData() {
        let imageWidth:Int = Int(self.contentView.frame.size.width-(2*48))
        if let artwork = self.album.artwork,
           let imageUrl = artwork.url(width: imageWidth, height: imageWidth) {
            self.albumArt.loadImage(with: imageUrl, placeholderImage: UIImage(systemName: "photo.artframe"))
        }
        
        self.albumName.text = album.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.albumArt.layer.cornerRadius = 8
        self.albumArt.clipsToBounds = true
        
        self.playContainer.layer.cornerRadius = 4
        self.playContainer.clipsToBounds = true
    }
}

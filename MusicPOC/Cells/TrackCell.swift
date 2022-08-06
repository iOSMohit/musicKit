//
//  TrackCell.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 18/02/22.
//

import MusicKit
import UIKit

class TrackCell: UITableViewCell {
    
    // MARK: - IBOuetlet
    
    @IBOutlet private weak var trackNoLabel: UILabel!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var trackArtwork: UIImageView!

    // MARK: - Properties
    static let reusableIdentifier = "TrackCellID"
    static var getNib: UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }
    
    var track: Track!{
        didSet {
            self.trackNameLabel.text = self.track.title
            self.artistNameLabel.text = self.track.artistName
            self.trackNoLabel.text = (self.track.trackNumber ?? 1).toString()+"."
            
            if let artwork = self.track.artwork,
               let trackImageUrl = artwork.url(width: 64, height: 64) {
                self.trackArtwork.loadImage(with: trackImageUrl,
                                            placeholderImage: UIImage(systemName: "play.square.fill"))
            }
        }
    }
    
    // MARK: - UIView methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trackArtwork.layer.cornerRadius = 4
        trackArtwork.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension Int {
    func toString() -> String{
        "\(self)"
    }
}

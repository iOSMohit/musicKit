    //
//  AlbumCell.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 16/02/22.
//

import MusicKit
import UIKit
import Kingfisher

class AlbumCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var artworkImgView: UIImageView!
    @IBOutlet private weak var albumTitle: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    
    static let reusableIdentifier = "AlbumCellID"
    var album: Album! {
        didSet {
            if let artwork = album.artwork, let albumUrl = artwork.url(width: 72, height: 72) {
                artworkImgView.loadImage(with: albumUrl,
                                         placeholderImage: UIImage(systemName: "photo.artframe"))
            } else {
                artworkImgView.image = UIImage(systemName: "photo.artframe")
            }
            
            albumTitle.text = album.title
            descriptionLabel.text = album.artistName
        }
    }
    
    // MARK: - UIView methods

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        self.artworkImgView.layer.cornerRadius = 4
        self.artworkImgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helper methods
    static func getNib() -> UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }
    
    // MARK: - IBAction methods
    
}


extension UIImageView{
    
    func loadImage(imageUrlString:String,placeholderImageName:String){
        self.image = nil
        let placeholderImg = UIImage.init(named: placeholderImageName)
        guard let imageURLWithoutSpace = imageUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),let imageURL = URL(string: imageURLWithoutSpace) else{
            self.image = placeholderImg
            return
        }
        let cacheKey = imageUrlString
        let songImageResource = ImageResource(downloadURL: imageURL, cacheKey: cacheKey)
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: songImageResource, placeholder: placeholderImg)
    }
    
    func loadImage(with imageURL:URL,placeholderImage:UIImage?){
        let songImageResource = ImageResource(downloadURL: imageURL, cacheKey: nil)
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: songImageResource, placeholder: placeholderImage)
    }
    
    func loadImage(for urlString:String,placeholderImage:UIImage?){
        guard let imageURLWithoutSpace = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),let imageURL = URL(string: imageURLWithoutSpace) else{
            self.image = placeholderImage
            return
        }
        let cacheKey = urlString
        let songImageResource = ImageResource(downloadURL: imageURL, cacheKey: cacheKey)
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: songImageResource, placeholder: placeholderImage)
    }
}

extension Album {
    func getGenre() -> String {
        let genres = self.genreNames
        var allGenres = ""
        for (index, genre) in genres.enumerated() {
            if index == genres.count - 1 {
                allGenres += " \(genre)"
            } else {
                allGenres += "\(genre) ,"
            }
        }
        
        return allGenres
    }
}











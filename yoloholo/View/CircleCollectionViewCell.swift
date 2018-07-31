//
//  CircleCollectionViewCell.swift
//  yoloholo
//
//  Created by killi8n on 2018. 7. 25..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class CircleCollectionViewCell: UICollectionViewCell {
    
    var placeViewModel: DetailPlanViewModel! {
        didSet {
            
            getGooglePlaceImage(placeId: placeViewModel.placeId)
            
            destNameLabel.text = placeViewModel.destName
        }
    }
    
    let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        iv.clipsToBounds = true
       
        return iv
    }()
    
    let destNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupContentView() {
        contentView.layer.cornerRadius = contentView.frame.size.width * 0.5
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let components = [placeImageView]
        components.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        placeImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        placeImageView.layer.cornerRadius = contentView.frame.size.width * 0.5
        
        placeImageView.addSubview(destNameLabel)
        destNameLabel.translatesAutoresizingMaskIntoConstraints = false
        destNameLabel.centerXAnchor.constraint(equalTo: placeImageView.centerXAnchor).isActive = true
        destNameLabel.centerYAnchor.constraint(equalTo: placeImageView.centerYAnchor).isActive = true
        destNameLabel.widthAnchor.constraint(equalToConstant: 280).isActive = true
        destNameLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

    }
    
    
}

extension CircleCollectionViewCell {
    func getGooglePlaceImage(placeId: String?) {
        guard let placeId = placeId else {
            DispatchQueue.main.async {
                self.placeImageView.image = nil
            }
            return
            
        }
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                        (photo, error) -> Void in
                        
                        if let error = error {
                            
                            print("Error: \(error.localizedDescription)")
                        }
                        else {
                            DispatchQueue.main.async {
                                self.placeImageView.image = photo
                            }
                        }
                    })
                }
            }
        }
    }
}

//
//  SharingActivityItemSource.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 15/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit

class SharingActivityItemSource: NSObject, UIActivityItemSource {
    
    let placeHolderText = "Kaupunkifillarit.fi - Kaupunkifillarit kartalla https://itunes.apple.com/app/id1111297620"
    
    @objc func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return placeHolderText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        switch activityType {
            case let x where [UIActivityType.postToFacebook, UIActivityType.postToTwitter].contains(x):
                return "Tässäpä kätevä äppi! " + placeHolderText
            default:
                return placeHolderText
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "Kaupunkifillarit.fi - Näppärä sovellus, jolla löydät lähimmän kaupunkifillarin!"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return UIImage(named: "kaupunkifillarit-logo.png")
    }
    
    
    
}

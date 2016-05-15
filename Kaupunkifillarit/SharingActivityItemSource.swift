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
    
    @objc func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return placeHolderText
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        switch activityType {
            case let x where [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter].contains(x):
                return "Tässäpä kätevä äppi! " + placeHolderText
            default:
                return placeHolderText
        }
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return "Kaupunkifillarit.fi - Näppärä sovellus, jolla löydät lähimmän kaupunkifillarin!"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
        return UIImage(named: "kaupunkifillarit-logo.png")
    }
    
    
    
}
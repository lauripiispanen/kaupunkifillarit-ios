//
//  StationAnnotation.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 06/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import MapKit

class StationAnnotation: MKPointAnnotation {
    let amount:Int
    let total:Int
    var icon:UIImage {
        get {
            return createMarkerIcon(self.amount, total: self.total)
        }
    }
    
    init(amount: Int, total: Int) {
        self.amount = amount
        self.total = total
        super.init()
    }
}

func createMarkerIcon(amount: Int, total: Int) -> UIImage {
    let margin:Double = 0
    let width:Double = 56
    let height:Double = 40
    let taper:Double = 5
    let boxHeight:Double = 30
    let boxRect = CGRect(x: margin, y: margin, width: width, height: boxHeight)
    let label = UIView(frame: CGRect(x: 0, y: 0, width: width + (2 * margin), height: height + (2 * margin)))
    label.opaque = false
    label.backgroundColor = UIColor.clearColor()
    let markerPath = UIBezierPath(rect: boxRect)
    let midpoint = (width + (2 * margin)) / 2.0
    markerPath.moveToPoint(CGPoint(x: midpoint - taper, y: boxHeight + margin))
    markerPath.addLineToPoint(CGPoint(x: midpoint, y: height + margin))
    markerPath.addLineToPoint(CGPoint(x: midpoint + taper, y: boxHeight + margin))
        
    let markerBackground = CAShapeLayer()
    markerBackground.path = markerPath.CGPath
    markerBackground.fillColor = UIColor(red: 254.0 / 255.0, green: 187.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0).CGColor
    markerBackground.shadowColor = UIColor.blackColor().CGColor
    markerBackground.shadowOffset = CGSize(width: 0.0, height: 2.0)
    markerBackground.shadowRadius = 4.0
    markerBackground.shadowOpacity = 0.1
    
    label.layer.addSublayer(markerBackground)
    
    let text = UILabel(frame: boxRect)
    text.text = String(format: "%d / %d", amount, total)
    text.textAlignment = .Center
    text.font = text.font.fontWithSize(12.0)
    
    label.addSubview(text)
    
    return viewToImage(label)
}

func viewToImage(view: UIView) -> UIImage {
    let size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, view.opaque, 0.0)
    //CGContextSetShadow(UIGraphicsGetCurrentContext(), CGSize(width: 0, height: 4), 8.0)
    
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return img
}
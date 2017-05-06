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

func createMarkerIcon(_ amount: Int, total: Int) -> UIImage {
    let margin:Double = 0
    let width:Double = 44
    let height:Double = 60

    let label = UIView(frame: CGRect(x: 0, y: 0, width: width + (2 * margin), height: height + (2 * margin)))
    label.isOpaque = false
    label.backgroundColor = UIColor.clear

    let markerPath = UIBezierPath()
    markerPath.move(to: CGPoint(x: width / 2.0, y: height))
    markerPath.addCurve(to: CGPoint(x: 0, y: width / 2.0), controlPoint1: CGPoint(x: 0, y: 7.0 * width / 8.0), controlPoint2: CGPoint(x: 0, y: 5.0 * width / 8.0))
    markerPath.addArc(withCenter: CGPoint(x: width / 2.0, y: width / 2.0), radius: (CGFloat(width) / 2.0), startAngle: CGFloat(M_PI), endAngle: 0, clockwise: true)
    markerPath.addCurve(to: CGPoint(x: width / 2.0, y: height), controlPoint1: CGPoint(x: width, y: 5.0 * width / 8.0), controlPoint2: CGPoint(x: width, y: 7.0 * width / 8.0))

    let markerBackground = CAShapeLayer()
    markerBackground.path = markerPath.cgPath
    if (amount == 0) {
        markerBackground.fillColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0).cgColor
    } else {
        markerBackground.fillColor = UIColor(red: 251.0 / 255.0, green: 188.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0).cgColor
    }
    markerBackground.shadowColor = UIColor.black.cgColor
    markerBackground.shadowOffset = CGSize(width: 0.0, height: 2.0)
    markerBackground.shadowRadius = 4.0
    markerBackground.shadowOpacity = 0.1
    
    label.layer.addSublayer(markerBackground)
    
    let text = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height * 3.0 / 4.0))
    text.text = String(format: "%d / %d", amount, total)
    text.textAlignment = .center
    text.font = text.font.withSize(12.0)
    
    label.addSubview(text)
    
    return viewToImage(label)
}

func viewToImage(_ view: UIView) -> UIImage {
    let size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, view.isOpaque, 0.0)
    
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return img!
}

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
    let width:Double = 20
    let height:Double = 30
    let label = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    label.opaque = false
    label.backgroundColor = UIColor.clearColor()
    let markerPath = UIBezierPath()
    markerPath.moveToPoint(CGPoint(x: width / 2.0, y: height))
    markerPath.addCurveToPoint(CGPoint(x: 0, y: width / 2.0), controlPoint1: CGPoint(x: 0, y: 7.0 * width / 8.0), controlPoint2: CGPoint(x: 0, y: 5.0 * width / 8.0))
    
    markerPath.addArcWithCenter(CGPoint(x: width / 2.0, y: width / 2.0), radius: (CGFloat(width) / 2.0), startAngle: CGFloat(M_PI), endAngle: 0, clockwise: true)
    
    markerPath.addCurveToPoint(CGPoint(x: width / 2.0, y: height), controlPoint1: CGPoint(x: width, y: 5.0 * width / 8.0), controlPoint2: CGPoint(x: width, y: 7.0 * width / 8.0))
    
    let markerBackground = CAShapeLayer()
    markerBackground.path = markerPath.CGPath
    markerBackground.fillColor = UIColor.whiteColor().CGColor
    
    label.layer.addSublayer(markerBackground)
    
    let markerForeground = CAShapeLayer()
    markerForeground.path = markerPath.CGPath
    markerForeground.fillColor = UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0).CGColor
    
    let consumed = Double(amount) / Double(total)
    let mask = CAShapeLayer()
    mask.path = UIBezierPath(rect: CGRect(x: 0, y: height * (1.0 - consumed), width: width, height: height * consumed)).CGPath
    markerForeground.mask = mask
    
    
    label.layer.addSublayer(markerForeground)
    
    let text = UILabel(frame: label.frame)
    text.text = String(amount)
    text.textAlignment = .Center
    text.font = text.font.fontWithSize(10.0)
    
    label.addSubview(text)
    
    let foregroundText = UILabel(frame: label.frame)
    foregroundText.text = String(amount)
    foregroundText.textColor = UIColor.whiteColor()
    foregroundText.textAlignment = .Center
    foregroundText.font = foregroundText.font.fontWithSize(10.0)
    let textMask = CAShapeLayer()
    textMask.path = mask.path
    foregroundText.layer.mask = textMask
    
    label.addSubview(foregroundText)
    
    return viewToImage(label)
}

func viewToImage(view: UIView) -> UIImage {
    let size = CGSize(width: view.bounds.size.width + 10.0, height: view.bounds.size.height + 10.0)
    UIGraphicsBeginImageContextWithOptions(size, view.opaque, 0.0)
    CGContextSetShadow(UIGraphicsGetCurrentContext(), CGSize(width: 0, height: 4), 8.0)
    
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return img
}
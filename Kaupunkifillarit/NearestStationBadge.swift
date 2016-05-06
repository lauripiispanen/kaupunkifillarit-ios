//
//  NearestStationBadge.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 06/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit

class NearestStationBadge {
    
    let nearestStationText: UILabel
    let nearestStationDistance: UILabel
    let nearestStationCount: UILabel
    let view: UIView
    
    init() {
        self.view = UIView()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let ring = CAShapeLayer()
        ring.shadowColor = UIColor.blackColor().CGColor
        ring.shadowRadius = 10.0
        ring.shadowOpacity = 0.4
        ring.shadowOffset = CGSize(width: 0, height: 5)
        ring.path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 100, height: 100)).CGPath
        ring.fillColor = UIColor.whiteColor().CGColor
        self.view.layer.addSublayer(ring)
        
        let nearestStationText = UILabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        self.nearestStationText = nearestStationText
        nearestStationText.textAlignment = .Center
        nearestStationText.font = nearestStationText.font.fontWithSize(10.0)
        self.view.addSubview(nearestStationText)
        
        let nearestStationDistance = UILabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 50.0))
        self.nearestStationDistance = nearestStationDistance
        nearestStationDistance.textAlignment = .Center
        nearestStationDistance.font = nearestStationDistance.font.fontWithSize(12.0)
        self.view.addSubview(nearestStationDistance)
        
        let nearestStationCount = UILabel(frame: CGRect(x: 0, y: 50.0, width: 100.0, height: 50.0))
        self.nearestStationCount = nearestStationCount
        nearestStationCount.textAlignment = .Center
        nearestStationCount.font = nearestStationCount.font.fontWithSize(12.0)
        self.view.addSubview(nearestStationCount)
    }
    
    func setNearestStation(station: Station, distance: Double, count: Int) {
        self.nearestStationText.text = station.name
        self.nearestStationDistance.text = String(format: "%1.0fm", distance)
        self.nearestStationCount.text = String(format: "%d kpl", count)
    }
    
    
    
}
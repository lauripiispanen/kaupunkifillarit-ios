//
//  ViewController.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 04/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let API = NSURL(string: "https://kaupunkifillarit.herokuapp.com/api/stations")
    var map: GMSMapView?
    let locationManager = CLLocationManager()
    var stations = Array<Station>()
    var borrowing = true
    var borrowButton: UIButton?
    var returnButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        map = GMSMapView()
        
        map!.camera = GMSCameraPosition.cameraWithLatitude(60.1699, longitude: 24.9384, zoom: 13.0)
        map!.myLocationEnabled = true
        
        self.view.addSubview(map!)
        
        let borrowButton = UIButton()
        self.borrowButton = borrowButton
        borrowButton.addTarget(self, action: #selector(self.startBorrowing), forControlEvents: .TouchUpInside)
        borrowButton.backgroundColor = UIColor.whiteColor()
        borrowButton.translatesAutoresizingMaskIntoConstraints = false
        borrowButton.setTitle("LAINAAN", forState: .Normal)
        borrowButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.view.addSubview(borrowButton)
        
        let returnButton = UIButton()
        self.returnButton = returnButton
        returnButton.addTarget(self, action: #selector(self.startReturning), forControlEvents: .TouchUpInside)
        returnButton.backgroundColor = UIColor.grayColor()
        
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.setTitle("PALAUTAN", forState: .Normal)
        returnButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        self.view.addSubview(returnButton)
        
        map!.translatesAutoresizingMaskIntoConstraints = false
        map!.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -75.0).active = true
        map!.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        map!.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        map!.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        
        borrowButton.topAnchor.constraintEqualToAnchor(map!.bottomAnchor).active = true
        borrowButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        borrowButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        
        returnButton.topAnchor.constraintEqualToAnchor(map!.bottomAnchor).active = true
        returnButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        returnButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        returnButton.leftAnchor.constraintEqualToAnchor(borrowButton.rightAnchor).active = true
        borrowButton.widthAnchor.constraintEqualToAnchor(returnButton.widthAnchor).active = true
        
        loadStationData()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            if let loc = locationManager.location {
                locationManager(locationManager, didUpdateLocations: [loc])
            }
        }
    }
    
    func startBorrowing() {
        self.borrowing = true
        self.redrawStations()
        returnButton!.backgroundColor = UIColor.grayColor()
        borrowButton!.backgroundColor = UIColor.whiteColor()
    }
    
    func startReturning() {
        self.borrowing = false
        self.redrawStations()
        borrowButton!.backgroundColor = UIColor.grayColor()
        returnButton!.backgroundColor = UIColor.whiteColor()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location,
           let station = nearestStation(location) {
            
            print(station.name, distance(location)(station))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func distance(location: CLLocation) -> (Station) -> Double {
        return {(station: Station) -> Double in
            return location.distanceFromLocation(CLLocation(latitude: station.lat, longitude: station.lon))
        }
    }
    
    func nearestStation(location: CLLocation) -> Station? {
        let distanceTo = distance(location)
        
        return stations.sort({ (station1, station2) -> Bool in
            distanceTo(station1) < distanceTo(station2)
        }).first
    }
    
    func loadStationData() {
        let task = NSURLSession.sharedSession().dataTaskWithURL(API!) {
            (data, response, error) -> Void in
                do {
                    let obj = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    let stations = obj["bikeRentalStations"]
                    if stations is NSArray {
                        self.stations = (stations as! NSArray).map { Station.parse($0) }.filter { $0 != nil }.map { $0! }
                        self.redrawStations()
                    }
                } catch let err {
                    print(err)
                }

        }
        
        task.resume()
    }
    
    func redrawStations() {
        let markers = self.stations.map { (station) -> (Station, UIImage) in
            return (station, self.createMarkerIcon(station))
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.map!.clear()
            markers.forEach { (stationAndMarker) -> Void in
                let station = stationAndMarker.0
                let coords = CLLocationCoordinate2DMake(station.lat, station.lon)
                let marker = GMSMarker(position: coords)
                marker.icon = stationAndMarker.1
                marker.map = self.map!
            }
        })
    }
    
    func createMarkerIcon(station: Station) -> UIImage {
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
        
        let amount = borrowing ? station.bikesAvailable : station.spacesAvailable
        let size = Double(amount) / Double(station.bikesAvailable + station.spacesAvailable)
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(rect: CGRect(x: 0, y: height * (1.0 - size), width: width, height: height * size)).CGPath
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

}

struct Station {
    let spacesAvailable: Int
    let bikesAvailable: Int
    let id: String
    let lat: Double
    let lon: Double
    let name: String
    
    static func parse(obj: AnyObject) -> Station? {
        if obj is Dictionary<String, AnyObject> {
            if let spacesAvailable = obj["spacesAvailable"] as? Int,
               let bikesAvailable = obj["bikesAvailable"] as? Int,
               let id = obj["id"] as? String,
               let lat = obj["lat"] as? Double,
               let lon = obj["lon"] as? Double,
               let name = obj["name"] as? String {
                return Station(spacesAvailable: spacesAvailable, bikesAvailable: bikesAvailable, id: id, lat: lat, lon: lon, name: name)
            }
        }
        return nil
    }
}
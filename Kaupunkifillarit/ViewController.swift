//
//  ViewController.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 04/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FillariDataSourceDelegate {
    
    
    var map: MKMapView?
    let locationManager = CLLocationManager()
    let dataSource = FillariDataSource()
    var borrowing = true
    var borrowButton: UIButton?
    var returnButton: UIButton?
    var nearestStationBadge: NearestStationBadge?

    override func viewDidLoad() {
        super.viewDidLoad()
        map = MKMapView()
        map?.delegate = self
        
        dataSource.delegate = self
        
        map!.showsUserLocation = true
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        
        map!.setRegion(region, animated: false)
        
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
        
        let badge = NearestStationBadge()
        self.nearestStationBadge = badge
        
        self.view.addSubview(badge.view)
        
        badge.view.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20.0).active = true
        badge.view.widthAnchor.constraintEqualToConstant(100.0).active = true
        badge.view.heightAnchor.constraintEqualToAnchor(badge.view.widthAnchor).active = true
        badge.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        
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
        
        dataSource.startRefresh()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            syncLocation()
        }
    }
        
    func syncLocation() {
        if let loc = locationManager.location {
            locationManager(locationManager, didUpdateLocations: [loc])
        }
    }
    
    func startBorrowing() {
        self.borrowing = true
        self.redrawStations(dataSource.stations)
        returnButton!.backgroundColor = UIColor.grayColor()
        borrowButton!.backgroundColor = UIColor.whiteColor()
        syncLocation()
    }
    
    func startReturning() {
        self.borrowing = false
        self.redrawStations(dataSource.stations)
        borrowButton!.backgroundColor = UIColor.grayColor()
        returnButton!.backgroundColor = UIColor.whiteColor()
        syncLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location,
           let station = dataSource.nearestStation(location, borrowing: borrowing) {
            nearestStationBadge!.setNearestStation(station, distance: distance(location)(station), count: borrowing ? station.bikesAvailable : station.spacesAvailable)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is StationAnnotation {
            let ann = (annotation as! StationAnnotation)
            let id = String(format: "station-%d/%d", ann.amount, ann.total)
            
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(id)
            if pin != nil {
                return pin
            } else {
                pin = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                pin?.image = ann.icon
                pin?.canShowCallout = false
            }
            return pin
        }
        return nil
    }
    
    
    func updatedStationData(stations: [Station]) {
        self.redrawStations(stations)
    }
    
    
    func redrawStations(stations: [Station]) {
        let markers = stations.map { (station) -> StationAnnotation in
            
            let amount = borrowing ? station.bikesAvailable : station.spacesAvailable
            let total = station.bikesAvailable + station.spacesAvailable
            
            let annotation = StationAnnotation(amount: amount, total: total)
            annotation.coordinate = CLLocationCoordinate2DMake(station.lat, station.lon)
            return annotation
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.map!.removeAnnotations(self.map!.annotations)
            markers.forEach { (annotation) -> Void in
                self.map?.addAnnotation(annotation)
            }
        })
    }        

}

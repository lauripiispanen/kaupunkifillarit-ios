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
    let dataSource = FillariDataSource()
    var mapHasLocatedUser = false
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()

        map = MKMapView()
        map?.delegate = self
        
        dataSource.delegate = self
        
        map!.showsUserLocation = true
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        
        map!.setRegion(region, animated: false)
        
        self.view.addSubview(map!)
        
        map!.translatesAutoresizingMaskIntoConstraints = false
        map!.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        map!.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        map!.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        map!.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        
        dataSource.startRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !mapHasLocatedUser && isWithinDesiredMapBounds(userLocation.coordinate) {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)), animated: true)
            mapHasLocatedUser = true
        }
    }
    
    func isWithinDesiredMapBounds(coords: CLLocationCoordinate2D) -> Bool {
        return coords.latitude > 60.151568 &&
               coords.latitude < 60.194072 &&
               coords.longitude > 24.903618 &&
               coords.longitude < 24.984335
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
                pin?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
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
            let total = station.bikesAvailable + station.spacesAvailable
            
            let annotation = StationAnnotation(amount: station.bikesAvailable, total: total)
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
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "map")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

}

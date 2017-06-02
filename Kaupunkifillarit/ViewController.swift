//
//  ViewController.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 04/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FillariDataSourceDelegate, InfoDrawerViewDelegate {
    
    var map: MKMapView?
    let dataSource = FillariDataSource()
    var mapHasLocatedUser = false
    var zoomedIn = false
    let locationManager = CLLocationManager()
    let infoView = InfoDrawerView()
    var infoViewLeftAnchor:NSLayoutConstraint?
    var infoViewRightAnchor:NSLayoutConstraint?
    let hamburger = ViewController.initHamburger()
    let mapOverlay = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        
        dataSource.delegate = self
        
        map = initMap()
        map!.delegate = self
        
        self.view.addSubview(map!)
        
        mapOverlay.frame = self.view.frame
        mapOverlay.isUserInteractionEnabled = false
        self.view.addSubview(mapOverlay)
        
        infoView.delegate = self
        self.view.addSubview(infoView)

        self.view.addSubview(hamburger)

        self.initConstraints()

        hamburger.addTarget(self, action: #selector(hamburgerChanged), for: .touchUpInside)
    }

    func initMap() -> MKMapView {
        let map = MKMapView()

        map.showsUserLocation = true

        map.setRegion(DEFAULT_MAP_REGION, animated: false)
        return map
    }

    fileprivate static func initHamburger() -> LPIAnimatedHamburgerButton {
        let hamburger = LPIAnimatedHamburgerButton()
        hamburger.animationTime = 0.1
        hamburger.layer.shadowColor = UIColor.black.cgColor
        hamburger.layer.shadowOffset = CGSize(width: 0, height: 2)
        hamburger.layer.shadowRadius = 5.0
        hamburger.layer.shadowOpacity = 0.25
        return hamburger
    }

    func initConstraints() {

        // MAP
        
        map!.translatesAutoresizingMaskIntoConstraints = false
        map!.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        map!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        map!.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        map!.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // HAMBURGER

        hamburger.translatesAutoresizingMaskIntoConstraints = false
        hamburger.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        hamburger.widthAnchor.constraint(equalToConstant: 20).isActive = true
        hamburger.heightAnchor.constraint(equalTo: hamburger.widthAnchor, multiplier: 1.0).isActive = true
        hamburger.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true


        // INFOVIEW

        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let widthConstraint = infoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        widthConstraint.priority = 900
        widthConstraint.isActive = true
        infoView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        infoViewRightAnchor = infoView.rightAnchor.constraint(equalTo: view.rightAnchor)
        infoViewRightAnchor?.isActive = false
        infoViewLeftAnchor = infoView.leftAnchor.constraint(equalTo: view.rightAnchor)
        infoViewLeftAnchor?.isActive = true

        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func onInfoViewShareSelected() {
        let source = SharingActivityItemSource()
        let shareViewController = UIActivityViewController(
            activityItems: [
                source
            ],
            applicationActivities: nil
        )
        shareViewController.excludedActivityTypes = [
            UIActivityType.print,
            UIActivityType.airDrop,
            UIActivityType.openInIBooks,
            UIActivityType.postToFlickr,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll
        ]
        if (shareViewController.popoverPresentationController != nil) {
            shareViewController.view.translatesAutoresizingMaskIntoConstraints = false
            shareViewController.popoverPresentationController?.sourceView = infoView.shareButton
        }
        
        self.present(shareViewController, animated: true, completion: nil)
    }
    
    func hamburgerChanged() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            if (self.hamburger.isHamburger) {
                self.infoViewRightAnchor?.isActive = false
                self.infoViewLeftAnchor?.isActive = true
                self.mapOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            } else {
                self.infoViewLeftAnchor?.isActive = false
                self.infoViewRightAnchor?.isActive = true
                self.mapOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
            self.view.layoutIfNeeded()
        }) { (completed: Bool) -> Void in
            self.infoView.didFinishAnimating()
        }
    }

    func appReturnedFromBackground() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name:
            NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        dataSource.startRefresh()
    }

    func appEnteredBackground() {
        self.mapHasLocatedUser = false
        dataSource.stopRefresh()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(appReturnedFromBackground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name:
            NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        dataSource.startRefresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !mapHasLocatedUser && isWithinDesiredMapBounds(userLocation.coordinate) {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)), animated: true)
            mapHasLocatedUser = true
        }
    }
    
    func isWithinDesiredMapBounds(_ coords: CLLocationCoordinate2D) -> Bool {
        return (coords.latitude > 60.147999 &&
               coords.latitude < 60.222083 &&
               coords.longitude > 24.848328 &&
               coords.longitude < 24.987888) ||
            (coords.latitude > 60.145009 &&
                coords.latitude < 60.179172 &&
                coords.longitude > 24.717007 &&
                coords.longitude < 24.759579)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is StationAnnotation {
            let ann = (annotation as! StationAnnotation)
            let id = String(format: "station-%d/%d-%@", ann.amount, ann.total, String(ann.small))
            
            var pin = mapView.dequeueReusableAnnotationView(withIdentifier: id)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomed = mapView.region.span.latitudeDelta < 0.022
        if zoomed != self.zoomedIn {
            self.zoomedIn = zoomed
            self.redrawStations(dataSource.stations)
        }
    }
    
    func updatedStationData(_ stations: [Station]) {
        self.redrawStations(stations)
    }
    
    func redrawStations(_ stations: [Station]) {
        let markers = stations.map { (station) -> StationAnnotation in
            let total = station.bikesAvailable + station.spacesAvailable
            
            let annotation = StationAnnotation(amount: station.bikesAvailable, total: total, small: !self.zoomedIn)
            annotation.coordinate = CLLocationCoordinate2DMake(station.lat, station.lon)
            return annotation
        }
        DispatchQueue.main.async(execute: {
            let old_annotations = self.map!.annotations
            markers.forEach { (annotation) -> Void in
                self.map?.addAnnotation(annotation)
            }
            self.map!.removeAnnotations(old_annotations)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        #if RELEASE
            trackScreenView("map")
        #endif
    }

    fileprivate func trackScreenView(_ name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
}

private let DEFAULT_MAP_REGION = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

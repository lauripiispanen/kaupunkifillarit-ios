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
    var mapHasLocatedUser = ProcessInfo.processInfo.arguments.contains("NOLOCATION")
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
        var bottomAnchor: NSLayoutYAxisAnchor?
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchor = bottomLayoutGuide.topAnchor
        }
        [
            map!,
            hamburger,
            infoView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            map!.topAnchor.constraint(equalTo: view.topAnchor),
            map!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            map!.leftAnchor.constraint(equalTo: view.leftAnchor),
            map!.rightAnchor.constraint(equalTo: view.rightAnchor),

            hamburger.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            hamburger.widthAnchor.constraint(equalToConstant: 20),
            hamburger.heightAnchor.constraint(equalTo: hamburger.widthAnchor, multiplier: 1.0),
            hamburger.bottomAnchor.constraint(equalTo: bottomAnchor!, constant: -20),

            infoView.topAnchor.constraint(equalTo: view.topAnchor),
            infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let widthConstraint = infoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        widthConstraint.priority = UILayoutPriority(rawValue: 900)
        widthConstraint.isActive = true
        infoView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        infoViewRightAnchor = infoView.rightAnchor.constraint(equalTo: view.rightAnchor)
        infoViewRightAnchor?.isActive = false
        infoViewLeftAnchor = infoView.leftAnchor.constraint(equalTo: view.rightAnchor)
        infoViewLeftAnchor?.isActive = true

        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }

    @objc func hamburgerChanged() {
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

    @objc func appReturnedFromBackground() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name:
            NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        dataSource.startRefresh()
    }

    @objc func appEnteredBackground() {
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
        if !mapHasLocatedUser {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)), animated: true)
            mapHasLocatedUser = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is StationAnnotation {
            let ann = (annotation as! StationAnnotation)
            let id = String(format: "station-%d-%@", ann.amount, String(ann.small))
            
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
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        self.redrawStations(stations)
    }
    
    func updateStarting() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    func redrawStations(_ stations: [Station]) {
        let markers = stations.map { (station) -> StationAnnotation in
            let amount = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") ?
                max(Int(arc4random_uniform(20)) - 6, 0) :
                station.bikesAvailable
            
            let annotation = StationAnnotation(amount: amount, small: !self.zoomedIn)
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
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
}

private let DEFAULT_COORD_SPAN = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
private let HELSINKI_CENTER_COORD = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
private let TURKU_CENTER_COORD = CLLocationCoordinate2D(latitude: 60.449, longitude: 22.265)

private let DEFAULT_MAP_REGION = MKCoordinateRegion(
    center: UserDefaults.standard.string(forKey: "userLocation") == "Turku"
        ? TURKU_CENTER_COORD
        : HELSINKI_CENTER_COORD,
    span: DEFAULT_COORD_SPAN
)

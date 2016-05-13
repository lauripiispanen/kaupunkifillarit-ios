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
    let infoView = UIView()
    var infoViewLeftAnchor:NSLayoutConstraint?
    var infoViewRightAnchor:NSLayoutConstraint?
    let hamburger = LPIAnimatedHamburgerButton()
    let mapOverlay = UIView()

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
        
        mapOverlay.frame = self.view.frame
        mapOverlay.userInteractionEnabled = false
        self.view.addSubview(mapOverlay)
        
        initInfoView(infoView)
        
        self.view.addSubview(infoView)

        
        self.view.addSubview(hamburger)
        hamburger.animationTime = 0.1
        hamburger.addTarget(self, action: #selector(hamburgerChanged), forControlEvents: .TouchUpInside)
        hamburger.layer.shadowColor = UIColor.blackColor().CGColor
        hamburger.layer.shadowOffset = CGSize(width: 0, height: 2)
        hamburger.layer.shadowRadius = 5.0
        hamburger.layer.shadowOpacity = 0.25
        
        map!.translatesAutoresizingMaskIntoConstraints = false
        map!.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        map!.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        map!.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        map!.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        
        hamburger.translatesAutoresizingMaskIntoConstraints = false
        hamburger.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -20).active = true
        hamburger.widthAnchor.constraintEqualToConstant(20).active = true
        hamburger.heightAnchor.constraintEqualToAnchor(hamburger.widthAnchor, multiplier: 1.0).active = true
        hamburger.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20).active = true
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        infoView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        let widthConstraint = infoView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 0.75)
        widthConstraint.priority = 900
        widthConstraint.active = true
        infoView.widthAnchor.constraintLessThanOrEqualToConstant(300).active = true

        infoViewRightAnchor = infoView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        infoViewRightAnchor?.active = false
        infoViewLeftAnchor = infoView.leftAnchor.constraintEqualToAnchor(view.rightAnchor)
        infoViewLeftAnchor?.active = true
    }
    
    private func initInfoView(infoView: UIView) {
        infoView.backgroundColor = UIColor(red: 254.0 / 255.0, green: 187.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
        let image = UIImageView(image: UIImage(named: "kaupunkifillarit-logo.png"))
        infoView.addSubview(image)
        
        image.contentMode = .ScaleAspectFit
        image.clipsToBounds = true
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraintEqualToAnchor(infoView.topAnchor, constant: 20).active = true
        image.leftAnchor.constraintEqualToAnchor(infoView.leftAnchor, constant: 30).active = true
        image.rightAnchor.constraintEqualToAnchor(infoView.rightAnchor, constant: -30).active = true
        image.heightAnchor.constraintEqualToAnchor(image.widthAnchor).active = true
        
        let title = UILabel()
        title.text = "KAUPUNKI-\nFILLARIT.FI"
        title.numberOfLines = 0
        title.font = UIFont(name: "Arial-BoldMT", size: 32.0)
        title.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        
        infoView.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraintEqualToAnchor(image.bottomAnchor).active = true
        title.leftAnchor.constraintEqualToAnchor(infoView.leftAnchor, constant: 30).active = true
        title.rightAnchor.constraintEqualToAnchor(infoView.rightAnchor, constant: -30).active = true
        
        let text = UITextView()
        let html = infoViewTextAsHtml
        text.attributedText = try? NSAttributedString(html:html)
        text.scrollEnabled = true
        text.selectable = true
        text.editable = false
        text.linkTextAttributes = [ NSForegroundColorAttributeName: title.textColor ]
        
        text.textColor = title.textColor
        text.backgroundColor = UIColor.clearColor()
        text.font = UIFont(name: "Arial", size: 12.0)
        
        infoView.addSubview(text)
        
        text.translatesAutoresizingMaskIntoConstraints = false
        
        text.topAnchor.constraintEqualToAnchor(title.bottomAnchor).active = true
        text.leftAnchor.constraintEqualToAnchor(infoView.leftAnchor, constant: 30).active = true
        text.rightAnchor.constraintEqualToAnchor(infoView.rightAnchor, constant: -30).active = true
        text.bottomAnchor.constraintEqualToAnchor(infoView.bottomAnchor).active = true
        

    }
    
    func hamburgerChanged() {
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseIn, animations: {
            if (self.hamburger.isHamburger) {
                self.infoViewRightAnchor?.active = false
                self.infoViewLeftAnchor?.active = true
                self.mapOverlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
            } else {
                self.infoViewLeftAnchor?.active = false
                self.infoViewRightAnchor?.active = true
                self.mapOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func appReturnedFromBackground() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appEnteredBackground), name:
            UIApplicationDidEnterBackgroundNotification, object: nil)
        dataSource.startRefresh()
    }

    func appEnteredBackground() {
        self.mapHasLocatedUser = false
        dataSource.stopRefresh()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appReturnedFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appEnteredBackground), name:
            UIApplicationDidEnterBackgroundNotification, object: nil)
        dataSource.startRefresh()
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            let old_annotations = self.map!.annotations
            markers.forEach { (annotation) -> Void in
                self.map?.addAnnotation(annotation)
            }
            self.map!.removeAnnotations(old_annotations)
        })
    }

    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "map")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    let infoViewTextAsHtml = "<style type=\"text/css\">a { color: #333333; }</style>" +
        "<p>Polkupyöräily lisää kaupunkilaisten onnea. Innostuimme <a href=\"http://reaktor.fi/careers/?utm_source=kaupunkifillarit&amp;utm_medium=referral&amp;utm_campaign=kaupunkifillarit_2016\" target=\"_blank\" title=\"Reaktor careers\">Reaktorilla</a> maan mainioista Helsingin kaupunkipyöristä.</p>" +
        "<p>Kaupunkifillareiden ainoa ongelma on niiden kova suosio. Siispä me kaupunkipyöräilijät, <a href=\"https://twitter.com/sampsakuronen\" target=\"_blank\" title=\"Sampsa Kuronen Twitter\">Sampsa Kuronen</a>, <a href=\"https://twitter.com/albrto\" target=\"_blank\">Antero Päärni</a>, <a href=\"https://twitter.com/lauripiispanen\" target=\"_blank\">Lauri Piispanen</a> ja <a href=\"https://twitter.com/hleinone\" target=\"_blank\">Hannu Leinonen</a>, päätimme vapaa-ajallamme avittaa muita kaupunkilaisia.</p>" +
        "<p>Pyöriä käyttämään pääsee tosi helposti: <a href=\"https://www.hsl.fi/kaupunkipy%C3%B6r%C3%A4t\" target=\"_blank\">hsl.fi/kaupunkipyörät</a></p>" +
        "<p><a href=\"https://www.dropbox.com/sh/ni5lq7nu0waqprs/AAD5hdNUydglidjCfhM27zyDa?dl=0\" target=\"_blank\" title=\"Kaupunkifillarit.fi lehdistömateriaalit\">Press kit löytyy täältä.</a></p>" +
        "<p>Tiedot ovat HSL:n tarjoamaa avointa dataa.</p>"

}

private extension NSAttributedString {
    convenience init(html:String) throws {
        guard let data = html.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw NSError(domain: "Invalid HTML", code: -500, userInfo: nil)
        }
        
        let options = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(unsignedInteger:NSUTF8StringEncoding)]
        try self.init(data: data, options: options, documentAttributes: nil)
    }
}
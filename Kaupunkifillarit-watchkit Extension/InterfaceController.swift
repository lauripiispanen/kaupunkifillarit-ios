//
//  InterfaceController.swift
//  Kaupunkifillarit-watchkit Extension
//
//  Created by Lauri Piispanen on 31/05/2018.
//  Copyright © 2018 Lauri Piispanen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, FillariDataSourceDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var stationsTable: WKInterfaceTable!
    var dataSource: FillariDataSource = FillariDataSource()
    var locationManager: CLLocationManager?
    var location: CLLocation?
    var stations: [Station] = []
    
    
    override init() {
        super.init()
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager?.activityType = .otherNavigation
            self.locationManager?.distanceFilter = 10
        }
        dataSource.delegate = self
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        /*
        bikeStandNameLabel.setText("Päivitetään...")
        numberOfBikesLabel.setText("--")
        distanceLabel.setText("")
        */
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        let authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .authorizedWhenInUse ||
            authStatus == .authorizedAlways) {
            self.locationManager?.requestLocation()
        } else {
            self.locationManager?.requestWhenInUseAuthorization()
        }
            
        dataSource.startRefresh()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.locationManager?.stopUpdatingLocation()
        dataSource.stopRefresh()
        super.didDeactivate()
    }
    
    func redrawStationData() {
        var sortedStations = self.stations
        if let loc = self.location {
            sortedStations = sortedStations.sorted(by: { s1, s2 in
                return loc.distance(from: stationToLoc(s1)) < loc.distance(from: stationToLoc(s2))
            })
        }
        sortedStations = Array(sortedStations.prefix(10))
        self.stationsTable.setNumberOfRows(sortedStations.count, withRowType: "StationRowType")

        (0 ..< self.stationsTable.numberOfRows).forEach { rowNum in
            if let row = stationsTable.rowController(at: rowNum) as? StationRowType {
                if rowNum < sortedStations.count {
                    let station = sortedStations[rowNum]
                    row.setStation(station)
                    row.setDistanceFromLocation(self.location)
                }
            }
        }
    }
    
    func updatedStationData(_ stations: [Station]) {
        self.stations = stations
        redrawStationData()
    }
    
    func updateStarting() {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        redrawStationData()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Couldn't get location", error)
    }

}

class StationRowType: NSObject {

    @IBOutlet weak var bikeStandNameLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfBikesLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    private var bikeStandName: String = " " {
        didSet {
            if bikeStandName != oldValue {
                self.bikeStandNameLabel.setText(bikeStandName)
            }
        }
    }
    private var numberOfBikes: String = " " {
        didSet {
            if numberOfBikes != oldValue {
                self.numberOfBikesLabel.setText(numberOfBikes)
            }
        }
    }
    private var numberOfBikesColor: UIColor = UIColor.black {
        didSet {
            if numberOfBikesColor != oldValue {
                self.numberOfBikesLabel.setTextColor(numberOfBikesColor)
            }
        }
    }
    private var distance: String = " " {
        didSet {
            if distance != oldValue {
                self.distanceLabel.setText(distance)
            }
        }
    }
    var station: Station?

    func setStation(_ station: Station) {
        self.station = station
        self.bikeStandName = station.name
        self.numberOfBikes = String(station.bikesAvailable)
        self.numberOfBikesColor = (
            station.bikesAvailable == 0
                ? UIColor.black
                : Colors.BRANDYELLOW
        )
    }

    func setDistanceFromLocation(_ location: CLLocation?) {
        if let loc = location,
           let st = station {
            let dist = Int(loc.distance(from: stationToLoc(st)))
            self.distance = String(dist) + "m"
        } else {
            self.distance = ""
        }
    }

}


fileprivate func stationToLoc(_ s: Station) -> CLLocation {
    return CLLocation(latitude: s.lat, longitude: s.lon)
}
